#!/bin/sh

set -e

tmpdir=""

LATEST_VERSION=""
CURRENT_VERSION=""
UPDATE_AVAILABLE=false
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_new_install_description() {
	echo "This installer will:"
	echo "- download the latest MiroExporter release from GitHub"
	echo "- make the downloaded binary executable"
	echo "- run 'MiroExporter install', which installs it system-wide"
	echo "- remove the temporary download directory afterwards"
}

print_already_installed_description() {
    if [ "$UPDATE_AVAILABLE" = true ]; then
        echo "A newer version of MiroExporter is available: $LATEST_VERSION (currently installed: $CURRENT_VERSION)."
    else
        echo "You have the latest version of MiroExporter installed: $CURRENT_VERSION"
    fi
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
	if [ -n "$tmpdir" ]; then
		rm -rf "$tmpdir"
	fi
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
	tmpdir="$(mktemp -d)"
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


show_already_installed_options() {
        echo ""
        echo "What do you want to do?:"
        echo "  1) Reinstall the latest version ($LATEST_VERSION)"
        echo "  2) Uninstall the currently installed version ($CURRENT_VERSION)"
        echo "  3) Quit and keep the currently installed version"
        printf "Choose an option (1/2/3): "
        read option

        case "$option" in
            1)
                start_install
                ;;
            2)
                start_uninstall
                ;;
            *)
                echo "Bye!"
                ;;
        esac
}

start_reinstall(){
    start_uninstall
    start_install
}

start_uninstall(){
    echo "Uninstalling MiroExporter..."
    MiroExporter uninstall
}



start_already_installed_flow(){
    CURRENT_VERSION=$(retrieve_currently_installed_version)

    if is_newer_version_available; then
        UPDATE_AVAILABLE=true
    else
        UPDATE_AVAILABLE=false
    fi

    print_already_installed_description
    show_already_installed_options
}

retrieve_latest_version() {
    curl -sL "https://api.github.com/repos/spilehx/hx-MiroExporter/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

retrieve_currently_installed_version() {
    MiroExporter version 2>/dev/null || echo "unknown"
}

is_newer_version_available() {
    ## Compare LATEST_VERSION and CURRENT_VERSION.
    ## Return 0 (true) if LATEST_VERSION is newer than CURRENT_VERSION, 1 (false) otherwise.
    ## Version strings are expected in the format "X.Y.Z".

    latest_version=${LATEST_VERSION#v}
    current_version=${CURRENT_VERSION#v}

    old_ifs=$IFS

    IFS=.
    set -- $latest_version
    IFS=$old_ifs

    if [ "$#" -ne 3 ]; then
        return 1
    fi

    for latest_part in "$1" "$2" "$3"; do
        case "$latest_part" in
            ''|*[!0-9]*)
                return 1
                ;;
        esac
    done

    latest_major=$1
    latest_minor=$2
    latest_patch=$3

    IFS=.
    set -- $current_version
    IFS=$old_ifs

    if [ "$#" -ne 3 ]; then
        return 0
    fi

    for current_part in "$1" "$2" "$3"; do
        case "$current_part" in
            ''|*[!0-9]*)
                return 0
                ;;
        esac
    done

    current_major=$1
    current_minor=$2
    current_patch=$3

    if [ "$latest_major" -gt "$current_major" ]; then
        return 0
    fi

    if [ "$latest_major" -lt "$current_major" ]; then
        return 1
    fi

    if [ "$latest_minor" -gt "$current_minor" ]; then
        return 0
    fi

    if [ "$latest_minor" -lt "$current_minor" ]; then
        return 1
    fi

    if [ "$latest_patch" -gt "$current_patch" ]; then
        return 0
    fi

    return 1
}




echo_info() {
    echo "${GREEN}$1${NC}"
}

echo_strong() {
    echo "${BLUE}$1${NC}"
}

echo_warn() {
   echo "${RED}$1${NC}"
}

print_header() {
    echo_info "MiroExporter Installer"
    echo_info "====================="
    echo ""
}






main() {
    print_header


    # LATEST_VERSION=$(retrieve_latest_version)

    # if command -v MiroExporter >/dev/null 2>&1; then
    #     start_already_installed_flow
    # else
    #     start_not_currently_installed_flow
    # fi
}

main "$@"
