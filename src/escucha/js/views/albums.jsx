var ListenStore = require('../stores/ListenStore');
var Album = require('./album.jsx');

var AlbumList = React.createClass({
	getInitialState: function(){
		return {albums: []};
	},
	componentDidMount: function() {
		var self = this;
		ListenStore.addChangeListener(function(){
			self.setState({albums: ListenStore.albums()});
		});
	},
	render: function(){
		var albums = this.state.albums.map(function(album){
			return (
				<Album key={album.item._id} album={album.item} count={album.count} />
			);
		});
		return (
			<div className='albums collection'>
				<h2>Albums</h2>
				{albums}
			</div>
		);
	}
});

module.exports = AlbumList;