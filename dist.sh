#!/bin/sh

#if [[ $# -lt 1 ]]
#then
#   echo "Usage: $0 <releaseVersion>"
#   exit 1
#fi

version='latest'

distDir='dist'

echo "First cleaning out dist dir"
rm -rf $distDir
mkdir -p $distDir


echo "Building dist files for version $version"

mv update.exe  $distDir/updateBananaMap-${version}.exe
cp BananaUpdaterConfig.xml $distDir


ls -lrt $distDir



exit 0
