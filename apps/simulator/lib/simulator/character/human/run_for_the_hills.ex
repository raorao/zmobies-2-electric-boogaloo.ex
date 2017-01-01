defmodule Simulator.Character.Human.RunForTheHills do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}, any()) :: Action.t | {Action.t, any()}
  def act(proximity_stream, self, _) do
    proximity_stream
    |> Stream.take(6)
    |> Helpers.run_from_nearest_being(self)
  end
end
