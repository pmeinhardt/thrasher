JsOsaDAS1.001.00bplist00�Vscript_function run(argv) { 
	let itunes = Application('iTunes'); 
	let tracks = itunes.tracks().filter(t => { return t.class() === 'fileTrack'; }).map(function (t) { 
			return {id: t.id(), name: t.name(), collection: t.album(), artist: t.artist()}; }); 
	
	return JSON.stringify(tracks);
	}
                              4jscr  ��ޭ