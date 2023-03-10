defmodule Wikimedia.BroadwayConsumer do
  use Broadway

  require Logger

  def start_link(_opts \\ []) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayKafka.Producer,
           [
             hosts: [localhost: 9092],
             group_id: "wikimedia_group",
             topics: ["wikimedia.recent_change"]
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 2
        ]
      ]
      # batchers: [
      #   default: [
      #     batch_size: 10,
      #     batch_timeout: 200,
      #     concurrency: 1
      #   ]
      # ]
    )
  end

  @impl true
  def handle_message(:default, message, _) do
    %Broadway.Message{data: data, metadata: %{headers: _headers, topic: _topic}} = message
    case Avrora.decode(data, schema_name: "body.Wikimedia") do
      {:ok, decoded} -> Logger.debug("proccessed by broadway #{decoded["id"]} #{DateTime.utc_now}")
      _ -> Logger.error("ups!!")
    end

    # it is required to return the broadway message struct
    message
  end
end
