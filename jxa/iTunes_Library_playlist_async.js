// macOS Sierra uses a JavaScriptCore analagous to that in Safari 10.1. This supports all of
// ECMAScript 2015 (“ES6”), and even much of ECMAScript 2016! For instance, try `async` 

async function playlistsTracks(playlists){
		function flatten(arr) {
  			return Array.prototype.concat.apply([], arr);
		}	
		var pl = await flatten(playlists.map( p => {
			let tracks  = p.tracks();
			return tracks.map( t => {
				// console.log(t.id(), t.name(), p.name());
				return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}
		 }) }))
   		return pl; 
}
	
function run(argv) {
	const itunes = Application('iTunes');
	const library = itunes.sources['Library'];
	const playlists = library.userPlaylists().filter(playlist => {
		return playlist.duration() > 0; });
  	var t = playlistsTracks(playlists);

  	if (!(t instanceof Promise)) throw "No ES2016 support."

  	return t
}
