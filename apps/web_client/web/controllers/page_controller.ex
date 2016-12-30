defmodule WebClient.PageController do
  use WebClient.Web, :controller
  alias Simulator.{GameSupervisor, GameManager}

  def index(conn, _params) do
    render conn, "index.html"
  end

  def start(conn, _params) do
    case start_simulation do
      {:error, {:already_started, _}} ->
        GameManager.stop
        start_simulation
      {:ok, _} -> nil
    end

    redirect conn, to: "/"
  end

  defp broadcast({snapshot, status}) do
    WebClient.Endpoint.broadcast("game:lobby", "update", %{snapshot: snapshot, status: status})
  end

  defp start_simulation do
    GameSupervisor.for_json(
      x: 35,
      y: 35,
      humans: 300,
      zombies: 10,
      broadcast_fn: &broadcast/1
    )
  end
end
