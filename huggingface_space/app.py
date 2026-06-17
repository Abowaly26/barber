from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict
from urllib.parse import quote
import time


class GenerateRequest(BaseModel):
    imageUrl: str
    count: int = 8
    preferences: Dict[str, str] = {}


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


STYLES = [
    "modern textured crop haircut with low fade",
    "classic side part haircut with clean taper",
    "high fade pompadour haircut",
    "low taper fade haircut",
    "curly top fade haircut",
    "buzz cut fade haircut",
    "french crop haircut with short fringe",
    "slick back undercut hairstyle",
]


@app.get("/")
def health():
    return {"status": "ok", "message": "AI hair advisor provider is running"}


@app.post("/generate-hairstyles")
def generate_hairstyles(request: GenerateRequest):
    count = max(1, min(request.count, len(STYLES)))
    timestamp = int(time.time())
    image_urls = []

    for index, style in enumerate(STYLES[:count]):
        prompt = (
            "realistic professional barber hairstyle preview, "
            f"{style}, front facing portrait, clean studio lighting, "
            "sharp hair detail, natural skin, high quality"
        )
        image_urls.append(
            "https://image.pollinations.ai/prompt/"
            + quote(prompt)
            + f"?width=768&height=768&seed={timestamp + index}&nologo=true"
        )

    return {"imageUrls": image_urls}
