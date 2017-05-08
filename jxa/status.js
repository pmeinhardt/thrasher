function run(argv) { 
var app = Application('iTunes'); 
var playerState = app.playerState();
try { 	var track = app.currentTrack();
	return JSON.stringify({state: playerState, track: {name: track.name(), album: track.album(), artist: track.artist()}});} 
catch(e) { 
	return JSON.stringify({state: playerState, track: {name: "", album: "", artist: ""} }) 
	} 
	
}