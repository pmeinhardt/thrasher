# JXA snippets and notes

Javascript for Automation 

_Update: As of macOS Sierra, the JXA JavaScriptCore is that from Safari ~10.1, which supports not only 100% of ECMAScript 6, according to Kangax's table, but even parts of ES2017 (‘ES7’), like async functions! Go wild, if your scripts will only ever run on Sierra and above_

[JavaScript for Automation grinding to a halt](https://apple.stackexchange.com/questions/273538/javascript-for-automation-grinding-to-a-halt)_

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