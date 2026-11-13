import asyncio
from contextlib import asynccontextmanager
import io
import math
import os
from pathlib import Path
import re
import secrets
import wave

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel

SAMPLE_RATE = 16_000
MIN_FRAMES = SAMPLE_RATE // 4
MAX_FRAMES = SAMPLE_RATE * 20
MAX_BYTES = 44 + MAX_FRAMES * 2


class Recognition(BaseModel):
    text: str | None = None
    minAverageLogProbability: float | None = None
    maxNoSpeechProbability: float | None = None
    hasSpeech: bool = False


def read_pcm(body: bytes) -> bytes:
    if not 44 + MIN_FRAMES * 2 <= len(body) <= MAX_BYTES:
        raise ValueError("Invalid WAV length")
    if (body[:4] != b"RIFF" or body[8:16] != b"WAVEfmt " or
            body[36:40] != b"data" or len(body) % 2 or
            int.from_bytes(body[4:8], "little") != len(body) - 8 or
            int.from_bytes(body[16:20], "little") != 16 or
            int.from_bytes(body[28:32], "little") != SAMPLE_RATE * 2 or
            int.from_bytes(body[32:34], "little") != 2 or
            int.from_bytes(body[40:44], "little") != len(body) - 44):
        raise ValueError("Invalid PCM container")
    with wave.open(io.BytesIO(body), "rb") as recording:
        if (recording.getnchannels(), recording.getsampwidth(), recording.getframerate()) != (1, 2, SAMPLE_RATE):
            raise ValueError("Invalid PCM format")
        return recording.readframes(recording.getnframes())


def load_model():
    from faster_whisper import WhisperModel

    path = Path(os.environ["READING_SPEECH_MODEL_PATH"]).resolve(strict=True)
    if not path.is_dir():
        raise ValueError("Use a preinstalled local faster-whisper model directory")
    threads = int(os.environ.get("READING_SPEECH_CPU_THREADS", "4"))
    if not 1 <= threads <= 32:
        raise ValueError("CPU threads must be between 1 and 32")
    return WhisperModel(str(path), device="cpu", compute_type="int8", cpu_threads=threads,
                        num_workers=1, local_files_only=True)


def transcribe(model, pcm: bytes) -> Recognition:
    import numpy as np

    samples = np.frombuffer(pcm, dtype="<i2").astype(np.float32) / 32768
    segments, _ = model.transcribe(samples, language="ar", task="transcribe", beam_size=5,
                                   vad_filter=True, condition_on_previous_text=False)
    segments = [segment for segment in segments if segment.text.strip()]
    if not segments:
        return Recognition()
    log_probability = min(segment.avg_logprob for segment in segments)
    no_speech = max(segment.no_speech_prob for segment in segments)
    return Recognition(
        text=" ".join(segment.text.strip() for segment in segments),
        minAverageLogProbability=log_probability if math.isfinite(log_probability) else None,
        maxNoSpeechProbability=no_speech if math.isfinite(no_speech) else None,
        hasSpeech=True,
    )


def create_app(model_loader=load_model, recognize=transcribe) -> FastAPI:
    @asynccontextmanager
    async def lifespan(app: FastAPI):
        token = os.environ.get("READING_SPEECH_TOKEN", "")
        if not re.fullmatch(r"[a-zA-Z0-9_-]{32,256}", token):
            raise ValueError("Configure a private READING_SPEECH_TOKEN")
        timeout = float(os.environ.get("READING_SPEECH_TIMEOUT_SECONDS", "25"))
        if not 1 <= timeout <= 55:
            raise ValueError("Inference timeout must be between 1 and 55 seconds")
        app.state.token = f"Bearer {token}".encode("ascii")
        app.state.timeout = timeout
        app.state.model = model_loader()
        app.state.slot = asyncio.Lock()
        yield

    app = FastAPI(lifespan=lifespan, docs_url=None, redoc_url=None, openapi_url=None)

    @app.post("/internal/transcribe", response_model=Recognition)
    async def recognize_recording(request: Request) -> Recognition:
        state = request.app.state
        supplied = request.headers.get("authorization", "").encode("utf-8")
        if not secrets.compare_digest(supplied, state.token):
            raise HTTPException(401)
        if request.headers.get("content-type", "").split(";", 1)[0].strip().lower() != "audio/wav":
            raise HTTPException(415)
        if state.slot.locked():
            raise HTTPException(503)
        await state.slot.acquire()
        job = None
        try:
            body = bytearray()
            try:
                async with asyncio.timeout(5):
                    async for chunk in request.stream():
                        if len(body) + len(chunk) > MAX_BYTES:
                            raise HTTPException(413)
                        body.extend(chunk)
                pcm = read_pcm(bytes(body))
            except TimeoutError:
                raise HTTPException(408) from None
            except (EOFError, ValueError, wave.Error):
                raise HTTPException(400) from None
            if not any(pcm):
                return Recognition()

            job = asyncio.create_task(asyncio.to_thread(recognize, state.model, pcm))
            # Native inference may finish after the HTTP timeout. Keep the slot until it exits.
            def release(completed):
                state.slot.release()
                if not completed.cancelled():
                    completed.exception()

            job.add_done_callback(release)
            try:
                return await asyncio.wait_for(asyncio.shield(job), state.timeout)
            except TimeoutError:
                raise HTTPException(504) from None
            except Exception:
                raise HTTPException(503) from None
        finally:
            if job is None:
                state.slot.release()

    return app


app = create_app()
