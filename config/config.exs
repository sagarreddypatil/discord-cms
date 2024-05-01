import Config

config :nostrum,
  token: "DISCORD_BOT_TOKEN",
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
