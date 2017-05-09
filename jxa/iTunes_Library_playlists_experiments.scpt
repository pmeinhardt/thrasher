JsOsaDAS1.001.00bplist00�Vscript_�function run(argv) { 
	let itunes = Application('iTunes');
	/*
	const getiTunesLibrary = function (iTunes) {
  		const librarys = iTunes.sources.whose({kind: 'klib'});
  		const library = librarys && librarys.length ? librarys[0] :
    	iTunes.sources().find(function(source) {
      		return source.kind() === 'library'; });
  		return library;
	};
	const library = getiTunesLibrary(itunes); */
	const library = itunes.sources['Library'];

	/* const tracks = library.tracks().forEach(track => {
    if (track.class() === 'fileTrack' ) {
      	console.log(track.id(), track.name(), track.artist());
  		return {id: track.id(), name: track.name(), artist: track.artist()}
    } }); */
	
	 const playlists = library.userPlaylists().filter(playlist => {
	  return playlist.duration() > 0;
     });
	 
 	/* const pl = playlists.map(playlist => {
      console.log(playlist.id(), playlist.name());
	  return {id: playlist.id(), name: playlist.name()}
  
     });
	 
	for (let i = 0; i < playlists.length; i++) {
		let tracks  = playlists[i].tracks();
		tracks.forEach( t => {
				console.log(t.id(), t.name(), playlists[i].name()); })
	} */
	function flatten(arr) {
  		return Array.prototype.concat.apply([], arr);
	}
	
		var pl = flatten(playlists.map( p => {
		let tracks  = p.tracks();
		return tracks.map( t => {
				console.log(t.id(), t.name(), p.name());
				return {id: t.id(), name: t.name(), collection: p.name(), artist: t.artist()}
		 }) }))
	return pl[22]
}                              � jscr  ��ޭ