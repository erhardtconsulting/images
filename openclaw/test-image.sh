#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: bash openclaw/test-image.sh IMAGE}
directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
parent=$(awk '$1 == "FROM" && $2 ~ /^ghcr.io\/openclaw\/openclaw:/ { print $2 }' "$directory/Dockerfile")
if ! podman image exists "$parent"; then
    podman pull --quiet "$parent"
fi
metadata='{{.Config.User}}|{{.Config.WorkingDir}}|{{json .Config.Entrypoint}}|{{json .Config.Cmd}}'
test "$(podman image inspect --format "$metadata" "$image")" \
    = "$(podman image inspect --format "$metadata" "$parent")"

# mode works with remote Podman too, unlike uid/gid tmpfs options.
runtime=(--pull=never --read-only --read-only-tmpfs=false
    --tmpfs '/tmp:rw,nosuid,nodev,mode=1777'
    --tmpfs '/home/node:rw,nosuid,nodev,mode=1777')
podman run --rm --network=none "${runtime[@]}" \
    --volume "$directory/tests:/opt/openclaw-tests:ro" \
    "$image" bash /opt/openclaw-tests/smoke.sh

container=$(podman run --detach "${runtime[@]}" "$image" \
    node openclaw.mjs gateway --allow-unconfigured --bind loopback --auth none)
trap '
    result=$?
    if ((result != 0)); then
        podman logs "$container"
    fi
    podman rm --force "$container" >/dev/null
' EXIT
for ((attempt = 0; attempt < 120; attempt++)); do
    if podman exec "$container" node -e \
        'fetch("http://127.0.0.1:18789/healthz", {signal: AbortSignal.timeout(1000)}).then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))'; then
        printf 'Read-only OpenClaw gateway is healthy\n'
        exit 0
    fi
    if [[ $(podman inspect --format '{{.State.Running}}' "$container") != true ]]; then
        printf 'OpenClaw exited before becoming healthy\n' >&2
        exit 1
    fi
    sleep 2
done
printf 'OpenClaw did not become healthy\n' >&2
exit 1
