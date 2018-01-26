var debounce = require('debounce');
var trim = require('trim');

var AutoComplete = React.createClass({

	getInitialState: function(){

		var options = [];
		if (typeof this.props.options === 'function' ) {
			this.filter = this.props.options;
		} else {
			options = this.props.options;
			this.filter = this.default_filter;
		}

		return {
			options: options,
			value: null,
			autocompleting: '',
			selecting: false
		};
	},

	render: function() {
		var type = this.props.type || 'text';
		var input = this.props.input || {};
		input.placeholder = this.props.placeholder;

		return (
			<div className="autocomplete">
				<input type={type} {...input} onKeyDown={this.changed} />
				<input type="hidden" name={this.props.name} value={this.state.value} />
				<ul>
					{this.state.options.map(function(option){
						return (<ACOption {...option} onMouseOver={this.selected}/>);
					})}
				</ul>
			</div>
		);
	},


	default_filter: function(val, then){
		var opts = this.props.data.slice(0);
		var exp = RegExp.new(val, 'iu');
		return opts.filter(function(option) {
			return exp.test(option.value);
		});

	},

	select: function(option) {
		this.setState({value: option.value});
	},

	changed: function(evt){
		var val = trim(evt.target.value);
		if (val != autocompleting) {
			var self = this;
			var filter = function() {
				self.filter(val, function(opts){
					self.setState({options: opts});
				});
			};
			this.autocompleting = val;
			debounce(filter, 700);
		}
	}

});

var ACOption = React.createClass({
	getInitialState: function() {
	    return {
	          value: this.props.value,
	          label: this.props.name,
	          selected: selected
	    };
	},

	render: function() {
		var className = "autocomplete-option";
		if (this.state.selected) {
			className += ' autocomplete-option-selected';
		}
		return (<li className={className}>{label}</li>);
	}
});

module.exports = AutoComplete;