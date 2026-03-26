#!/bin/sh

set -e

echo "This installer will:"
echo "- download the latest MiroExporter release from GitHub"
echo "- make the downloaded binary executable"
echo "- run 'MiroExporter install', which installs it system-wide"
echo "- remove the temporary download directory afterwards"
printf "Proceed? (y/n): "
read proceed

if [ "$proceed" != "y" ]; then
	echo "Installation cancelled."
	exit 0
fi

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
