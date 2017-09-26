# video-downloader

## Overview

This script gets a file list (m3u8) from a HLS connection and downloads it for you. 

As of late, almost all paid courses available on the internet use this protocol to protect their videos from being downloaded, in order to avoid (illegal) sharing. The intention here is to provide a way for legitimate users/students who paid for the (access to the) courses to get a hold of the video files, for their personal use, once the access is revoked. It's in no way intended to aiding you pirate, distribute the files and/or violate/infrige any copyrights. You're solely responsible for what you decide do with it. 

To get to the (m3u8) file, you need to manually extract it from the current session, meaning that you need to choose the video, load it and do the steps to follow: 

* From your browser, press F12 to activate the debug mode, namely "Developer Tools" (the shortcut works for both Chrome and Firefox) and access the Network tab
* When you play the video, look for an URL containing "index.m3u8" in it. All those URLs have the m3u8 extension, so it should be relatively easy to spot them.
* Having found the URL, copy it (to any note taking app or to the clipboard is just fine).

## Usage

Just execute this script! It's gonna guide you through the rest of the process...

## HLS Protocol

I made this script based on: [RFC 8216](https://tools.ietf.org/html/draft-pantos-http-live-streaming-23).

## TO-DO

* Test all remaining cases;
* Try to simplify this script even more;
* Port this script to Python (I'm still learning it :p).
