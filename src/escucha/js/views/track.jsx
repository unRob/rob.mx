var Cover = require('./cover.jsx');
var C = require('../_constants');

var Track = React.createClass({
	render: function() {
		var i = this.props.track;
		var cover = i.album.cover || i.artist.cover;

		var count = null;
		if (this.props.count){
			count = <h4 className="count big-count">{this.props.count} plays</h4>
		}
		return (
			<article className="track item clearfix">
				<Cover type="track" stub={i.stub} data={cover} url={i.spotify_id} />
				<h3>
					<a href={C.render_url(i)} className="item-name track">{i.name}</a> // <a href={C.render_url(i.artist)} className="artist">{i.artist.name}</a>
				</h3>
				<h4 className="collapsed">
					<a href={C.render_url(i.album)} className="album">{i.album.name}</a>
				</h4>
				{count}
			</article>
		);
	}
});

module.exports = Track;