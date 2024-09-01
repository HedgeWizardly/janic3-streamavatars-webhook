# streamavatars-webhook

Client lua script to connect to janic3 reward queue for streamavatars.

NOTE: This script is ONLY compatible with the janic3 chatbot. If you would like to take this script and change the endpoint and other parameters to serve your own purposes as a functional websocket script, be my guest! Please reach out to me via email - hedgewizardly@gmail.com, or on Discord, Instagram, Bluesky etc with the same username (HedgeWizardly) if this is something you would like to configure with Janic3, as I haven't fully fleshed out and set this up beyond something for one specific streamer.

You will need to follow the instructions in the StreamAvatars docs for adding a new script: https://docs.streamavatars.com/lua-scripting-api/quick-start

My script is called "janic3" for the purposes of following that tutorial, but you can name it anything. (the example in the guide calls it "my_new_script".

When setting up the command in StreamAvatars (again, following the guide linked above), you will need to set the "Run As" option to "On Connect" rather than "On Command Call".

When StreamAvatars connects, it will immediately run the script which will attempt to open a websocket connection with Janic3's websocket endpoint.

Clicking "Create Script" will create a new folder with a .lua file and a _settings.json file in it. The .lua file will create a very basic hello world script. Either open this file in a text editor and replace all the code in there with the code in my janic3.lua file, or replace the entire file (but make sure the name matches*)

*if you created a script called my_new_script.lua, then download my janic3.lua script and rename it to my_new_script.lua, move it to that folder, and overwrite the existing one. Or if you created it with the name "janic3" then half your work is done for you- just replace it with mine.

**You will also NEED to edit the script (again, in any text editor will do) and change the text "YOURIDHERE" near the top of the script to your Twitch ID, which is a numerical value that looks something like "49234872". **
If you don't know what your ID is, and most people outside of developers don't, you can use this tool to find it out: https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/

If you set all that up correctly, this script should run every time you open StreamAvatars now, as long as that "command" (it's not a chat command, it's just referred to as a command") is enabled in SA.
