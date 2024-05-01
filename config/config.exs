import Config

config :nostrum,
  token: "DISCORD_BOT_TOKEN",
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content
  ]
