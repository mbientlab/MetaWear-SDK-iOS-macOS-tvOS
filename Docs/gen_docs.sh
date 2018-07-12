jazzy \
    --clean \
    --source-directory ../MetaWear \
    --author MBIENTLAB INC \
    --author_url https://mbientlab.com \
    --github_url https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS \
    --github-file-prefix https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/tree/3.1.2/MetaWear \
    --module-version 3.1.2 \
    --xcodebuild-arguments -workspace,MetaWear.xcworkspace,-scheme,MetaWear-iOS \
    --module MetaWear \
    --exclude=../MetaWear/MetaWear-SDK-Cpp/* \
    --readme ../README.md \
    --hide-documentation-coverage
open docs/index.html

make html
open build/html/index.html
