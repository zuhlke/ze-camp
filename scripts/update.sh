#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR/../ZeCamp && $SCRIPT_DIR/../carthage/carthage update --platform ios --no-build
