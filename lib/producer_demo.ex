defmodule KafkaBeginner.ProducerDemo do
  require Logger

  def produce(topic, message) do
    Logger.info("sending message: #{message} to: #{topic}")

    case KafkaEx.produce(topic, 0, message) do
      :ok -> Logger.info("message sent!")
      error -> Logger.error("error: #{error}")
    end
  end
end
