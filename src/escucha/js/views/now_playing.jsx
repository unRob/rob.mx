
var ListenStore = require('../stores/ListenStore');
var C = require('../_constants');

var NowPlaying = React.createClass({
	getInitialState: function() {
		return {track: null, time: null, source: null, id: null};
	},
	componentDidMount: function(){
		var self = this;
		ListenStore.addChangeListener('listening', function(){
			self.setState({track: ListenStore.listening(), time: new Date()});
		});

		API.call('get', '/stats/listens/last/track').then(function(data){
			if (self.isMounted()) {
				self.setState(data);
			} else {
				console.log('not mounted', data);
			}
		});
	},
	tiempo_relativo: function(desde, hasta){
		var cuantos, tiempos;
		var diff = desde - hasta;
		var hoy = new Date(new Date(desde).setHours(0));
		var ayer = new Date(new Date(hoy).setDate(hoy.getDate()-1));
		var horas = 3600000;
		var dias = 24*horas;
		var mes = 30*dias;
		var anos = 365*dias;
		var hace = 'hace ';
		var plural = 's';

		switch (true) {
			case (hasta >= hoy):
				cuantos = diff/horas;
				tiempos = 'hora';
				break;
			case (hasta <= hoy && hasta >= ayer):
				return 'ayer';
			case (diff < 30*dias):
				cuantos = diff/dias;
				tiempos = 'día';
				break;
			case (diff > mes && diff < 1*ano):
				hace += 'mas de ';
				cuantos = diff/mes;
				plural = 'es';
				break;
			case (diff >= 1*anos):
				cuantos = diff/anos;
				tiempos = 'año';
				break;
		}

		cuantos = Math.round(cuantos);
		plural = cuantos === 1 ? '' : plural;
		return hace+cuantos+' '+tiempos+plural;
	},
	tiempo: function(date){
		var ahora = new Date();
		var mins5 = new Date(date.getTime() + 5*60*1000);
		var mins30 = new Date(date.getTime() + 30*60*1000);
		var hora1 = new Date(date.getTime() + 3600000);

		switch(true) {
			case (ahora <= mins5):
				return 'ahora';
			case (ahora <= mins30):
				return 'hace ratito';
			case (ahora <= hora1):
				return 'esta hora';
			default:
				return this.tiempo_relativo(ahora, date);
		}

	},
	render: function() {
		if (this.state.track == null) {
			return(<div></div>);
		}

		var track = this.state.track;
		var info = this.state;
		var date = new Date(info.time);
		var tiempo = this.tiempo(date);

		var urls = {
			spotify: "https://open.spotify.com/track/"+info.track.spotify_id,
			track: C.render_url(info.track),
			album: C.render_url(info.track.album),
			artist: C.render_url(info.track.artist)
		}

		return(
			<div id="now-playing">
				<h3>
					<a href={urls.spotify} target="_blank" className="icon-play">▶</a>
					<a href={urls.track} className="track">{info.track.name}</a> // <a href={urls.artist} className="artist">{info.track.artist.name}</a> // <a href={urls.album} className="album">{info.track.album.name}</a>
					<span className="fecha">{tiempo}</span>
				</h3>
			</div>
		);

	}
});

module.exports = NowPlaying;