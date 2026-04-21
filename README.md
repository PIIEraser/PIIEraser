<div align="center">
  <h1>
    PII Eraser
  </h1>
  <p><b>Self-hosted PII detection and anonymization for modern data workflows and LLM guardrails.</b></p>

  <p>
    <a href="https://docs.piieraser.ai"><strong>📖 Documentation</strong></a> |
    <a href="https://docs.piieraser.ai/api/"><strong>⚡ API Reference</strong></a> |
    <a href="https://piieraser.ai/get-started"><strong>📧 Get Started</strong></a>
  </p>
</div>

---

## Overview

PII Eraser is a high-performance, self-hosted container providing a REST API for the detection, redaction, and masking of Personally Identifiable Information (PII) and confidential entities. 

Designed specifically for compliance-heavy environments including [Financial Services](https://piieraser.ai/solutions/finance), [Insurance](https://piieraser.ai/solutions/insurance) and [Legal](https://piieraser.ai/solutions/legal), PII Eraser processes [text strings](https://docs.piieraser.ai/user_guide/text/) and [OpenAI-format chats](https://docs.piieraser.ai/user_guide/chats/) entirely within your own infrastructure, ensuring sensitive data never leaves your environment.

> **Note:** This repository contains the official deployment templates and integration examples for PII Eraser. The core container image is commercially licensed.

## Key Capabilities

* **Global & Europe-First Localization:** Built with native, deep support for [European languages](https://docs.piieraser.ai/user_guide/languages/) and data formats (DACH, FR, IT, Benelux) alongside comprehensive US/CA/AU/UK coverage.
* **Industry Leading Accuracy:** PII Eraser uses the latest transformer technology to detect [over 60 sensitive entity types](https://docs.piieraser.ai/user_guide/entity_types/). This delivers higher accuracy than legacy regex or ML-based detectors, particularly on real world data that doesn't fit rigid formats or contain PII type descriptors (e.g. "My credit card number is ..").
* **Drop-In Presidio Replacement:** Fully compatible with Microsoft Presidio Analyzer workflows, allowing you to upgrade your detection accuracy and performance without rewriting your application logic. Learn more in the [Presidio Compatibility Guide](https://docs.piieraser.ai/user_guide/presidio/).
* **Easy GenAI Guardrails:** Leverage [native OpenAI-format chat support](https://docs.piieraser.ai/user_guide/chats/) for detecting and anonymizing PII in chats before they are sent to external LLM providers.
* **Enterprise-Grade Security:** PII Eraser is built with a minimal dependency tree and runs exclusively on CPUs, eliminating the management overhead and persistent patching cycles associated with GPU/CUDA vulnerabilities. Built on a [Chainguard](https://www.chainguard.dev/) base image to minimize CVEs at build time and provide a hardened attack surface, PII Eraser is designed for the most stringent [Enterprise DevSecOps requirements](https://docs.piieraser.ai/security-compliance/security/).
* **Optimized Compute Performance:** Highly optimized for modern x86 architectures (e.g., AWS c8a instances), delivering over 5000 tokens/s on a 8 vCPU instance. See our [Hardware & Benchmarks](https://docs.piieraser.ai/installation/benchmarks/) page for details.

## Repository Contents

This repository is designed to help you quickly [deploy](https://docs.piieraser.ai/installation/introduction/) and integrate PII Eraser into your existing infrastructure:

| Directory | Description |
| :--- | :--- |
| [`/examples`](./examples) | API usage examples and sample `config.yaml` files. |
| [`/deploy`](./deploy) | Deployment templates, including [AWS CloudFormation for ECS/EC2](https://docs.piieraser.ai/installation/aws/). Please visit the docs for [Docker Compose](https://docs.piieraser.ai/installation/docker/#docker-compose) and [Kubernetes](https://docs.piieraser.ai/installation/other/#kubernetes). |

## Quick Start Example

Once your PII Eraser container is running, you can interact with the [REST API](https://docs.piieraser.ai/api/) to redact text instantly.

**Request:**
```bash
curl -X 'POST' \
  'http://localhost:8000/text/transform' \
  -H 'Content-Type: application/json' \
  -d '{
  "text": ["Hallo Gunther, wie geht es dir?"],
  "operator": "redact"
}'
````

**Response:**

```json
{
  "text": [
    "Hallo <NAME>, wie geht es dir?"
  ],
  "entities": [
    [
      {
        "entity_type": "NAME",
        "output_start": 6,
        "output_end": 12
      }
    ]
  ],
  "stats": {
    "total_tokens": 14,
    "tps": 5500.23
  }
}
```

Please visit the [Processing Text guide](https://docs.piieraser.ai/user_guide/text/) and the [Processing Chats guide](https://docs.piieraser.ai/user_guide/chats/) for more details.

## Security

We take the security of your data seriously. PII Eraser is stateless and designed to operate completely offline and air-gapped. For more details on our security architecture, visit our [Security Documentation](https://docs.piieraser.ai/security-compliance/security/).

If you discover a security vulnerability, please review our [Security Policy](SECURITY.md) for instructions on how to securely report it. **Do not open public issues for security vulnerabilities.**

## License

The code and deployment templates in this repository are licensed under the Apache 2.0 License.

The PII Eraser container image itself is proprietary software. See [Third Party Licenses](https://docs.piieraser.ai/third_party_licenses/) for information on bundled open-source components.

## Support

For support, feature requests, or custom entity training, please email us at **support@piieraser.ai**.