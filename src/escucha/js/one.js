var objs = {
	track: require('./views/track.jsx'),
	album: require('./views/album.jsx'),
	artist: require('./views/artist.jsx')
};

var TrackList = require('./views/tracks.jsx');
var AlbumList = require('./views/albums.jsx');

// var Filters = require('./views/filters.jsx');
// var NowPlaying = require('./views/now_playing.jsx');
var ListenStore = require('./stores/ListenStore');
var C = require('./_constants');
var Stat = require('./views/stat.jsx');

var url = window.location.pathname.replace('/escucha/', '').split('/');
var action = url.shift() || 'portada';
var stub = url.join('/');

var stubber = new API.Request('get', 'music/stub/{kind}/{stub}');
var stats = new API.Request('get', 'stats/listens/period');

$(function(){
	stubber.execute(null, null, {kind: action, stub: stub}).then(function(res){
		var data = {count: res.count};
		data[action] = res;

		var item = objs[action];
		React.render(React.createElement(item, data), document.getElementById('item'));

		if (action != 'track') {
			query = {};
			React.render(React.createElement(TrackList), document.querySelector('#tracks'));
			if (action == "artist") {
				query.artist = res._id;
				React.render(React.createElement(AlbumList), document.querySelector('#albums'));
			} else {
				query.album = res._id;
			}

			console.log("query", query);

			ListenStore.fetch({q: query, period: 'all-time'});
		}

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
			console.log(query);
			return stats.execute(query).then(function(stat){
				var info = ids[query.period];
				console.log(stat);
				React.render(React.createElement(Stat, {stat: stat, titulo: info[0], step: query.step}), document.getElementById(info[1]));
			});
		});

	});
});