defmodule WebClient.PageController do
  use WebClient.Web, :controller
  alias Simulator.{GameSupervisor, GameManager}

  def index(conn, _params) do
    case start do
      {:ok, _} -> nil
      {:error, {:already_started, _}} ->
        GameManager.stop
        start
    end

    render conn, "index.html"
  end

  defp start do
    GameSupervisor.for_json(
      x: 35,
      y: 35,
      humans: 300,
      zombies: 10,
      broadcast_fn: &broadcast/1
    )
  end

  defp broadcast({snapshot, _status}) do
    WebClient.Endpoint.broadcast("game:lobby", "update", %{snapshot: snapshot})
  end
end
