defmodule Simulator.Character.Human.RunForTheHills do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}) :: Action.t
  def act(proximity_stream, being) do
    proximity_stream
    |> Stream.take(5)
    |> Helpers.run(being)
  end
end
