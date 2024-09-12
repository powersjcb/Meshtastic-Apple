#!/bin/bash

sed -i '' -e 's/GCH7VS5Y9R/LQPP7M7XNY/g' ./Meshtastic.xcodeproj/project.pbxproj
sed -i '' -e 's/gvh.Meshtastic/jpowers.Meshtastic/g' ./Meshtastic.xcodeproj/project.pbxproj

# patch the entitlements file to remove carplay
patch ./Meshtastic/Meshtastic.entitlements ./scripts/entitlements-build.patch

