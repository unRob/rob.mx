var ListenStore = require('../stores/ListenStore');
var Track = require('./track.jsx');

var TrackList = React.createClass({
	getInitialState: function(){
		return {tracks: []};
	},
	componentDidMount: function() {
		var self = this;
		ListenStore.addChangeListener(function(){
			self.setState({tracks: ListenStore.tracks()});
		});
	},
	render: function(){
		var tracks = this.state.tracks.map(function(track){
			return (
				<Track key={track.item._id} track={track.item} count={track.count} />
			);
		});
		return (
			<div className='tracks collection'>
				<h2>Tracks</h2>
				{tracks}
			</div>
		);
	}
});

module.exports = TrackList;