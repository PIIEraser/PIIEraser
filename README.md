<div align="center">
  <img src="https://via.placeholder.com/400x120/FFFFFF/000000?text=PII+Eraser+Logo" alt="PII Eraser Logo" width="400"/>

  <p><b>Enterprise-grade PII detection and anonymization for modern data workflows.</b></p>

  <img alt="License" src="https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square">
</div>

---

## Overview

PII Eraser is a high-performance, self-hosted container providing a REST API for the detection, redaction, and masking of Personally Identifiable Information (PII) and confidential entities. 

Designed specifically for compliance-heavy environments (Finance, Healthcare, Legal), PII Eraser processes raw text strings and OpenAI-format chats entirely within your own infrastructure, ensuring sensitive data never leaves your environment.

> **Note:** This repository contains the official deployment templates (AWS CloudFormation, Docker Compose) and integration examples for PII Eraser. The core container image is commercially licensed and available via the AWS Container Marketplace or directly from PII Eraser.

## Key Capabilities

* **Global & Europe-First Localization:** Built with native, deep support for European languages and data formats (DACH, FR, IT, Benelux) alongside comprehensive US/CA/AU/UK coverage. See the [full list in the docs](https://docs.piieraser.ai/entity_types/).
* **Industry Leading Accuracy:** PII Eraser uses the latest transformer technology to detect sensitive entities. This delivers higher accuracy than legacy regex or ML-based detectors, particularly on real world data that doesn't fit rigid formats or contain PII type descriptors (e.g. "My credit card number is ..").
* **Drop-In Presidio Replacement:** Fully compatible with Microsoft Presidio Analyzer workflows, allowing you to upgrade your detection accuracy and performance without rewriting your application logic.
* **LLM & GenAI Ready:** Native support for detecting and anonymizing PII in OpenAI-format chats before they are sent to external LLM providers.
* **Enterprise-Grade Security:** PII Eraser is built with a minimal dependency tree and runs exclusively on CPUs, eliminating the management overhead and persistent patching cycles associated with GPU/CUDA vulnerabilities. Furthermore, it is built on a [Chainguard](https://www.chainguard.dev/) base image, minimizing CVEs at build time and providing a hardened attack surface that satisfies the most stringent enterprise DevSecOps requirements.
* **Optimized Compute Performance:** Highly optimized for modern x86 architectures (e.g., AWS c8a instances), delivering over 5000 tokens/s on a 8 vCPU instance.

## Repository Contents

This repository is designed to help you quickly deploy and integrate PII Eraser into your existing infrastructure:

* `/examples` - API usage examples and sample `config.yaml` files.
* `/deploy` - Deployment templates, including AWS CloudFormation templates for deploying on ECS and EC2.

## Quick Start Example

Once your PII Eraser container is running (see the deployment templates in this repo), you can interact with the REST API to redact text instantly.

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

Please visit the [docs](https://docs.piieraser.ai/#core-capabilities) for more.

## Security

We take the security of your data seriously. PII Eraser is stateless and designed to operate completely offline and air-gapped, with no usage data or telemetry sent back.

If you discover a security vulnerability in the deployment templates or the container itself, please review our [Security Policy](SECURITY.md) for instructions on how to securely report it. **Do not open public issues for security vulnerabilities.**

## License

The code and deployment templates in this repository are licensed under the Apache 2.0 License.

The PII Eraser container image itself is proprietary software licensed via the AWS and Azure Marketplaces or via contract. Usage of the container is subject to the terms of service provided at the time of subscription.

## Support

For support, feature requests, or custom entity training, please [email us](mailto:support@piieraser.ai) at **support@piieraser.ai**.