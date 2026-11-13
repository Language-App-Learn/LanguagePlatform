# Private Arabic reading speech service

Use 64-bit Python 3.12 or newer with binary wheels available for the platform. The service uses faster-whisper and CTranslate2 on the local CPU in INT8 mode. The model is loaded once at startup per Uvicorn worker. The operator supplies a local model directory. No model is selected automatically. FastAPI lifespan initializes the worker. [FastAPI lifespan](https://fastapi.tiangolo.com/advanced/events/) and [faster-whisper](https://github.com/SYSTRAN/faster-whisper)

Run the following from this directory on Windows. Keep tokens in the environment or a service secret store.

```powershell
py -3.12 -m venv .venv
& ./.venv/Scripts/python.exe -m pip install --only-binary=:all: -r requirements.txt
$env:READING_SPEECH_MODEL_PATH = (Resolve-Path ./models/small).Path
$env:READING_SPEECH_TOKEN = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
$env:READING_SPEECH_CPU_THREADS = '4'
$env:READING_SPEECH_TIMEOUT_SECONDS = '25'
& ./.venv/Scripts/python.exe -m uvicorn speech_service:app --host 127.0.0.1 --port 8081 --workers 1 --limit-concurrency 8 --no-access-log
```

On Linux use `.venv/bin/python` and export equivalent environment values. Provision the public [small](https://huggingface.co/Systran/faster-whisper-small/tree/main) and [medium](https://huggingface.co/Systran/faster-whisper-medium/tree/main) models at reviewed, pinned revisions ahead of time. The model directories require about 486 MB and 1.53 GB of disk. Run the worker with outbound network access blocked. Bind to loopback on the API host. For a separate host use a private authenticated network and TLS. Only the ASP.NET Core service should reach the worker.

Configure the ASP.NET Core host with `ReadingSpeech__Endpoint=http://127.0.0.1:8081/internal/transcribe` and set `ReadingSpeech__Token` to the same secret. `ReadingSpeech__TimeoutSeconds` defaults to 30 and should exceed the Python inference deadline plus upload time. Keep `ReadingSpeech__AutomaticProgressionEnabled` false until calibration. The private endpoint accepts a bounded PCM WAV body and returns text plus segment confidence summaries. The Python worker allows one in-flight job and responds with 503 when busy. An inference timeout returns 504 and holds the slot until the underlying job exits. Supervise and restart a stuck worker.

Run the model-independent unit tests with `python -m pip install -r requirements-test.txt` and `python -m unittest -v`.

## Choosing and validating a model

The same consented recordings should be evaluated by both models on the intended hardware. Keep the JSON manifest and audio outside Git. The manifest is an array whose records have a relative `wav` path and `spokenText` containing the teacher's verbatim transcription. Use an empty transcription for silence or noise. Add `targetText` for the approved line and include genuine misreads, omissions, repeats and reordering.

```text
python -m pip install -r requirements-benchmark.txt
python benchmark.py PATH_TO_PRIVATE_MANIFEST --small models/small --medium models/medium
```

The tool reports aggregate latency, peak process RAM on Windows and Linux, word error rate and exact transcription count. Supply `--min-log-probability` and `--max-no-speech` to count false lexical approvals and rejected correct readings at candidate settings. Choose the production model and settings after checking these results on representative, held-out recordings. This comparison cannot measure tashkeel, articulation or grammatical endings. Keep automated progression off until approved. Set `ReadingSpeech__MinimumAverageLogProbability` and `ReadingSpeech__MaximumNoSpeechProbability` to the reviewed values before turning it on.

On the local Windows host with four CPU threads, both INT8 models discarded all five one-second test noise signals. Small used 715 MiB peak process RAM and medium used 1,691 MiB. The measured median latency was 9.4 ms and 7.4 ms respectively. Those figures cover a test with no speech and cannot be used to size the production worker or compare Arabic accuracy. The upstream small INT8 CPU benchmark reported 1,477 MB RAM on speech audio. [Upstream CPU benchmark](https://github.com/SYSTRAN/faster-whisper#small-model-on-cpu)

Audio stays in process memory through validation and inference, including a still-running timed-out job. The worker creates no temporary audio files. Disable proxy request buffering to disk, body logging, tracing of payloads, and crash dumps for both services. Configure process memory limits. See the [API contract](../../docs/api/INTERACTIVE_READING_CONTRACT.md) for retained database metadata.
