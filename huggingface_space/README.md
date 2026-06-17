# AI Hair Advisor Provider

Free Hugging Face Space provider for the Supabase `generate-hairstyles` Edge Function.

This first version returns generated hairstyle image URLs using a free public image endpoint. It is useful to validate the full Flutter -> Supabase -> AI provider flow.

Important: this does not preserve the uploaded user's face yet. True face-preserving hairstyle try-on needs an image-to-image/inpainting model such as SDXL + IP-Adapter/InstantID and usually requires paid GPU or a stronger hosted provider.

Endpoint:

```text
POST /generate-hairstyles
```

Body:

```json
{
  "imageUrl": "https://...",
  "count": 8,
  "preferences": {}
}
```

Response:

```json
{
  "imageUrls": ["https://...", "https://..."]
}
```
