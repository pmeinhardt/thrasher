JsOsaDAS1.001.00bplist00�Vscript_ function run(argv) { 
	let itunes = Application('iTunes'); 
	//.filter(t => { return t.class() === 'fileTrack'; })

	let tracks = itunes.tracks().map(function (t) { 
		return {id: t.id(), name: t.name(), collection: t.album(), artist: t.artist()}; }); 
	
	return JSON.stringify(tracks);
}                              6jscr  ��ޭ