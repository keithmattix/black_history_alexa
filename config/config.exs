# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :black_history_alexa,
  ecto_repos: [BlackHistoryAlexa.Repo]

# Configures the endpoint
config :black_history_alexa, BlackHistoryAlexa.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UBj7AkKhm5MuF/fEdCD+UdKLqT5kfHSmBZEMAABZW2MlJDAicsByute4e6rz/b1U",
  render_errors: [view: BlackHistoryAlexa.ErrorView, accepts: ~w(json)],
  pubsub: [name: BlackHistoryAlexa.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :black_history_alexa, :config,
  data_url: "https://s3.amazonaws.com/blackhistory-calendar/data-min.json"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
