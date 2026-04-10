"""
PII Eraser — OpenAI-format Chat PII Firewall Example

Demonstrates the recommended pattern for using PII Eraser as a PII firewall or
privacy gateway between your application and a cloud LLM provider.

Flow:
    1. Build the conversation (system prompt + user message).
    2. Send it to PII Eraser's /chat/transform endpoint to strip PII.
    3. Forward the anonymized conversation to the OpenAI Chat Completions API.
    4. Return the LLM response to the user.

Prerequisites:
    pip install requests openai

Set your OpenRouter API key:
    export OPENROUTER_API_KEY="sk-or-v1-..."
"""

import os

import requests
from openai import OpenAI

PII_ERASER_URL = "http://localhost:8000"
OPENROUTER_MODEL = "openai/gpt-5.4-nano"


def anonymize_chat(messages: list[dict]) -> list[dict]:
    """Send a conversation through PII Eraser and return anonymized messages.

    Only user messages are processed; system and assistant messages are
    preserved so that the LLM's instructions and prior responses remain
    intact.
    """
    response = requests.post(
        f"{PII_ERASER_URL}/chat/transform",
        json={
            "messages": messages,
            "operator": "redact",
            "chat_roles": ["user"],
        },
    )
    response.raise_for_status()
    return response.json()["messages"]


def main():
    # 1. Build the conversation
    conversation = [
        {
            "role": "system",
            "content": ("You are a helpful customer support assistant for a telecoms company. Help the customer with their request."),
        },
        {
            "role": "user",
            "content": (
                "Hi, my name is Stefan Müller and I live at Schillerstraße 42, "
                "80336 Munich. My account number is DE89 3704 0044 0532 0130 00 "
                "and I'd like to change my phone plan."
            ),
        },
    ]

    print("=== Original conversation ===")
    for msg in conversation:
        print(f"  {msg['role']}: {msg['content']}")

    # 2. Anonymize via PII Eraser
    conversation_anonymized = anonymize_chat(conversation)

    print("\n=== Anonymized conversation (sent to OpenRouter) ===")
    for msg in conversation_anonymized:
        print(f"  {msg['role']}: {msg['content']}")

    # 3. Forward to OpenRouter
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        print("\n⚠️  OPENROUTER_API_KEY not set — skipping LLM call.")
        return

    # Initialize OpenAI client pointing to OpenRouter
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=api_key,
    )

    completion = client.chat.completions.create(
        model=OPENROUTER_MODEL,
        messages=conversation_anonymized,
    )
    assistant_reply = completion.choices[0].message.content

    print("\n=== LLM response ===")
    print(f"  assistant: {assistant_reply}")


if __name__ == "__main__":
    main()
