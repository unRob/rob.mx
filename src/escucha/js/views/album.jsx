var Cover = require('./cover.jsx');
var C = require('../_constants');
var Album = React.createClass({
	render: function () {
		var i = this.props.album;
		var count = null;
		if (this.props.count){
			count = <h4 className="count big-count">{this.props.count} plays</h4>;
		}
		return (
			<article className="album item clearfix">
				<Cover type="album" stub={i.stub} data={i.cover} url={i.spotify_id} />
				<h3><a href={C.render_url(i)} className="album item-name">{i.name}</a> // <a href={C.render_url(i.artist)} className="artist">{i.artist.name}</a></h3>
				{count}
			</article>
		);
	}
});

module.exports = Album;