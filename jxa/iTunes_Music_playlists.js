function run(argv) { 
	let app = Application('iTunes');
	let lib = app.playlists.byName('Library');
	let n = app.sources['Library'].subscriptionPlaylists.length;	
	var tracks = [];
	for (let i = 0; i < n; i++) {
		let p = app.sources['Library'].subscriptionPlaylists[i];
		tracks = tracks.concat(p.tracks().map(function (t) { return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}; }));
	}
	return JSON.stringify(tracks); 

}