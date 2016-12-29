defmodule WebClient.GameChannel do
  use Phoenix.Channel

  def join("game:lobby", _message, socket) do
    Simulator.GameSupervisor.for_json(x: 45, y: 45, humans: 400, zombies: 10, broadcast_fn: &IO.inspect/1)
    {:ok, socket}
  end
  def join("game:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
