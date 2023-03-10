defmodule Wikimedia do
  @moduledoc false
  use Application

  def start(_type \\ [], _args \\ []) do
    IO.inspect("Starting supervisor...")

    children = [
        Avrora,
        Wikimedia.ChangeHandler,
        Wikimedia.Consumer
      ]

    opts = [strategy: :one_for_one, name: Wikimedia.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def start_broadway(_type \\ [], _args \\ []) do
    IO.inspect("Starting broadway supervisor...")

    children = [
       Avrora,
       Wikimedia.BroadwayConsumer
      ]

    opts = [strategy: :one_for_one, name: Wikimedia.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
