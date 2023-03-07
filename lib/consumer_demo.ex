defmodule KafkaBeginner.ConsumerDemo do
  @moduledoc """
  How to run it:

  iex> KafkaEx.GenConsumer.start_link(KafkaBeginner.ConsumerDemo, "kafka_ex", "elixir_demo", 0)
  """
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      Logger.debug(fn -> "message: " <> inspect(message) end)
    end
    {:async_commit, state}
  end
end
