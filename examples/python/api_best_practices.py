from concurrent.futures import ThreadPoolExecutor, as_completed

import requests

API_URL = "http://your-pii-eraser-endpoint:8000/text/transform"

# --- Your input data ---
texts = 100 * ["My name is Anna Schneider and I live in London."]


def process_texts(session: requests.Session, batch: list[str]) -> dict:
    """Send a batch of texts to PII Eraser using a persistent session."""
    response = session.post(API_URL, json={"text": batch, "operator": "redact"})
    response.raise_for_status()
    return response.json()


# --- Configuration ---
CONCURRENCY = 8  # Target: 4 × number of PII Eraser instances
BATCH_SIZE = 20  # 10–50 texts per request is a reasonable default

# Split texts into batches
batches = [texts[i : i + BATCH_SIZE] for i in range(0, len(texts), BATCH_SIZE)]

# Use a Session for HTTP Keep-Alive (avoids TCP/TLS handshake per request)
session = requests.Session()

# Process batches concurrently
with ThreadPoolExecutor(max_workers=CONCURRENCY) as executor:
    futures = {executor.submit(process_texts, session, batch): batch for batch in batches}
    for future in as_completed(futures):
        result = future.result()
        for text in result["text"]:
            print(text)
