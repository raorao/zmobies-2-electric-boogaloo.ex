defmodule Human do
  alias Simulator.{Being, Proximity, Action}

  @callback act([Proximity.ring], %Being{}, any()) :: Action.t | {Action.t, any()}

  defmacro __using__(_) do
    quote location: :keep do
      @spec initial_state(%Being{}) :: any()
      def initial_state(_self), do: :custom_state

      @spec listen(any(), %Being{}, %Being{}, any()) :: any()
      def listen(_message, _speaker, _self, custom_state), do: custom_state

      defoverridable [initial_state: 1, listen: 4]
    end
  end
end
