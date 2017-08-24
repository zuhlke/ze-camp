#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR/../ZeCamp && $SCRIPT_DIR/../carthage/carthage bootstrap --platform ios --no-build
