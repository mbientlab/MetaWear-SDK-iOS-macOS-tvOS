#!/bin/bash
set -e

jazzy \
    --clean \
    --source-directory MetaWear \
    --author MBIENTLAB INC \
    --author_url https://mbientlab.com \
    --github_url https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS \
    --github-file-prefix https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/$1/MetaWear \
    --module-version $1 \
    --xcodebuild-arguments -UseModernBuildSystem=YES,-workspace,MetaWear.xcworkspace,-scheme,MetaWear-AsyncUtils-Core-DFU-UI-iOS \
    --module MetaWear \
    --exclude=MetaWear/MetaWear-SDK-Cpp/* \
    --readme README.md \
    --hide-documentation-coverage \
    --output Build/api_docs
open Build/api_docs/index.html

make -C Docs html
open Docs/build/html/index.html
