# vynl-ios2

An iOS app that allows users to listen to music together.

A user can create a room, where others can join and add/vote on youtube videos. The queue seamlessly updates, and everyone gets to play what they want.

Built using Swift 2 and Node.js. Uses socket.io to communicate between the server and the client application, and uses the Youtube API to search and play videos

https://itunes.apple.com/us/app/vynl/id1046128544?mt=8 - Currently taken off the app store to fix new youtube Terms of Service

## Setup
You must use Xcode 7 to run this app locally. Clone this repository, and open the .xcworkspace file to run this application. In the constants file, change the server_url from vynl.stream to localhost if you want to run the node app locally as well.
