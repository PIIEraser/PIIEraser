"""
PII Eraser — Streaming Pipeline Example

A memory-efficient, generator-based pipeline for processing arbitrarily large
datasets. The ``redact_stream`` generator accepts any iterable of strings —
file lines, database cursors, message queue consumers — and yields redacted
results without loading the full dataset into memory.

This pattern is useful as a building block inside ETL jobs, Kafka consumers,
or any situation where data arrives as a continuous stream.

Usage:
    python streaming_pipeline.py
"""

from collections.abc import Iterable, Iterator

import requests

API_URL = "http://localhost:8000/text/transform"


def redact_stream(
    texts: Iterable[str],
    *,
    session: requests.Session | None = None,
    batch_size: int = 5,
    operator: str = "redact",
) -> Iterator[str]:
    """Yield redacted strings from an arbitrary iterable of input strings.

    Internally buffers *batch_size* items at a time and sends them to
    PII Eraser in a single API call for efficiency.

    Args:
        texts: Any iterable (generator, list, file object, queue, …).
        session: Optional ``requests.Session`` for connection reuse.
                 A new session is created if not provided.
        batch_size: Number of texts per API request.
        operator: PII Eraser operator (redact, mask, hash, redact_constant).

    Yields:
        Redacted text strings, one for each input string, in order.
    """
    if session is None:
        session = requests.Session()

    batch: list[str] = []

    for text in texts:
        batch.append(text)

        if len(batch) >= batch_size:
            yield from _flush(session, batch, operator)
            batch = []

    # Flush any remaining items.
    if batch:
        yield from _flush(session, batch, operator)


def _flush(session: requests.Session, batch: list[str], operator: str) -> list[str]:
    """Send a batch to PII Eraser and return the redacted texts."""
    response = session.post(API_URL, json={"text": batch, "operator": operator})
    response.raise_for_status()
    return response.json()["text"]


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    # --- Example 1: Process a JSONL file line-by-line ---
    # Imagine a multi-GB file; the generator never loads it all into memory.
    print("=== Example 1: JSONL / text file ===")
    import io
    import json

    sample_file = io.StringIO("\n".join(json.dumps({"id": i, "text": f"Patient {i}: Anna Schneider, DOB 12/03/1985"}) for i in range(60)))

    def lines_from_jsonl(fh):
        """Yield the 'text' field from each JSONL line."""
        for line in fh:
            yield json.loads(line)["text"]

    for redacted in redact_stream(lines_from_jsonl(sample_file)):
        print(redacted)

    # --- Example 2: Infinite stream (e.g. message queue) ---
    print("\n=== Example 2: Simulated infinite stream (first 10 shown) ===")

    def fake_queue() -> Iterator[str]:
        """Simulate an infinite message queue."""
        names = ["Luca Rossi", "Marie Dupont", "Stefan Müller", "Jane Smith"]
        i = 0
        while True:
            yield f"Customer {names[i % len(names)]} placed order #{1000 + i}."
            i += 1

    session = requests.Session()
    for i, redacted in enumerate(redact_stream(fake_queue(), session=session)):
        print(redacted)
        if i >= 9:
            break  # Stop after 10 for this demo.
