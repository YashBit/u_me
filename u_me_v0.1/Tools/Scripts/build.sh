#!/bin/bash
# Build script for U&Me

echo "Building U&Me..."
xcodebuild -scheme u_me_v0.1 -configuration Debug build
