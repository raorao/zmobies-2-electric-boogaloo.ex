// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

let channel = socket.channel("game:lobby", {})

function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}

function randomInt() {
  return Math.ceil(Math.random() * 100)
}


function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

function getRandomType() {
  return Math.random() > 0.5 ? "zombie" : "human"
}

class Container extends React.Component {

  constructor() {
    super();
    this.state = {beings: []};
  }

  componentDidMount() {
    channel.on("update", function(payload) {
      this.setState({beings: payload.snapshot})
    }.bind(this))
  }

  renderChildren() {
    return this.state.beings.map(function(being) {
      return React.createElement("div",
        {
          key: being.uuid,
          className: "being " + being.type,
          style:
            {
              top: (being.y * 20) + "px",
              left: (being.x * 20) + "px",
              backgroundColor: being.color,
            }
        }
      )
    })
  }

  render() {
    return (
      React.createElement('div', {className: "container"},
        React.createElement(FlipMove, {duration: 200},
          this.renderChildren()
        )
      )
    );
  }
}

ReactDOM.render(
  React.createElement(Container, {}, []),
  document.querySelector('anchor')
);

channel.join()
  .receive("error", resp => { console.log("Unable to join", resp) })
