#!/usr/bin/env sh

# The CI messes with our project before building:
# * Inserted signing settings in the project file.
# * Inserted environmental keys to the app’s info.plist.
#
# We know what we want, so undo anything the CI did
git reset --hard
