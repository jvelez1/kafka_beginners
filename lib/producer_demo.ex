defmodule KafkaBeginner.ProducerDemo do
  alias KafkaEx.Protocol.Produce.{Message, Request}
  require Logger

  @doc """
  Simple producer receives a topic and a message and send the message to given topic.
  As this is a simple producer, it will always send the message to Partition:0
  """
  @spec produce(String.t(), String.t()) :: :ok | :error | any()
  def produce(topic, message) do
    Logger.info("sending message: #{message} to: #{topic}")

    case KafkaEx.produce(topic, 0, message) do
      :ok -> Logger.info("message sent!")
      error -> Logger.error("error: #{error}")
    end
  end

  @doc """
  Producer that receives a topic, key and a message and send the message to a given topic.
  As this receive a key, kafka will send the message always to the same partition by key.
  """
  @spec produce(String.t(), String.t(), String.t()) :: :ok | :error | any()
  def produce(topic, key, message) do
    request = %Request{
      messages: [
        %Message{
          key: key,
          value: message
        }
      ],
      topic: topic,
      required_acks: 1
    }

    case KafkaEx.produce(request) do
      {:ok, id} -> Logger.info("message sent: pid: #{id}")
      error -> Logger.error("error: #{error}")
    end
  end
end
