#!/bin/bash

sed -i '' -e 's/6YF6QJH524/LQPP7M7XNY/g' ./Meshtastic.xcodeproj/project.pbxproj
sed -i '' -e 's/jpowers.Meshtastic/gvh.Meshtastic/g' ./Meshtastic.xcodeproj/project.pbxproj

# revert entitlement changes
patch ./Meshtastic/Meshtastic.entitlements ./scripts/entitlements-revert.patch
