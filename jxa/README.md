# JXA snippets

Javascript for Automation 

### Compile

'''
osacompile -l JavaScript -o myCompiledScriptName.scpt myScript.js
'''

### Play

[Applescript examples](http://dougscripts.com/itunes/itinfo/info03.php) 

'''
-- by index number...

tell application "iTunes"
	play track 16 of playlist 1
end tell

-- by name...

tell application "iTunes"
	play track "Running Two" of playlist "Lola"
end tell

-- playlist by name...

tell application "iTunes"
	play playlist "Lola"
end tell

tell application "iTunes"
	play the playlist named "Lola"
end tell

-- by filename...

tell application "iTunes"
	play "Main:Sound:MP3s:Lola:Running Two.mp3"
end tell
'''

[JXA iTunes Cookbook](https://github.com/dtinth/JXA-Cookbook/wiki/iTunes)