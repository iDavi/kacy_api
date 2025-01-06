import Config

# Do not print debug messages in production
config :logger, level: :info

config :kacy_api, KacyApiWeb.Endpoint,
  http: [port: 3000],
  url: [host: "kacychat.site", port: 3000],
  check_origin: ["https://kacychat.site"]

config :kacy_api, :cors_origins, ["https://kacychat.site", "https://www.kacychat.site"]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
