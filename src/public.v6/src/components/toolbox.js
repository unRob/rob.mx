import React, { Component } from 'react';

const debounce = (fn, time=250) => {
  let timeout = null

  return function(evt) {
    evt.persist()
    clearTimeout(timeout)
    timeout = setTimeout(() => fn(evt), time)
  }
}

const Range = ({name, value, max=100, step='0.1'}) => (
  <div className="label">
    <label htmlFor={`range-${name}`}>{name[0]}</label>
    <input
      id={`range-${name}`}
      type='range'
      name={name}
      defaultValue={value.toFixed(2)}
      min={'0.0'}
      max={max.toFixed(2)} />
  </div>
)


export default class Toolbox extends Component {

  constructor(defaults) {
    super(defaults)
    this.state = defaults
  }

  componentDidMount() {
    this.onChange = debounce(this.onChange.bind(this))
  }

  onChange (evt) {
    const { target } = evt
    this.setState({[target.name]: target.valueAsNumber})
    this.setBackground()
  }

  setBackground () {
    console.log(Object.keys(this.state).map(p => {
      const val = p === 'hue' ? this.state[p] : `${this.state[p]}%`;
      document.documentElement.style
        .setProperty(`--${p}`, val)
      return `${p}: ${val}`
    }).join("\n"))
  }


  render() {
    const ranges = Object.keys(this.state).map( p => (
      <Range key={`range-${p}`} value={this.state[p]} max={p === 'hue' ? 360.0 : 100} name={p} />
    ))

    return (
      <form onChange={(evt) => this.onChange(evt)}>
        { ranges }
      </form>
    )
  }
}