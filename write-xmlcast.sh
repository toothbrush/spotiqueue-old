#!/bin/sh

thePList="Spotiqueue.app/Contents/Info.plist"

buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$thePList")
verNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$thePList")
feedurl=$(/usr/libexec/PlistBuddy -c "Print SUFeedURL" "$thePList")
dateNow=$(date)
signature=$(./sign_update.rb Spotiqueue.app.zip dsa_priv.pem)
diffs=$(git log -n 15 --pretty=format:"<li>%ar: %s </li>")

## now generate the xml file:

cat <<HERE > spotiqueue.xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
   <channel>
      <title>Spotiqueue Changelog</title>
      <link>$feedurl</link>
      <description>Most recent changes with links to updates.</description>
      <language>en</language>
      <item>
      <title>Version $verNumber (build $buildNumber)</title>
          <description><![CDATA[
              <h2>Recent changes:</h2>
              <ul>
$diffs
</ul>
              ]]></description>
          <pubDate>$dateNow</pubDate>
          <enclosure url="http://www.denknerd.org/files/Spotiqueue.app.zip"
              sparkle:version="$buildNumber"
              sparkle:shortVersionString="$verNumber"
              sparkle:dsaSignature="$signature"
              type="application/octet-stream" />
      </item>
   </channel>
</rss>
HERE
