defmodule Wikimedia.ChangeHandler do
  use GenServer, shutdown: 1000

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

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    case Regex.run(~r/data: (.+?)\n/, chunk) do
      [_, data] ->
        json = Jason.decode!(data)
        # todo send messages to kafka
        IO.inspect(json)
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
end