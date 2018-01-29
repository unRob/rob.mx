import React, { Component } from 'react';
import './App.css';
import Toolbox from './components/toolbox';


class App extends Component {

  componentWillMount() {
    const style = getComputedStyle(document.body);
    const toolboxState = {};
    ['spread', 'hue', 'saturation', 'luminance'].forEach(p => {
      toolboxState[p] = parseFloat(style.getPropertyValue(`--${p}`))
    });
    this.setState({ toolboxState })
  }

  render() {
    return (
      <div className="App">
        <header>
          <div className="cara" />
          <h1>Roberto Hidalgo</h1>

          <Toolbox {...this.state.toolboxState} />
        </header>

        <main>
          <div id="intro">
            <p className="header-byline">dice alguna pendejada cagada tktk</p>
          </div>

          <div className="internal" id="escucha">
            <h2>escucha</h2>

            <p>Esta semana he escuchado mucho <strong>Luis Bonfá</strong></p>
          </div>
        </main>
      </div>
    );
  }
}

export default App;
