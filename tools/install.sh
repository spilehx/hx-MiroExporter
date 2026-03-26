#!/bin/sh

set -e

tmpdir="$(mktemp -d)"

LATEST_VERSION=""
CURRENT_VERSION=""

print_new_install_description() {
	echo "This installer will:"
	echo "- download the latest MiroExporter release from GitHub"
	echo "- make the downloaded binary executable"
	echo "- run 'MiroExporter install', which installs it system-wide"
	echo "- remove the temporary download directory afterwards"
}

print_already_installed_description() {
    echo "MiroExporter $CURRENT_VERSION is already installed."
}

confirm_proceed() {
	printf "Proceed? (y/n): "
	read proceed

	if [ "$proceed" != "y" ]; then
		echo "Cancelled."
		exit 0
	fi
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

start_install(){
    echo "Installing MiroExporter..."
	setup_cleanup_trap
	enter_temp_directory
	download_release_binary
	make_binary_executable
	run_binary_installer
}



start_not_currently_installed_flow(){
    print_new_install_description
    confirm_proceed
    start_install
}


start_already_installed_flow(){
    CURRENT_VERSION=$(retrieve_currently_installed_version)


    print_already_installed_description

}

retrieve_latest_version() {
    curl -sL "https://api.github.com/repos/spilehx/hx-MiroExporter/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

retrieve_currently_installed_version() {
    MiroExporter version 2>/dev/null || echo "unknown"
}

is_newer_version_available() {
    ## should compare LATEST_VERSION and CURRENT_VERSION, return true if LATEST_VERSION is newer than CURRENT_VERSION, false otherwise.
    ## version strings follow a semantic versioning pattern are in the format "X.Y.Z", where X, Y, and Z are integers. For example, "1.2.3".
}

main() {
    LATEST_VERSION=$(retrieve_latest_version)
#  echo "Latest MiroExporter version: $LATEST_VERSION"

    if command -v MiroExporter >/dev/null 2>&1; then
        start_already_installed_flow
    else
        start_not_currently_installed_flow
    fi
}

main "$@"
