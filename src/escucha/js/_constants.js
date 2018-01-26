module.exports = {
	Listens: {
		FETCH: 'listens.fetch',
		NOW_PLAYING: 'https://open.spotify.com/user/1219735559/playlist/0gnbDbdtHd4Ji4Qduv5ayy'
	},
	render_url: function(obj) {
		var stub = obj.stub;
		var types = [null, 'artist', 'album', 'track']
		var type = types[stub.split('/').length];
		var res = '/escucha/'+[type, stub].join('/');
		return res;
	}
};