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

let bus = new Bacon.Bus()

channel.on("update", function(payload) {
  bus.push(payload)
})

let stream = bus.delay(200).bufferingThrottle(20)

class Container extends React.Component {

  constructor() {
    super();
    this.state = {beings: [], status: "ongoing"};
  }

  componentDidMount() {
    stream.onValue(function(payload) {
      this.setState({beings: payload.snapshot, status: payload.status})
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
              top: (being.y * (100/37)) + "%",
              left: (being.x * (100/37)) + "%",
              backgroundColor: being.color,
              opacity: (being.type == "zombie" ? (being.health / 30) + 0.1 : 1)
            }
        }
      )
    })
  }

  maybeRenderStatus() {
    let status = this.state.status
    let beings = this.state.beings

    if (beings.length == 0) {
      return React.createElement('div', {className: "image-container"},
        React.createElement('img', {key: "loader", src: "images/loader.gif"}),
        React.createElement('h2', {key: "status"},
          React.createElement('a', {href: "/"}, "Restart.")
        )
      )
    } else if (status == "ongoing" || status == "empty") {
      return null
    } else {
      return React.createElement('h2', {key: "status", className: status},
        "The " + status + "s have won. ",
        React.createElement('a', {href: "/"}, "Restart.")
      )
    }
  }

  render() {
    return (
      React.createElement('div', {},
        React.createElement('div', {className: "custom-container", key: "rao"},
          this.renderChildren()
        ),
        this.maybeRenderStatus()
      )
    );
  }
}

if (document.querySelector('anchor')) {
  ReactDOM.render(
    React.createElement(Container, {}, []),
    document.querySelector('anchor')
  );


  console.log("attempting to join.")
  channel.join()
    .receive("error", resp => { console.log("Unable to join", resp) })
    .receive("ok", resp => { console.log("joined", resp) })

}


