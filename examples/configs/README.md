# `config.yaml` Examples

PII Eraser can be configured either in REST API requests or via a `config.yaml` file that is mounted into the container. This folder contains some example `config.yaml` files that illustrate how to configure PII Eraser. Please see the [config file reference](https://docs.piieraser.ai/config_file_reference/) for all the possible parameters. `config.template.yaml` also lists all possible parameters with example values.

To use the `config.yaml` examples, please mount them into the container like this:

```shell
docker run -p 8000:8000 -v "<path to config.yaml>:/app/config.yaml:ro" <container repo path>
```