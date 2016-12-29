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


class Container extends React.Component {

  constructor() {
    super();
    this.state = {beings: [], status: "ongoing"};
  }

  componentDidMount() {
    channel.on("update", function(payload) {
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
              top: (being.y * 20) + "px",
              left: (being.x * 20) + "px",
              backgroundColor: being.color,
            }
        }
      )
    })
  }

  maybeRenderStatus() {
    let status = this.state.status
    let beings = this.state.beings

    if (beings.length == 0) {
      return React.createElement('h2', {key: "status", className: status},
        React.createElement('a', {href: "/restart"}, "Restart.")
      )
    } else if (status == "ongoing" || status == "empty") {
      return null
    } else {
      return React.createElement('h2', {key: "status", className: status},
        "The " + status + "s have won. ",
        React.createElement('a', {href: "/restart"}, "Restart.")
      )
    }
  }

  render() {
    return (
      React.createElement('div', {},
        React.createElement('div', {className: "container", key: "rao"},
          this.renderChildren()
        ),
        this.maybeRenderStatus()
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
