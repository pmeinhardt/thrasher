JsOsaDAS1.001.00bplist00�Vscript_�function run(argv) { 
	var app = Application('iTunes'); 
	app.stop(); 
	let pl = app.sources['Library'].subscriptionPlaylists['Piano Bar'];
	pl.play();

}                            �jscr  ��ޭ