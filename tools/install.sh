#!/bin/sh

set -e

echo "Installing MiroExporter..."




tmpdir="$(mktemp -d)"

cleanup() {
	rm -rf "$tmpdir"
}

trap cleanup EXIT INT TERM HUP

cd "$tmpdir"
curl -fsSL "https://github.com/spilehx/hx-MiroExporter/releases/latest/download/MiroExporter" -o "./MiroExporter"
chmod +x "./MiroExporter"
./MiroExporter install
