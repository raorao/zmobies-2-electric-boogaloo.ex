defmodule Zmobies.Being do
  @enforce_keys [:location, :type]
  defstruct [:location, :type, :uuid, :speed]
  alias Zmobies.{Location, Being}

  @type character_type :: :human | :zombie

  @spec new(character_type, x: number, y: number) :: %Being{}
  def new(type, x: x, y: y) when x != nil and y != nil do
    %__MODULE__{location: Location.at(x: x, y: y), type: type}
  end

  @spec new(character_type, %Location{}) :: %Being{}
  def new(type, location = %Location{}) do
    %__MODULE__{location: location, type: type}
  end

  @spec set_traits(%Being{}) :: %Being{uuid: String.t, speed: number}
  def set_traits(being = %Being{}) do
    %{ being | :uuid => UUID.uuid1(), :speed => generate_speed(type(being)) }
  end

  @spec x(%Being{}) :: number
  def x(%Being{location: %Location{x: x}}), do: x

  @spec y(%Being{}) :: number
  def y(%Being{location: %Location{y: y}}), do: y

  @spec type(%Being{}) :: character_type
  def type(%Being{type: type}), do: type

  @spec turn(%Being{}) :: {:error, :already_turned} | {:ok, %Being{}}
  def turn(%Being{type: :zombie}), do: {:error, :already_turned}

  def turn(being = %Being{type: :human}) do
    {:ok, %{being | type: :zombie, speed: generate_speed(:zombie) } }
  end

  @spec generate_health() :: number
  defp generate_health do
    generate_stat(50)
  end

  @spec generate_speed(%Being{}) :: number
  defp generate_speed(:human) do
    generate_stat(60)
  end

  defp generate_speed(:zombie) do
    generate_stat(30)
  end

  @spec generate_stat(number) :: number
  defp generate_stat(average) do
    average + (:rand.uniform(50) - 25)
  end

  def to_s(%Being{type: type}, colors: colors) do
    if colors do
      case type do
        :zombie -> "#{IO.ANSI.red()}Z"
        :human  -> "#{IO.ANSI.cyan()}H"
      end
    else
      case type do
        :zombie -> "Z"
        :human  -> "H"
      end
    end
  end
end
