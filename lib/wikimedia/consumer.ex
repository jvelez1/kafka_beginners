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
  use GenServer, restart: :transient
  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def start_link(_args \\ []) do
    KafkaEx.GenConsumer.start_link(
      __MODULE__,
      "wikimedia_group",
      "wikimedia.recent_change",
      0,
      auto_offset_reset: :latest,
      commit_interval: 5000, commit_threshold: 100
    )
  end

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      message
      |> decode()
      |> then(fn message -> Logger.debug("proccessed #{message["id"]} #{DateTime.utc_now}") end)
    end

    {:async_commit, state}
  end

  #
  # Previosly you should start avro =>  {:ok, pid} = Avrora.start_link()
  # register_schema_by_name => {:ok, schema} = Avrora.Utils.Registrar.register_schema_by_name("body.Wikimedia", force: true)
  #
  defp decode(message) do
    case Avrora.decode(message, schema_name: "body.Wikimedia") do
      {:ok, decoded} -> decoded
      _ -> Logger.error("ups!!")
    end
  end
end
