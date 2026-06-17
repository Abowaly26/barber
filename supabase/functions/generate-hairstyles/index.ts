const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  console.log(`[generate-hairstyles] ${req.method} request received`);

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const providerEndpoint = Deno.env.get('AI_PROVIDER_ENDPOINT');
    const providerToken = Deno.env.get('AI_PROVIDER_TOKEN');

    if (!providerEndpoint) {
      console.error('[generate-hairstyles] Missing AI_PROVIDER_ENDPOINT secret');
      return json({ error: 'Missing AI_PROVIDER_ENDPOINT secret' }, 500);
    }

    const body = await req.json();
    const imageUrl = body.imageUrl;
    const count = Number(body.count ?? 8);
    const preferences = body.preferences ?? {};

    if (!imageUrl || typeof imageUrl !== 'string') {
      console.error('[generate-hairstyles] imageUrl is missing');
      return json({ error: 'imageUrl is required' }, 400);
    }

    console.log(`[generate-hairstyles] Calling provider for ${count} images`);

    const providerResponse = await fetch(providerEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(providerToken ? { Authorization: `Bearer ${providerToken}` } : {}),
      },
      body: JSON.stringify({ imageUrl, count, preferences }),
    });

    const providerText = await providerResponse.text();

    if (!providerResponse.ok) {
      console.error(
        `[generate-hairstyles] Provider failed with ${providerResponse.status}: ${providerText}`,
      );
      return json(
        {
          error: 'AI provider request failed',
          status: providerResponse.status,
          details: providerText,
        },
        502,
      );
    }

    const providerData = JSON.parse(providerText);
    const imageUrls = extractImageUrls(providerData).slice(0, count);

    console.log(`[generate-hairstyles] Returning ${imageUrls.length} image URLs`);

    return json({ imageUrls });
  } catch (error) {
    console.error('[generate-hairstyles] Unhandled error', error);
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});

function extractImageUrls(data: unknown): string[] {
  if (!data || typeof data !== 'object') return [];

  const record = data as Record<string, unknown>;

  if (Array.isArray(record.imageUrls)) {
    return record.imageUrls.filter((item): item is string => typeof item === 'string');
  }

  if (Array.isArray(record.results)) {
    return record.results
      .map((item) => {
        if (!item || typeof item !== 'object') return null;
        return (item as Record<string, unknown>).imageUrl;
      })
      .filter((item): item is string => typeof item === 'string');
  }

  return [];
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
