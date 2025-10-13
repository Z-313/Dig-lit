from modules.ai_engine.core.config import AIEngineConfig
from modules.ai_engine.core.engine import AIEngine
from modules.ai_engine.inference.inference_engine import InferenceEngine

cfg = AIEngineConfig.from_env()
engine = AIEngine(cfg)

engine.load_model("llm", "dummy-llm")
engine.load_model("vision", "dummy-vision")
engine.load_model("audio", "dummy-audio")

infer = InferenceEngine(engine, optimize=False)

print(infer.run("llm", "Hello Dig-lit!"))
print(infer.run("vision", b"\x89PNG...binary-image..."))
print(infer.run("audio", b"\x00\x01\x02\x03"))
