var Cover = require('./cover.jsx');
var C = require('../_constants');
var Artist = React.createClass({
    render: function () {
    	var i = this.props.artist;
    	var count = null;
    	if (this.props.count){
            count = <h4 className="count big-count">{this.props.count} plays</h4>
        }
        return (
            <article className="artists item clearfix">
            	<Cover type="artist" stub={i.stub} data={i.cover} url={i.spotify_id} />
            	<h3><a className="artist item-name" href={C.render_url(i)}>{i.name}</a></h3>
            	{count}
            </article>
        );
    }
});

module.exports = Artist;