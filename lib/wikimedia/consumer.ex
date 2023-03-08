defmodule Wikimedia.Consumer do
  @moduledoc """
  How to run it:

  {:ok, pid} = KafkaEx.GenConsumer.start_link(
    Wikimedia.Consumer,
    "wikimedia_group",
    "wikimedia.recent_change",
    0,
    auto_offset_reset: :latest,
    commit_interval: 5000, commit_threshold: 100
    )
  """
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      payload = Jason.decode!(message)
      %{"id" => id} = payload
      Logger.debug("proccessed #{id} #{DateTime.utc_now}")
    end

    {:async_commit, state}
  end
end
