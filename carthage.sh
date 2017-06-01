#!/bin/bash

# This script is used to generate a drag-and-drop .framework file.

carthage build --no-skip-current
mkdir dist
mv Carthage/Build/iOS/*.framework dist
