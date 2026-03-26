#!/bin/sh

set -e

tmpdir="$(mktemp -d)"

print_install_description() {
	echo "This installer will:"
	echo "- download the latest MiroExporter release from GitHub"
	echo "- make the downloaded binary executable"
	echo "- run 'MiroExporter install', which installs it system-wide"
	echo "- remove the temporary download directory afterwards"
}

confirm_installation() {
	printf "Proceed? (y/n): "
	read proceed

	if [ "$proceed" != "y" ]; then
		echo "Installation cancelled."
		exit 0
	fi
}

print_install_start_message() {
	echo "Installing MiroExporter..."
}

cleanup() {
	rm -rf "$tmpdir"
}

setup_cleanup_trap() {
	trap cleanup EXIT INT TERM HUP
}

enter_temp_directory() {
	cd "$tmpdir"
}

download_release_binary() {
	curl -fsSL "https://github.com/spilehx/hx-MiroExporter/releases/latest/download/MiroExporter" -o "./MiroExporter"
}

make_binary_executable() {
	chmod +x "./MiroExporter"
}

run_binary_installer() {
	./MiroExporter install
}

main() {
	print_install_description
	confirm_installation
	print_install_start_message
	setup_cleanup_trap
	enter_temp_directory
	download_release_binary
	make_binary_executable
	run_binary_installer
}

main "$@"
