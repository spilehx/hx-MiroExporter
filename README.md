# hx-MiroExporter

`hx-MiroExporter` is a Haxe command line tool for working with Miro `.rtb` backup files.

The project extracts `.rtb` archives, preserves the raw exported files, and builds a structured offline output that lets a user inspect as much of the board data as possible without using the Miro platform.

## What it does

- extracts `.rtb` files
- stores the raw extracted files
- exports supported embedded resources such as images, SVGs, and videos
- generates structured metadata files
- generates an offline summary HTML page
- provides an interactive local web UI for uploading and browsing exports

## Current limitation

Miro board layout and canvas object reconstruction are limited because the main `canvas.json` payload inside `.rtb` exports appears to be opaque or encrypted, so this project focuses on the metadata and resource files that can be reliably accessed.

## Commands

```bash
MiroExporter extract <path-to-file.rtb>
MiroExporter interactive
MiroExporter install
MiroExporter version
```

## Interactive mode

Interactive mode starts a local HTTP server and opens the browser automatically. Uploaded files and generated exports are stored in:

```text
~/MiroExporter/
```

For example:

```text
~/MiroExporter/interactive_uploads
```

## Quick install

```bash
tmpdir="$(mktemp -d)" && (cd "$tmpdir" && curl -L https://github.com/spilehx/hx-MiroExporter/releases/latest/download/MiroExporter -o ./MiroExporter && chmod +x ./MiroExporter && ./MiroExporter install); exit_code=$?; rm -rf "$tmpdir"; exit $exit_code
```

This downloads the latest release binary with `curl`, makes it executable, runs `./MiroExporter install`, and always removes the temporary download directory afterwards while preserving the install command's exit code.
