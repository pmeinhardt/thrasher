JsOsaDAS1.001.00bplist00�Vscript_;function run(argv) { 
	let app = Application('iTunes');
	// let p = app.sources['Library'].userPlaylists[12];
	let n = app.sources['Library'].userPlaylists.length;

	
	/* 
	let tracks = p.tracks();
	return JSON.stringify(tracks.map(function (t) { return {id: t.id(), class: t.class(), name: t.name(), album: t.album(), artist: t.artist()}; })); 
	*/
	// return app.sources['Library'].userPlaylists.length;
	
	/*
	var playlists = []
	
	for (let i = 0; i < n; i++) {
		let p = app.sources['Library'].userPlaylists[i];
		playlists.push(p.name())
	}
	
	return playlists
	*/
}                              Q jscr  ��ޭ