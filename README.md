# Zmobies

Zombie simulator in elixir.

### Usage

requires elixir 1.6.5. To run in console:

```sh
$ mix deps.get
$ iex -S mix
$ iex> Simulator.GameSupervisor.for_console(x: 45, y: 45, humans: 400, zombies: 10, strategy: Simulator.Character.Human.StrengthInNumbers)

```

To run in server:

```sh
$ mix phoenix.server
```

simulation should now be visible at http://localhost:4000.
