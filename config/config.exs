import Config

import Logger

config :nostrum,
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content
  ]

config :tailwind, version: "3.2.4", default: [
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
  cd: Path.expand("../assets", __DIR__)
]

if File.exists?("config/secret.exs"), do: import_config("secret.exs")
