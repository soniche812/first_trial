#!/usr/bin/env bash
# Build the SONICHE app and run all tests on the newest available iPhone simulator.
# Runs on macOS with Xcode installed: locally on a Mac and in GitHub Actions.
set -euo pipefail

cd "$(dirname "$0")/.."

xcodebuild -version
xcodebuild -list -project Soniche.xcodeproj

# Pick the iPhone simulator with the newest iOS runtime.
UDID="$(xcrun simctl list devices available --json | python3 -c '
import json, sys
best = None
for runtime, devices in json.load(sys.stdin)["devices"].items():
    if ".iOS-" not in runtime:
        continue
    version = tuple(int(p) for p in runtime.split(".iOS-")[1].split("-"))
    for d in devices:
        if d["name"].startswith("iPhone") and (best is None or version > best[0]):
            best = (version, d["udid"], d["name"])
if best is None:
    sys.exit("No available iPhone simulator found")
version_text = ".".join(str(p) for p in best[0])
print("Using " + best[2] + " on iOS " + version_text, file=sys.stderr)
print(best[1])
')"

xcodebuild test \
    -project Soniche.xcodeproj \
    -scheme Soniche \
    -destination "id=${UDID}" \
    CODE_SIGNING_ALLOWED=NO
