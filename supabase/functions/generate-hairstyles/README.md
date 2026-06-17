# generate-hairstyles

Supabase Edge Function used by the Flutter AI Hair Advisor flow.

Input body:

```json
{
  "imageUrl": "https://...",
  "preferences": {},
  "count": 8
}
```

Expected provider response shape:

```json
{
  "imageUrls": ["https://...", "https://..."]
}
```

or:

```json
{
  "results": [
    { "imageUrl": "https://..." }
  ]
}
```

Required secrets:

```bash
supabase secrets set AI_PROVIDER_ENDPOINT=https://your-provider-endpoint
supabase secrets set AI_PROVIDER_TOKEN=your_optional_provider_token
```

Deploy:

```bash
supabase functions deploy generate-hairstyles
```

Run Flutter with Supabase config:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```
