#!/bin/bash
set -e

DATA_DIR="/data"
MODS_DIR="$DATA_DIR/mods"
MANIFEST="$DATA_DIR/manifest.json"

mkdir -p "$MODS_DIR"

echo "[Init] Downloading mods from manifest..."

# Install jq if not already available
if ! command -v jq &> /dev/null; then
    echo "[Init] jq not found, installing..."
    apt-get update && apt-get install -y jq curl
fi

# Iterate over mods in the manifest and download them
cat "$MANIFEST" | jq -c '.mods[]' | while read mod; do
    FILE_NAME=$(echo "$mod" | jq -r '.fileName')
    PROJECT_ID=$(echo "$mod" | jq -r '.projectId')

    # Example: download from Modrinth (you can tweak for CurseForge links)
    MOD_URL="https://example.com/mods/$PROJECT_ID/$FILE_NAME"  # replace with real URLs
    if [ ! -f "$MODS_DIR/$FILE_NAME" ]; then
        echo "[Init] Downloading $FILE_NAME..."
        curl -fSL "$MOD_URL" -o "$MODS_DIR/$FILE_NAME"
    else
        echo "[Init] $FILE_NAME already exists, skipping"
    fi
done

echo "[Init] Starting Minecraft server..."
exec java -Xms1G -Xmx1G -jar "$DATA_DIR/fabric-server-launch.jar" nogui

