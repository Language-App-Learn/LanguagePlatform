import io
import os
from threading import Event, Thread
import unittest
from unittest.mock import patch
import wave

from fastapi.testclient import TestClient

from speech_service import MAX_BYTES, Recognition, create_app


class SpeechServiceTests(unittest.TestCase):
    def setUp(self):
        token = "T" * 32
        self.headers = {"Authorization": f"Bearer {token}", "Content-Type": "audio/wav"}
        self.calls = 0
        self.loads = 0
        environment = patch.dict(os.environ, {
            "READING_SPEECH_TOKEN": token, "READING_SPEECH_TIMEOUT_SECONDS": "1",
        })
        self.enterContext(environment)

    def load(self):
        self.loads += 1
        return object()

    def recognize(self, model, pcm):
        self.calls += 1
        return Recognition(hasSpeech=True, text="اختبار")

    @staticmethod
    def wave(sample=b"\x01\x01", frames=4_000):
        output = io.BytesIO()
        with wave.open(output, "wb") as recording:
            recording.setparams((1, 2, 16_000, 0, "NONE", "not compressed"))
            recording.writeframes(sample * frames)
        return output.getvalue()

    def post(self, client, audio=None):
        return client.post("/internal/transcribe", headers=self.headers,
                           content=self.wave() if audio is None else audio)

    def test_private_route_and_bounded_wav(self):
        with TestClient(create_app(self.load, self.recognize)) as client:
            self.assertEqual(401, client.post("/internal/transcribe", content=self.wave()).status_code)
            self.assertEqual(404, client.get("/docs").status_code)
            self.assertEqual(400, self.post(client, b"bad audio").status_code)
            self.assertEqual(413, self.post(client, bytes(MAX_BYTES + 1)).status_code)
            self.assertEqual(0, self.calls)

    def test_silence_and_model_reuse(self):
        with TestClient(create_app(self.load, self.recognize)) as client:
            silent = self.post(client, self.wave(b"\x00\x00"))
            self.assertEqual(200, silent.status_code)
            self.assertFalse(silent.json()["hasSpeech"])
            self.assertEqual(0, self.calls)
            for _ in range(2):
                response = self.post(client)
                self.assertEqual(200, response.status_code)
                self.assertTrue(response.json()["hasSpeech"])
            self.assertEqual(2, self.calls)
            self.assertEqual(1, self.loads)

    def test_inference_failure_hides_details_and_releases_capacity(self):
        def fail(model, pcm):
            raise RuntimeError("sensitive diagnostic")

        with TestClient(create_app(self.load, fail)) as client:
            for _ in range(2):
                response = self.post(client)
                self.assertEqual(503, response.status_code)
                self.assertNotIn("sensitive diagnostic", response.text)

    def test_timeout_keeps_native_slot_until_inference_finishes(self):
        started, finish = Event(), Event()

        def block(model, pcm):
            started.set()
            finish.wait(5)
            return Recognition()

        with TestClient(create_app(self.load, block)) as client:
            results = []
            worker = Thread(target=lambda: results.append(self.post(client).status_code))
            worker.start()
            try:
                self.assertTrue(started.wait(3))
                self.assertEqual(503, self.post(client).status_code)
                worker.join(4)
                self.assertEqual([504], results)
                self.assertEqual(503, self.post(client).status_code)
            finally:
                finish.set()
                worker.join(5)
