#!/bin/bash

# This script is used to generate a drag-and-drop .framework file.

CURRENT_TAG=$(git describe --abbrev=0 --tags)
SWIFT_VER=$(xcrun swift -version | cut -d" " -f4)
VERSION_DIR=tag-$CURRENT_TAG-swift-$SWIFT_VER-framework

carthage build --no-skip-current
mkdir -p dist/$VERSION_DIR
mv Carthage/Build/iOS/LotameDMP.framework dist/$VERSION_DIR/LotameDMP.framework
cd dist
rm -f $VERSION_DIR.zip
zip -r $VERSION_DIR.zip $VERSION_DIR && rm -rf $_
