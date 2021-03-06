# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :ivan_bloggo, IvanBloggo.Endpoint,
  url: [host: "localhost"],
  root: Path.expand("..", __DIR__),
  secret_key_base: "3B2D7BitiZXRpbXG89Sk76XLZ2holZHxDFjXE0wtqVhO7HOjETHaG0Nf9r9uCBIj",
  debug_errors: false,
  pubsub: [name: IvanBloggo.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Enable the use of Haml for templates
config :phoenix, :template_engines, haml: PhoenixHaml.Engine
