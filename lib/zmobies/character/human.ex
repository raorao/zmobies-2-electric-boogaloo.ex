defmodule Zombies.Character.Human do
  alias Zmobies.{Being, Movement, Location, Character.Helpers}

  @spec act([Movement.ring], %Being{}) :: Movement.t
  def act(proximity_stream, being) do
    proximity_stream
    |> Stream.take(5)
    |> Helpers.run(being)
  end
end
