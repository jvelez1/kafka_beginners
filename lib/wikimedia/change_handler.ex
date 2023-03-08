defmodule Wikimedia.ChangeHandler do
  use GenServer, shutdown: 1000

  alias Wikimedia.Producer

  require Logger

  @moduledoc """
  This module reads events from https://stream.wikimedia.org/v2/stream/recentchange
  and publish messages to kafka

  Usage:
  iex()> {:ok, pid} = GenServer.start(Wikimedia.ChangeHandler, [])
  send(pid, :terminate)
  """

  def start(url) do
    GenServer.start_link(__MODULE__, url: url)
  end

  @url "https://stream.wikimedia.org/v2/stream/recentchange"
  def init(_args) do
    IO.puts "Connecting to stream..."
    HTTPoison.get!(@url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  @topic "wikimedia.recent_change"
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    case Regex.run(~r/data: (.+?)\n/, chunk) do
      [_, data] ->
        data
        |> Jason.decode!()
        |> parse_data()
        |> encode_data()
        |> then(fn message -> Producer.send(@topic, message) end)
      _ -> nil
    end

    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncStatus{} = status, _state) do
    IO.puts "Connection status: #{inspect status}"
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = headers, _state) do
    IO.puts "Connection headers: #{inspect headers}"
    {:noreply, nil}
  end

  defp parse_data(%{"$schema" => schema, "meta" => %{"uri" => uri, "request_id" => request_id,"id" => id} } = _data) do
    %{schema: schema, uri: uri, request_id: request_id, id: id}
  end

  #
  # Previosly you should start avro =>  {:ok, pid} = Avrora.start_link()
  # register_schema_by_name => {:ok, schema} = Avrora.Utils.Registrar.register_schema_by_name("body.Wikimedia", force: true)
  #
  defp encode_data(parsed_data) do
    case Avrora.encode(parsed_data, schema_name: "body.Wikimedia") do
      {:ok, encoded} -> encoded
      _ -> Logger.error("ups!")
    end
  end
end
