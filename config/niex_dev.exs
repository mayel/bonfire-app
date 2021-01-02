import Config

config :phoenix, :json_library, Poison

signing_salt = System.get_env("SIGNING_SALT", "CqAoopA2")
secret_key_base = System.get_env("SECRET_KEY_BASE", "g7K250qlSxhNDt5qnV6f4HFnyoD7fGUuZ8tbBF69aJCOvUIF8P0U7wnnzTqklK10")

# Configures the endpoint
config :niex, NiexWeb.Endpoint,
  pubsub_server: Niex.PubSub,
  live_view: [signing_salt: signing_salt],
  secret_key_base: secret_key_base,
  server: true,
  debug_errors: true,
  check_origin: false,
  http: [port: 3333],
  debug_errors: true,
  check_origin: false
