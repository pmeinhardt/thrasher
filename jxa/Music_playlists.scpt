JsOsaDAS1.001.00bplist00�Vscript_function run(argv) { 
	let app = Application('iTunes');
	let lib = app.playlists.byName('Library');
	let n = app.sources['Library'].subscriptionPlaylists.length;	
	var tracks = [];
	/* for (let i = 0; i < n; i++) {
		let p = app.sources['Library'].subscriptionPlaylists[i];
		tracks = tracks.concat(p.tracks().map(function (t) { return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}; }));
	} */
	let m = app.sources['Library'].userPlaylists.length;
	for (let i = 0; i < m; i++) {
		let p = app.sources['Library'].userPlaylists[i];
		tracks = tracks.concat(p.tracks().map(function (t) { return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}; }));
	}
	return JSON.stringify(tracks);
	/* for (let i = 0; i < n; i++) {
		let p = app.sources['Library'].subscriptionPlaylists[i];
		let tracks = p.tracks();
		songs.push(tracks.map(function (t) { return {id: t.id(), name: t.name(), album: t.album(), artist: t.artist(), playlist: p.name()}}))
		
	}
	
	return JSON.stringify(songs) */

}                              jscr  ��ޭ