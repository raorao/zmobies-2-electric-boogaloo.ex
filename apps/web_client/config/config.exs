# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :web_client, WebClient.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UedeZUNNqSYRDqh7NGse7mvo2OqBuYeyc7VWkPGOtl4VeHV7zcsav1GVwBXoFQaa",
  render_errors: [view: WebClient.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WebClient.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
