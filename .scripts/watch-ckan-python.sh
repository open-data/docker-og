#!/usr/bin/env bash

set -euo pipefail;

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/ckan";
WATCH_DIR="$PROJECT_ROOT/src";
RELOAD_FILE="$PROJECT_ROOT/reload.trigger";

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "ERROR: inotifywait is not installed.";
  docker-compose exec -t ckan sh -c 'echo "[CKAN RELOAD] ERROR: inotifywait is not installed." >> /proc/1/fd/1';
  exit 1;
fi

if [[ ! -d "$WATCH_DIR" ]]; then
  echo "ERROR: CKAN source directory not found: $WATCH_DIR";
  exit 1;
fi

declare -A FILE_HASHES;
while IFS= read -r -d '' file; do
  hash=$(sha256sum < "$file");
  FILE_HASHES["$file"]="${hash%% *}";
done < <(find "$WATCH_DIR" -type f -name '*.py' -print0);

echo "Watching: $WATCH_DIR";
docker-compose exec -T -e WATCH_DIR="$WATCH_DIR" ckan sh -c 'echo "[CKAN RELOAD] Watching: $WATCH_DIR" >> /proc/1/fd/1';
echo "Reload trigger: $RELOAD_FILE";
docker-compose exec -T -e RELOAD_FILE="$RELOAD_FILE" ckan sh -c 'echo "[CKAN RELOAD] Reload trigger: $RELOAD_FILE" >> /proc/1/fd/1';
echo "READY";

while IFS= read -r file; do
  [[ "$file" == *.py && -f "$file" ]] || continue;
  new_hash=$(sha256sum < "$file");
  new_hash="${new_hash%% *}";
  old_hash="${FILE_HASHES["$file"]-}";
  [[ "$new_hash" == "$old_hash" ]] && continue;
  FILE_HASHES["$file"]="$new_hash";
  echo "Python file changed: $file";
  docker-compose exec -T -e CHANGED_FILE="$file" ckan sh -c 'echo "[CKAN RELOAD] Python file changed: $CHANGED_FILE" >> /proc/1/fd/1';
  touch "$RELOAD_FILE";
done < <(
  inotifywait \
    --monitor \
    --recursive \
    --quiet \
    --event close_write,moved_to,create,delete \
    --exclude '(/\.git/|/__pycache__/|/\.venv/|/venv/|/build/|/dist/)' \
    --format '%w%f' \
    "$WATCH_DIR"
);
