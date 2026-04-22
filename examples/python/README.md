# Python Integration Examples

This directory contains Python scripts and code snippets demonstrating how to integrate with the PII Eraser REST API efficiently and securely.

| Script | Description |
| :--- | :--- |
| [`simple_example.py`](./simple_example.py) | The quickest way to verify your PII Eraser deployment is working. Sends a single request and prints the redacted text. |
| [`api_best_practices.py`](./api_best_practices.py) | Demonstrates high-volume best practices: batching to reduce network overhead, persistent connections via `requests.Session()` for HTTP Keep-Alive, and concurrency with `ThreadPoolExecutor` to saturate processing capabilities. |
| [`streaming_pipeline.py`](./streaming_pipeline.py) | A memory-efficient, generator-based pipeline for processing arbitrarily large datasets (JSONL, database cursors, message queues) without loading everything into memory. Useful as a building block for production ETL and data pipelines. |
| [`openai_chat_pii_firewall.py`](./openai_chat_pii_firewall.py) | Uses the [`/chat/transform`](https://docs.piieraser.ai/user-guide/chats/) endpoint to strip PII from an OpenAI Chat Completions-format conversation before forwarding it to an OpenAI-compatible LLM provider (OpenRouter in this example).. This is the recommended pattern for teams using PII Eraser as a privacy gateway or PII guardrail in front of cloud LLM providers. |

## Prerequisites

To run the examples in this directory, you will need Python 3.10+ and the `requests` library:

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
