var TrackList = require('./views/tracks.jsx');
var AlbumList = require('./views/albums.jsx');
var ArtistList = require('./views/artists.jsx');

$(function(){

	var url = window.location.pathname.replace('/escucha/', '').split('/');
	var action = url.shift() || 'portada';
	var stub = url.join('/');

	var latest = new API.Request('get', 'stats/listens');
	var stubber = new API.Request('get', 'music/stub/{kind}/{stub}');
	var stats = new API.Request('get', 'stats/listens/period');

	switch (action) {
		case 'portada':
			latest.execute({period: '1m'}).then(function(res){
				React.render(React.createElement(TrackList, {data: res.tracks}), document.getElementById('tracks'));
				React.render(React.createElement(AlbumList, {data: res.albums}), document.getElementById('albums'));
				React.render(React.createElement(ArtistList, {data: res.artists}), document.getElementById('artists'));
			});
			break;
		case 'track':
		case 'album':
		case 'artist':
		case 'genre':
			var kind = action.charAt(0).toUpperCase()+action.substr(1);
			var items = stubber.execute(null, function(res){
				var data = {count: res.count};
				data[action] = res;
				React.render(React.createElement(window[kind], data), document.getElementById('item'));


				stat_queries = [
					{period: '1w', step: 'd'},
					{period: '1m', step: 'w'},
					{period: '1y', step: 'm'}
				];

				opts = {q: {}};
				opts.q[action] = res._id;

				var ids = {
					'1w': ['Última semana', 'ultima-semana'],
					'1m': ['Último mes', 'ultimo-mes'],
					'1y': ['Último año', 'ultimo-ano']
				};

				var requests = stat_queries.map(function(query){
					query = $.extend({}, opts, query);
					return stats.execute(query, function(stat){
						var info = ids[query.period];
						console.log(info[1]);
						React.render(React.createElement(Stat, {stat: stat, titulo: info[0], step: query.step}), document.getElementById(info[1]));
					});
				});

			}, {kind: action, stub: stub});


		break;
	}

});