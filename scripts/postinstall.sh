#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

NPX_PATH="node_modules/expo-module-scripts/bin/npx"

# Check if the file exists
if [ ! -f "$NPX_PATH" ]; then
    echo "Error: $NPX_PATH does not exist"
    exit 1
fi

# Replace the content of the file
cat >"$NPX_PATH" <<'EOF'
#!/usr/bin/env bash
bunx "$@"
EOF

# Make the new script executable
chmod +x "$NPX_PATH"
