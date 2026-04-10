# Python Integration Examples

This directory contains Python scripts and code snippets demonstrating how to integrate with the PII Eraser REST API efficiently and securely. 

## Available Examples

### `api_best_practices.py`

This script demonstrates best practices when sending high-volume requests to the PII Eraser `/text/transform` endpoint. 

**Key performance optimizations included in this example:**

1.  **Batching (`BATCH_SIZE`):** Sending multiples strings per request can reduce network overhead compared to sending texts one by one.
2.  **Persistent Connections (`requests.Session()`):** Using a Session object enables HTTP Keep-Alive, which avoids the expensive TCP/TLS handshake process for every single request.
3.  **Concurrency (`ThreadPoolExecutor`):** By parallelizing requests, you can fully saturate the PII Eraser container's processing capabilities. A standard rule of thumb is to set concurrency to roughly 4x the number of available PII Eraser instances.

Please see the [Performance Tuning Guide](https://docs.piieraser.ai/user_guide/performance/) in the docs for more information.

## Prerequisites

To run the examples in this directory, you will need Python 3.10+ and the `requests` library.

Install the required dependencies using `pip`:

```shell
pip install requests
```

## Running the Examples

Before running the scripts, ensure your PII Eraser container is running and accessible.

By default, the scripts assume the API is available at `http://localhost:8000`. If you are running PII Eraser on a different host or port, please update the `API_URL` variable at the top of the respective Python file.
