defmodule WebClient.PageController do
  use WebClient.Web, :controller
  alias Simulator.{GameSupervisor, GameManager}

  def index(conn, _params) do
    case start do
      {:error, {:already_started, _}} ->
        GameManager.stop
        start
      {:ok, _} -> nil
    end

    render conn, "index.html"
  end

  defp broadcast({snapshot, _status}) do
    WebClient.Endpoint.broadcast("game:lobby", "update", %{snapshot: snapshot})
  end

  defp start do
    GameSupervisor.for_json(x: 20, y: 20, humans: 3, zombies: 1, broadcast_fn: &broadcast/1)
  end
end
