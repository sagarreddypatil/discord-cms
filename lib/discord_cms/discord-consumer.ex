defmodule DiscordConsumer do
  use Nostrum.Consumer

  # alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, _msg, _ws_state}) do
    # print message content to console
    # todo: invalidate content cache
  end

  def handle_event({:MESSAGE_UPDATE, _msg, _ws_state}) do
    # print message content to console
    # todo: invalidate content cache
  end

  def handle_event({:MESSAGE_DELETE, _msg, _ws_state}) do
    # print message content to console
    # todo: invalidate content cache
  end
end
