# `config.yaml` Examples

PII Eraser can be configured either in REST API requests or via a `config.yaml` file that is mounted into the container. This folder contains some example `config.yaml` files that illustrate how to configure PII Eraser:

* **[French Legal Tech (Presidio Migration)](./configs/french_legal_tech_presidio.yaml):** Demonstrates how to act as a drop-in replacement for Microsoft Presidio using compatibility aliases, while targeting French-specific entities like SIREN numbers and numéros de sécurité sociale.
* **[UK M&A Deal Room](./configs/uk_ma_deal_room.yaml):** Shows how to use block lists to protect internal project codenames and specific client organizations during financial due diligence.
* **[German Call Centre ASR](./configs/german_call_centre_asr.yaml):** Illustrates how to strictly mask PCI DSS data and European IBANs in customer service transcripts while using allow lists to prevent brand names from being redacted.
* **[Australian Health Insurance LLM](./configs/aus_health_insurance_llm.yaml):** Focuses on redacting strict healthcare and financial identifiers (Medicare, TFN, BSB) into semantic tags, allowing data to be safely processed by cloud-based LLMs while retaining narrative structure.

Please see the [config file reference](https://docs.piieraser.ai/config_file_reference/) for all the possible parameters. `config.template.yaml` also lists all possible parameters with example values.

To use the `config.yaml` examples, please mount them into the container like this:

```shell
docker run -p 8000:8000 -v "<path to config.yaml>:/app/config.yaml:ro" <container repo path>
```