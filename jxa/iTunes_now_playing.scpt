JsOsaDAS1.001.00bplist00�Vscript_�function run(argv) { 
	// https://github.com/dtinth/JXA-Cookbook/wiki/iTunes
	let track = Application('iTunes').currentTrack
	// let track = Application('iTunes').currentTrack()
	let info = track.name() + " - " + track.artist() + " - " + track.album() + " - " + track.duration();
	let app = Application.currentApplication();
	app.includeStandardAdditions = true;
	app.displayNotification(info, { withTitle: 'Now playing' });
}                              �jscr  ��ޭ