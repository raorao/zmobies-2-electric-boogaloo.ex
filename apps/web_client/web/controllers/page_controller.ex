defmodule WebClient.PageController do
  use WebClient.Web, :controller
  alias Simulator.{GameSupervisor, GameManager}

  def index(conn, _params) do
    GameSupervisor.for_json(
      x: 35,
      y: 35,
      humans: 300,
      zombies: 10,
      broadcast_fn: &broadcast/1
    )

    render conn, "index.html"
  end

  def restart(conn, _params) do
    GameManager.stop
    redirect conn, to: "/"
  end

  defp broadcast({snapshot, status}) do
    WebClient.Endpoint.broadcast("game:lobby", "update", %{snapshot: snapshot, status: status})
  end
end
