defmodule Simulator.Character.Human.RunForTheHills do
  use Human

  alias Simulator.{Character.Helpers}

  def act(proximity_stream, self, _) do
    proximity_stream
    |> Stream.take(6)
    |> Helpers.run_from_nearest_being(self)
  end
end
