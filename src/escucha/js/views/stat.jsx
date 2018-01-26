/** @jsx React.DOM */
var BarChart = require('react-d3').BarChart;

var Stat = React.createClass({
    displayName: 'Stat',
    getInitialState: function(){
        var items = [];

        this.props.stat.items.forEach(function(i){
            items.push({label: i._id.split('-').pop(), value: i.count});
        });

        return {items: items, since: this.props.stat.since, until: this.props.stat.until};
    },
    render: function () {
        var width = $('#item').width();
        return (
            <div className="stat">
                <h2>{this.props.stat.count}/{this.props.titulo}</h2>
                <BarChart data={this.state.items} fill={'#FF005B'} width={width} height={200} />
            </div>
        )
    }
});

module.exports = Stat;