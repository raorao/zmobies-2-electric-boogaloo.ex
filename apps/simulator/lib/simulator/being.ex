defmodule Simulator.Being do
  @enforce_keys [:location, :type]
  defstruct [:location, :type, :uuid, :speed, :health]
  alias Simulator.{Location, Being}

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
    %{ being | :uuid => UUID.uuid1(), :speed => generate_speed(type(being)), :health => generate_health }
  end

  @spec x(%Being{}) :: number
  def x(%Being{location: %Location{x: x}}), do: x

  @spec y(%Being{}) :: number
  def y(%Being{location: %Location{y: y}}), do: y

  @spec type(%Being{}) :: character_type
  def type(%Being{type: type}), do: type

  @spec turn(%Being{}) :: {:error, :already_turned} | %Being{}
  def turn(%Being{type: :zombie}), do: {:error, :already_turned}

  def turn(being = %Being{type: :human}) do
    %{being | type: :zombie, speed: generate_speed(:zombie) }
  end

  @spec hurt(%Being{}, %Being{}) :: %Being{}
  def hurt(attacker, victim), do: %{ victim | health: victim.health - div(attacker.health, 2)}

  @spec feed(%Being{}) :: %Being{}
  def feed(being = %Being{health: health}), do: %{ being | health: health + 10 }

  @spec age(%Being{}) :: %Being{}
  def age(being = %Being{type: :zombie, health: health}), do: %{ being | health: health - 1 }
  def age(being = %Being{type: :human}), do: being

  @spec generate_health() :: number
  defp generate_health do
    generate_stat(50)
  end

  @spec generate_speed(character_type) :: number
  defp generate_speed(:human) do
    generate_stat(60)
  end

  defp generate_speed(:zombie) do
    generate_stat(30)
  end

  @spec generate_stat(number) :: number
  defp generate_stat(average) do
    stat = round(average + (15 * Statistics.Distributions.T.rand(30)))

    cond do
      stat <= 0 || stat >= 100 -> generate_stat(average)
      true -> stat
    end
  end

  @spec attack(%Being{}, %Being{}) :: {:error, :allies} | {:attacked, %Being{}} | {:attacked, %Being{}, :feed}
  def attack(%Being{type: :human}, %Being{type: :human}), do: {:error, :allies}

  def attack(%Being{type: :zombie}, victim = %Being{type: :human}) do
    {:attacked, Being.turn(victim), :feed}
  end

  def attack(attacker = %Being{type: :zombie}, victim = %Being{type: :zombie}) do
    {:attacked, Being.hurt(attacker, victim), :feed}
  end

  def attack(attacker = %Being{type: :human}, victim = %Being{type: :zombie}) do
    {:attacked, Being.hurt(attacker, victim)}
  end

  def as_json(%Being{location: %Location{x: x, y: y}, health: health, uuid: uuid, type: type}) do
    type_string = case type do
      :zombie -> "zombie"
      :human  -> "human"
    end

    [x, y, type_string, uuid, health]
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
