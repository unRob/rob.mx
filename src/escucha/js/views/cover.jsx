/** @jsx React.DOM */
var Cover = React.createClass({
    displayName: 'Cover',
    render: function () {
        if (!this.props.data) {
            return(null);
        }
        var i = this.props;
        var spotify_url = "https://open.spotify.com/"+i.type+"/"+i.url;
        var url = "/escucha/"+this.props.type+"/"+i.stub;
        var style = {
            backgroundImage: "url("+i.data+")"
        };

        return (
            <div className="cover" style={style}>
                <a href={spotify_url} className="icon-play" target="_blank">▶</a>
            </div>
        );
    }
});

module.exports = Cover;