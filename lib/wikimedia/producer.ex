defmodule Wikimedia.Producer do
  alias KafkaEx.Protocol.Produce.{Message, Request}
  require Logger

  @doc """
  Simple producer receives a topic and a message and send the message to given topic.
  As this is a simple producer, it will always send the message to Partition:0
  """
  @spec send(String.t(), String.t()) :: :ok | :error | any()
  def send(topic, message) do
    Logger.info("sending message: #{message} to: #{topic}")

    case KafkaEx.produce(topic, 0, message) do
      :ok -> Logger.info("message sent!")
      error -> Logger.error("error: #{error}")
    end
  end
end
