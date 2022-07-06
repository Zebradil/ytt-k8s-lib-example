# Snippets

Reusable ytt templates and ytt-related snippets.
Just create a symlink to a file or copy-paste it and adjust as needed.

## Content

- [`bin`](bin) contains executable scripts:
  - [`decrypt_for_ytt`](bin/decrypt_for_ytt)
    Decrypts secrets with [sops](https://github.com/mozilla/sops) and annotates them for processing by ytt.
    Usage:
    ```sh
    decrypt_for_ytt secrets.sops.yaml | ytt -f - ...
    ```
- [`overlays`](overlays) contains ytt overlays:
  - [`add-metadata.yaml`](overlays/add-metadata.yaml)
    Contains overlays for adding common metadata to all resources.
    Just include it in ytt workflow.
- [`example-app`](example-app) contains ready to use hello world example, which duplicates some files in this repository
  - TODO: Probably deduplicate or refactor. But could just ledt as it is
- [`templates`](templates) contains some appliable best-practice templates
- [`Makefile`](Makefile) with common targets for ytt-based projects.
  See more documentation inside the file.

