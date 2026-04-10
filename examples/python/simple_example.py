"""
PII Eraser — Simple Example

The quickest way to verify your deployment is working.
Sends a single request and prints the redacted text.
"""

import json

import requests

API_URL = "http://localhost:8000"

# --- Redact ---
response = requests.post(
    f"{API_URL}/text/transform",
    json={
        "text": [
            "Hi, my name is Anna Schneider and my email is anna.schneider@example.com.",
            "Meine Steuer-ID ist 12 345 678 901.",
        ],
        "operator": "redact",
    },
)
response.raise_for_status()
result = response.json()

print("=== Redacted texts ===")
for text in result["text"]:
    print(text)

print("\n=== Full API response ===")
print(json.dumps(result, indent=4))
