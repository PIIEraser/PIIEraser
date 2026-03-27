# Security Policy

At PII Eraser, security and data privacy are foundational to our product. We take all security vulnerabilities seriously and appreciate the efforts of the security community and our customers in helping us maintain an enterprise-grade standard.

## Security Posture
PII Eraser is designed for high-compliance environments (Finance, Healthcare, Legal) and deploys as a single, stateless container. PII Eraser is designed to run in air gapped environments with no external internet access and no information of any kind is transmitted back to PII Eraser. 

To minimize our attack surface, the PII Eraser container is built on [Chainguard](https://www.chainguard.dev/) base images, ensuring a minimal footprint with zero known CVEs at the time of build. 

*Note: This repository primarily contains deployment templates (e.g., AWS CloudFormation) and usage examples. The core PII Eraser container is distributed securely via the AWS and Azure Container Marketplaces and PII Eraser's container repository.*

## Supported Versions

We provide security updates for the current major version of the PII Eraser container and deployment templates. 

## Reporting a Vulnerability

If you discover a potential security vulnerability in the PII Eraser container, or the deployment templates within this repository, **please do not open a public GitHub issue.**

Instead, please report it to us privately via email:

**Email:** security@piieraser.ai

### What to include in your report:
To help us triage and resolve the issue quickly, please include the following:
* A description of the vulnerability and its potential impact.
* The version of the PII Eraser container or the specific template where the vulnerability exists.
* Detailed steps to reproduce the vulnerability (a proof of concept is highly appreciated).
* Any relevant system information (e.g., AWS instance type, OS, environment).

### Our Response Committment
As a provider of privacy-critical software, we commit to the following process:
1.  **Acknowledge:** We will acknowledge receipt of your vulnerability report within 48 hours.
2.  **Triage:** We will investigate and confirm the vulnerability, providing you with an estimated timeline for a patch.
3.  **Remediate:** We will develop and release a patch to our Container Marketplace listings & container repository and update this repository if applicable.
4.  **Disclose:** Once the vulnerability is patched and customers have had time to update, we will publicly acknowledge your contribution (if desired).

## Out of Scope
The following types of reports are generally considered out of scope:
* Theoretical vulnerabilities without a clear proof of concept.
* Misconfigurations of the underlying cloud infrastructure (e.g., AWS IAM roles) that are explicitly meant to be configured by the user, unless the default templates provided in this repo are fundamentally insecure.
* Volumetric Denial of Service (DoS) attacks.