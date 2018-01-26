var Dispatcher = require('../dispatcher/EscuchaDispatcher');
var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var C = require('../_constants.js');

var CHANGE_EVENT = 'change';
var _data = null;
var _query = {
	period: null,
	genre: null,
	artist: null,
};

var fetcher = new API.Request('get', 'stats/listens');
var stream = new API.Stream('subscribe', ['listens']);

stream.on('listens', 'track', function(evt){
	_data.listening = evt.data;
	ListenStore.emitChange('listening');
});

var ListenStore = assign({}, EventEmitter.prototype, {
	listening: function() {
		return _data.listening;
	},
	tracks: function(){
		return _data.tracks;
	},
	albums: function(){
		return _data.albums;
	},
	artists: function(){
		return _data.artists;
	},
	plays: function(){
		return _data.plays;
	},
	query: function(){
		return _query;
	},
	fetch: function(query){
		_query = query;
		var self = this;
		// console.log("Fetching", query);
		fetcher.execute(query).then(function(res){
			_data = res;
			self.emitChange();
		});
	},
	emitChange: function(evt) {
		evt = evt || CHANGE_EVENT;
		this.emit(evt);
	},
	addChangeListener: function(evt, callback) {
		if (!callback) {
			callback = evt;
			evt = CHANGE_EVENT;
		}
		this.on(evt, callback);
	},
	removeChangeListener: function(evt, callback) {
		if (!callback) {
			callback = evt;
			evt = CHANGE_EVENT;
		}
		this.removeListener(evt, callback);
	}
});

Dispatcher.register(function(action){
	switch(action.actionType) {
		case C.Listens.FETCH:
			// ListenStore
		break;
	}
});

module.exports = ListenStore;