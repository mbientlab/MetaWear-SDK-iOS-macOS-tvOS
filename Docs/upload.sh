VERSION="2.8.2"
MBIENT_IP=192.232.222.243

ssh -p 2222 mbient@$MBIENT_IP "mkdir ~/www/docs/metawear/ios/$VERSION"
scp -r -P 2222 html/* mbient@$MBIENT_IP:~/www/docs/metawear/ios/$VERSION
ssh -p 2222 mbient@$MBIENT_IP "ln -sfn ~/www/docs/metawear/ios/$VERSION ~/www/docs/metawear/ios/latest"

ssh -p 2222 mbient@$MBIENT_IP "mkdir ~/www/iosdocs/$VERSION"
scp -r -P 2222 build/html/* mbient@$MBIENT_IP:~/www/iosdocs/$VERSION
ssh -p 2222 mbient@$MBIENT_IP "ln -sfn ~/www/iosdocs/$VERSION ~/www/iosdocs/latest"

git checkout master
git merge --no-ff release-$VERSION -m "Merge branch 'release-$VERSION'"
git tag -a "$VERSION" -m "Update to $VERSION - See release notes"
git push
git push --tags
open "https://github.com/mbientlab/MetaWear-SDK-iOS-macOS-tvOS/commits/master"

pod trunk push ../MetaWear.podspec --verbose

git checkout develop
git merge --no-ff release-$VERSION -m "Merge branch 'release-$VERSION' into develop"
git push
git branch -d release-$VERSION
