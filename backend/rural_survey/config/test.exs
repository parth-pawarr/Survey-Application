import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rural_survey, RuralSurveyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "uh7Njv5jL02uYKQLyC8FVwKpvcrYl4Y4nRuKZuEGPXqeYs+PvIeSjvguEsOrHQXL",
  server: false

# In test we don't send emails
config :rural_survey, RuralSurvey.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true

# Configure MongoDB for test environment
config :rural_survey, :mongo,
  name: :mongo,
  url: "mongodb://localhost:27017/rural_survey_test",
  pool_size: 5
