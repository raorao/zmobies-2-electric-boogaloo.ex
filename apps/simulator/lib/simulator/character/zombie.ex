defmodule Simulator.Character.Zombie do
  alias Simulator.{Being, Proximity, Character.Helpers, Action}

  @spec act([Proximity.ring], %Being{}, any()) :: Action.t | {Action.t, any()}
  def act(proximity_stream, self, _) do
    adjacent_enemy = proximity_stream
    |> Stream.take(1)
    |> Helpers.nearest_enemy(self)

    case adjacent_enemy do
      {enemy_location, _enemy} -> {:attack, enemy_location}
      nil ->
        proximity_stream
        |> Stream.drop(1)
        |> Stream.take(3)
        |> Helpers.chase_nearest_being(self)
    end
  end

  @spec initial_state(%Being{}) :: any()
  def initial_state(_self), do: :custom_state

  @spec listen(any(), %Being{}, %Being{}, any()) :: any()
  def listen(_message, _speaker, _self, custom_state), do: custom_state
end
