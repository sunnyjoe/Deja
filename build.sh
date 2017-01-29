#!/bin/sh

# ./build.sh product
if [ $1 = "product" ]; 
then 
	echo "product build"
	configuration="ProductDis"
	hockeyAppId="cf0ab58d2082c145f740f58967ce541a"
else 
	echo "test build"
	configuration="TestDis"
	hockeyAppId="2e9b209523daeff38f3b2462e054b49d"
fi

branchName="develop"

if [ $# -eq 2 ] 
then
	branchName=$2
fi

# code update
cd ~/deja-ios
git reset --hard
git checkout -f $branchName
git pull origin $branchName

# version number
buildNumber=`date +%Y%m%d%H%M`
echo "build start, buildNumber = $buildNumber"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" /Users/danychen/deja-ios/DejaFashion/Info.plist

workspaceName="DejaFashion.xcworkspace"
scheme="DejaFashion"
archivePath="build/DejaFashion_$buildNumber.xcarchive"
echo $archivePath

# build
xcodebuild clean -configuration "$configuration" -alltargets
xcodebuild archive -workspace "$workspaceName" -scheme "$scheme" -configuration "$configuration" -archivePath "$archivePath"

# upload to hockeyApp
changeLogDate=$(head -n 1 ChangeLog)
echo "changeLogDate = $changeLogDate"
today=`date +%Y.%m.%d`
if [[ $changeLogDate == *$today* ]]; 
then
	/usr/local/bin/puck -submit=auto -download=true -notes_path="$PWD/ChangeLog" -notes_type=markdown -app_id="$hockeyAppId" "$archivePath"
else
	/usr/local/bin/puck -submit=auto -download=true -app_id="$hockeyAppId" "$archivePath"
fi