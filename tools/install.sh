echo "Installing MiroExporter..."




tmpdir="$(mktemp -d)" && (cd "$tmpdir" && curl -L https://github.com/spilehx/hx-MiroExporter/releases/latest/download/MiroExporter -o ./MiroExporter && chmod +x ./MiroExporter && ./MiroExporter install); exit_code=$?; rm -rf "$tmpdir"; exit $exit_code