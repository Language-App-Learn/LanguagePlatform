"""Compare both local model candidates against a private, teacher-labelled WAV manifest."""
import argparse
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import time
import unicodedata

from speech_service import load_model, read_pcm, transcribe


def words(text):
    normalized = []
    for char in unicodedata.normalize("NFKC", text):
        if unicodedata.category(char) in {"Mn", "Mc", "Me", "Cf"} or char == "ـ":
            continue
        normalized.append("ا" if char == "ٱ" else char if char.isalnum() else " ")
    return "".join(normalized).split()


def edits(expected, actual):
    previous = list(range(len(actual) + 1))
    for index, token in enumerate(expected, 1):
        row = [index]
        for column, other in enumerate(actual, 1):
            row.append(min(row[-1] + 1, previous[column] + 1, previous[column - 1] + (token != other)))
        previous = row
    return previous[-1]


def percentile(values, fraction):
    return sorted(values)[math.ceil(fraction * len(values)) - 1]


def measure(model_path, cases, min_log_probability, max_no_speech):
    import psutil

    os.environ["READING_SPEECH_MODEL_PATH"] = str(model_path)
    process = psutil.Process()
    model = load_model()
    latencies, exact, tokens, changes, missing = [], 0, 0, 0, 0
    false_accepts, false_rejects, correct_cases, incorrect_cases = 0, 0, 0, 0
    for case, pcm in cases:
        start = time.perf_counter()
        result = transcribe(model, pcm)
        latencies.append((time.perf_counter() - start) * 1000)
        expected, actual = words(case["spokenText"]), words(result.text or "")
        exact += expected == actual
        tokens += len(expected)
        changes += edits(expected, actual)
        missing += not result.hasSpeech
        if "targetText" in case and min_log_probability is not None:
            target = words(case["targetText"])
            correct = bool(target) and expected == target
            passed = (bool(target) and actual == target and result.hasSpeech and
                      result.minAverageLogProbability is not None and
                      min_log_probability <= result.minAverageLogProbability <= 0 and
                      result.maxNoSpeechProbability is not None and
                      0 <= result.maxNoSpeechProbability <= max_no_speech)
            correct_cases += correct
            incorrect_cases += not correct
            false_accepts += passed and not correct
            false_rejects += not passed and correct
    memory = process.memory_info()
    peak = getattr(memory, "peak_wset", None)
    if peak is None and sys.platform.startswith("linux"):
        import resource
        peak = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss * 1024
    print(json.dumps({
        "recordings": len(cases), "p50_ms": round(percentile(latencies, .50), 1),
        "p95_ms": round(percentile(latencies, .95), 1), "no_speech": missing,
        "exact_transcriptions": exact, "word_error_rate": round(changes / tokens, 4) if tokens else None,
        "peak_ram_mib": round(peak / (1024 ** 2), 1) if peak is not None else None,
        "false_accepts": false_accepts if incorrect_cases else None, "incorrect_cases": incorrect_cases,
        "false_rejects": false_rejects if correct_cases else None, "correct_cases": correct_cases,
    }))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--small", type=Path, required=True)
    parser.add_argument("--medium", type=Path, required=True)
    parser.add_argument("--min-log-probability", type=float)
    parser.add_argument("--max-no-speech", type=float)
    parser.add_argument("--worker", choices=("small", "medium"), help=argparse.SUPPRESS)
    args = parser.parse_args()
    thresholds = (args.min_log_probability, args.max_no_speech)
    if thresholds != (None, None) and not (None not in thresholds and
            -10 <= args.min_log_probability < 0 and 0 < args.max_no_speech < 1):
        parser.error("Provide both thresholds in their allowed ranges.")
    if args.worker:
        entries = json.loads(args.manifest.read_text(encoding="utf-8"))
        if not entries:
            parser.error("Provide at least one labelled recording.")
        cases = [(case, read_pcm((args.manifest.parent / case["wav"]).read_bytes())) for case in entries]
        measure(getattr(args, args.worker), cases, *thresholds)
        return
    for name in ("small", "medium"):
        command = [sys.executable, __file__, str(args.manifest), "--small", str(args.small),
                   "--medium", str(args.medium), "--worker", name]
        if args.min_log_probability is not None:
            command.extend(["--min-log-probability", str(args.min_log_probability),
                            "--max-no-speech", str(args.max_no_speech)])
        output = subprocess.check_output(command, text=True)
        print(f"{name}: {output.strip()}", flush=True)


if __name__ == "__main__":
    main()
