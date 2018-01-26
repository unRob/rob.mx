var ListenStore = require('../stores/ListenStore');
var Artist = require('./artist.jsx');

var ArtistList = React.createClass({
    getInitialState: function(){
        return {artists: []};
    },
    componentDidMount: function() {
        var self = this;
        ListenStore.addChangeListener(function(){
            self.setState({artists: ListenStore.artists()});
        });
    },
	render: function(){
		return (
			<div className='artists collection'>
				<h2>Artists</h2>
				{this.state.artists.map(function(artist){
                    return (
                        <Artist key={artist.item._id} artist={artist.item} count={artist.count} />
                    );
                })}
			</div>
		);
	}
});

module.exports = ArtistList;