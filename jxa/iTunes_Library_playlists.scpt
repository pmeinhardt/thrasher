JsOsaDAS1.001.00bplist00�Vscript_)function run(argv) { 
	let itunes = Application('iTunes');
	let library = itunes.sources['Library'];
	let playlists = library.userPlaylists().filter(playlist => {
		return playlist.duration() > 0; })
	function flatten(arr) {
  		return Array.prototype.concat.apply([], arr);
	}
	var pl = flatten(playlists.map( p => {
		let tracks  = p.tracks();
			return tracks.map( t => {
				console.log(t.id(), t.name(), p.name(), t.artist());
				return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}
		 }) }))
	return JSON.stringify(pl);
}                              ? jscr  ��ޭ