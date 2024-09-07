#!/bin/bash


DEFAULT_APP_PROFILE_ID=GCH7VS5Y9R

DEFAULT_DEV_USER=thebentern
DEFAULT_DEV_PROFILE_ID=6YF6QJH524

PROFILE_ID=${LOCAL_PROFILE_ID:DEFAULT_APP_PROFILE_ID}
CURRENT_USER=$(whoami)
APP_ALIAS=${CURRENT_USER:DEFAULT_DEV_USER}

sed -i '' -e "s/${PROFILE_ID}/${DEFAULT_APP_PROFILE_ID}/g" ./Meshtastic.xcodeproj/project.pbxproj
sed -i '' -e "s/${APP_ALIAS}.Meshtastic/gvh.Meshtastic/g" ./Meshtastic.xcodeproj/project.pbxproj
