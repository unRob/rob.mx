var ListenStore = require('../stores/ListenStore');
var AutoComplete = require('./_autocomplete.jsx');

var autocomplete_request = new API.Request('get', '/search/{{kind}}/');
var autocomplete_map = function(callback) {
	return function(res) {
		callback(res.items.map(function(item){
			return {
				value: item._id,
				label: item.name
			};
		}));
	};

};

var Filters = React.createClass({
	getInitialState: function(){
		var q = {},
			visible = [],
			enabled = [];

		var initials = this.props.initials;
		for (var prop in initials) {
			var val = initials[prop];

			if (val !== false){
				q[prop] = val;
				visible.push(prop);
				if (val !== ':disabled') {
					enabled.push(prop);
				}
			}
		}
		return {
			query: q,
			visible: visible,
			enabled: enabled
		};
	},
	componentDidMount: function() {
		ListenStore.fetch(this.state.query);
	},


	visible: function(prop) {
		return this.state.visible.indexOf(prop) >= 0;
	},
	enabled: function(prop) {
		return this.state.enabled.indexOf(prop) >= 0;
	},


	select: function(prop, value) {
		var info = this[prop](value);
		var extra = {};
		if (!this.enabled(prop)){
			extra.disabled = 'disabled';
		}

		var hidden = '';
		if (!this.visible(prop)) {
			hidden = "hidden";
		}
		var name = info.name || prop;
		var key = 'filtro-'+name;
		var id = info.id || key;

		if (info.autocomplete) {
			return(
				<AutoComplete
					key={key}
					className={"filtro "+hidden}
					name={name}
					{...extra}
					placeholder={info.placeholder}
					options={info.options}
					onChange={this._onChange} />);
		} else {
			return(
				<select
					key={key}
					id={id}
					name={name}
					className={"filtro "+hidden}
					{...extra}
					onChange={this._onChange}
					defaultValue={value}
				>
					{info.options.map(function(choice){
						return(<option key={key+'-'+choice.label} value={choice.value}>{choice.label}</option>);
					})}
				</select>
			);
		}
	},

	// --------
	// Selects
	// --------
	period: function(value){
		var plural = this.state.query.period.match(/^\d+/)[0] !== '1';
		var choices = [
			{value: 'w', label: 'semana'},
			{value: 'm', label: ['mes', 'meses']},
			{value: 'y', label: 'año'}
		].map(function(c){
			var l = c.label;
			if (typeof l === 'string') {
				c.label = plural ? l+'s' : l;
			} else {
				c.label = l[plural+0];
			}
			return c;
		});

		return {
			name: 'periodo[calificativo]',
			id: 'periodo-calificativo',
			options: choices,
		};
	},
	artist: function(){
		var self = this;
		return {
			autocomplete: true,
			placeholder: 'Todos los artistas',
			options: function(term, callback) {
				var q = self.state.query;
				var query = {genre: q.genre};
				query.q = term;
				return autocomplete_request
					.execute(query, null, {kind: 'artist'})
					.then(autocomplete_map(callback));
			}
		};
	},
	genre: function(){
		var self = this;
		return {
			autocomplete: true,
			placeholder: 'Todos los géneros',
			options: function(term, callback) {
				var q = {term: term};
				return autocomplete_request
					.execute(q, null, {kind: 'genre'})
					.then(autocomplete_map(callback));
			}
		};
	},
	album: function(){
		var self = this;
		return {
			autocomplete: true,
			placeholder: 'Todos los artistas',
			options: function(term, callback) {
				var q = self.state.query;
				var query = {artist: q.artist, genre: q.genre};
				query.q = term;
				return autocomplete_request
					.execute(query, null, {kind: 'album'})
					.then(autocomplete_map(callback));
			}
		};
	},

	qty_periodo: function(value) {
		return (
			<input
				id="periodo-cantidad"
				type="number"
				min="0"
				max="52"
				className="filtro"
				name="periodo[cantidad]"
				defaultValue={value}
				onChange={this._onChange}/>
		);
	},


	_onChange: function(evt){
		var val = evt.target.value;
		var name = evt.target.name;
		var q = {};


		if (name.match(/^periodo/)){
			if (evt.target.id == 'periodo-cantidad' && parseInt(val, 10) < 1) {
				evt.target.value = this.state.query.period.replace(/\D+/g, '')
				return false;
			}
			var exp = name === 'periodo[cantidad]' ? /(\d+)/ : /(\D+)/;
			q.period = this.state.query.period.replace(exp, val);
		} else {
			q[name] = val === '' ? null : val;
		}

		this.setState({query: q});

	},

	componentDidUpdate: function(current, prev) {
		ListenStore.fetch(this.state.query);
	},


	render: function() {
		var pq = this.state.query.period.match(/^(\d+)(\w+)$/);
		var qty = pq[1];
		var cal = pq[2];
		var periodo = {
			cantidad: qty,
			calificativo: cal
		};

		// {this.select('artist', this.state.query.artist)}
		// {this.select('genre', this.state.query.genero)}
		// {this.select('album', this.state.query.album)}
		return (
			<nav id="filtros">
				{this.qty_periodo(periodo.cantidad)}
				{this.select('period', periodo.calificativo)}

			</nav>
		);
	}
});

module.exports = Filters;