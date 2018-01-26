var TrackList = require('./views/tracks.jsx');
var AlbumList = require('./views/albums.jsx');
var ArtistList = require('./views/artists.jsx');
var Filters = require('./views/filters.jsx');
var NowPlaying = require('./views/now_playing.jsx');
var ListenStore = require('./stores/ListenStore');
var C = require('./_constants');

$(function(){
	var q = {period: '1m', artists: null, albums: null, genres: null};
	React.render(React.createElement(TrackList), document.querySelector('#tracks'));
	React.render(React.createElement(AlbumList), document.querySelector('#albums'));
	React.render(React.createElement(ArtistList), document.querySelector('#artists'));

	React.render(React.createElement(Filters,   {initials: q}), document.querySelector('#filtros'));
	React.render(React.createElement(NowPlaying), document.querySelector('#now-playing-container'));
});