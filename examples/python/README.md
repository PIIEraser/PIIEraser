# Python Integration Examples

This directory contains Python scripts and code snippets demonstrating how to integrate with the PII Eraser REST API efficiently and securely.

## Available Examples

| Script | Description |
| :--- | :--- |
| `simple_example.py` | Minimal getting-started example. Send a single request and print the result. |
| `api_best_practices.py` | High-volume best practices: batching, persistent connections, and concurrency. |
| `streaming_pipeline.py` | Memory-efficient generator pipeline for arbitrarily large datasets (JSONL, database cursors, queues, etc.). |
| `openai_chat_pii_firewall.py` | Remove PII and other sensitive entities from an OpenAI-format conversation via the `/chat/transform` endpoint and forward it to an OpenAI-compatible LLM provider (OpenRouter in this example). |

### `simple_example.py`

The quickest way to verify your PII Eraser deployment is working. Sends a single request and prints the redacted text.

### `api_best_practices.py`

Demonstrates best practices when sending high-volume requests to the PII Eraser `/text/transform` endpoint.

**Key performance optimizations included in this example:**

1.  **Batching (`BATCH_SIZE`):** Sending multiple strings per request reduces network overhead compared to sending texts one by one.
2.  **Persistent Connections (`requests.Session()`):** Using a Session object enables HTTP Keep-Alive, which avoids the expensive TCP/TLS handshake process for every single request.
3.  **Concurrency (`ThreadPoolExecutor`):** By parallelizing requests, you can fully saturate the PII Eraser container's processing capabilities. A standard rule of thumb is to set concurrency to roughly 4x the number of available PII Eraser instances.

### `streaming_pipeline.py`

A memory-efficient, generator-based pipeline for processing arbitrarily large datasets without loading everything into memory. The `redact_stream()` generator accepts any iterable of strings (file lines, database cursors, message queues) and yields redacted results. Useful as a building block for production ETL and data pipelines.

### `openai_chat_pii_firewall.py`

Shows how to use the [`/chat/transform`](https://docs.piieraser.ai/user_guide/chats/) endpoint to strip PII from an OpenAI-format conversation before forwarding it to the OpenAI Chat Completions API. This is the recommended pattern for teams using PII Eraser as a privacy gateway in front of cloud LLM providers.

## Prerequisites

To run the examples in this directory, you will need Python 3.10+ and the `requests` library.

Install the required dependencies using `pip`:

```shell
pip install requests
```

`openai_chat_pii_firewall.py` additionally requires the `openai` library:

```shell
pip install openai
```

## Running the Examples

Before running the scripts, ensure your PII Eraser container is running and accessible.

By default, the scripts assume the API is available at `http://localhost:8000`. If you are running PII Eraser on a different host or port, please update the `API_URL` variable at the top of the respective Python file.
