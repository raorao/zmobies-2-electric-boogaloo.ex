defmodule WebClient.PageController do
  use WebClient.Web, :controller
  alias Simulator.{GameSupervisor, Game}

  def index(conn, _params) do
    render conn, "index.html"
  end

  def simulation(conn, _params) do
    render conn, "simulation.html"
  end

  def start(conn, %{"strategy" => strategy}) do
    case start_simulation(strategy) do
      {:error, {:already_started, _}} ->
        Game.stop
        start_simulation(strategy)
      {:ok, _} -> nil
    end

    redirect conn, to: "/simulation"
  end

  defp broadcast({snapshot, status}) do
    WebClient.Endpoint.broadcast(
      "game:lobby",
      "update",
      %{snapshot: snapshot, status: status}
    )
  end

  defp start_simulation(strategy_string) do
    strategy = case strategy_string do
      "run_for_the_hills" -> Simulator.Character.Human.RunForTheHills
      "this_is_sparta" -> Simulator.Character.Human.ThisIsSparta
      "fight_or_flight" -> Simulator.Character.Human.FightOrFlight
      "strength_in_numbers" -> Simulator.Character.Human.StrengthInNumbers
      "dont_look_back" -> Simulator.Character.Human.DontLookBack
      "chatter" -> Simulator.Character.Human.Chatter
    end

    GameSupervisor.for_json(
      x: 35,
      y: 35,
      humans: 300,
      zombies: 10,
      broadcast_fn: &broadcast/1,
      strategy: strategy
    )
  end
end
