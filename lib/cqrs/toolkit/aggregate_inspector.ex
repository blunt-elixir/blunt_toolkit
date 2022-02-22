defmodule Cqrs.Toolkit.AggregateInspector do
  @behaviour Ratatouille.App
  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  alias Ratatouille.Runtime.Command
  alias Cqrs.Toolkit.AggregateInspector.{Cache, Commands}

  @enter_key key(:enter)

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @delete_keys [
    key(:delete),
    key(:backspace),
    key(:backspace2)
  ]

  def init(_context) do
    :ok = Logger.configure(level: :warn)
    {:ok, _} = Cache.start_link()

    config = %{
      stream: "",
      stream_loaded: false,
      aggregate: "",
      aggregate_loaded: false,
      eventstore: "",
      eventstore_loaded: false,
      current_version: 0,
      state: [],
      loading: true
    }

    config
    |> Cache.get(:stream)
    |> Cache.get(:aggregate)
    |> Cache.get(:eventstore)
  end

  def update(%{eventstore_loaded: false, eventstore: eventstore} = model, msg) do
    case msg do
      {:event, %{key: key}} when key in @delete_keys ->
        %{model | eventstore: String.slice(eventstore, 0..-2)}

      {:event, %{key: @enter_key}} ->
        eventstore = Commands.get_event_store!(eventstore)
        _ = Cache.put(:eventstore, eventstore)
        %{model | eventstore: eventstore, eventstore_loaded: true}

      {:event, %{ch: ch}} when ch > 0 ->
        %{model | eventstore: eventstore <> <<ch::utf8>>}

      _ ->
        model
    end
  end

  def update(%{stream_loaded: false, stream: stream} = model, msg) do
    case msg do
      {:event, %{key: key}} when key in @delete_keys ->
        %{model | stream: String.slice(stream, 0..-2)}

      {:event, %{key: @enter_key}} ->
        Cache.put(:stream, stream)
        %{model | stream: stream, stream_loaded: true}

      {:event, %{ch: ch}} when ch > 0 ->
        %{model | stream: stream <> <<ch::utf8>>}

      _ ->
        model
    end
  end

  def update(%{aggregate_loaded: false, aggregate: aggregate} = model, msg) do
    case msg do
      {:event, %{key: key}} when key in @delete_keys ->
        %{model | aggregate: String.slice(aggregate, 0..-2)}

      {:event, %{key: @enter_key}} ->
        aggregate = Commands.get_aggregate!(aggregate)
        Cache.put(:aggregate, aggregate)
        model = %{model | aggregate: aggregate, aggregate_loaded: true}
        command = Command.new(fn -> Commands.load_stream(model) end, :stream_loaded)
        {model, command}

      {:event, %{ch: ch}} when ch > 0 ->
        %{model | aggregate: aggregate <> <<ch::utf8>>}

      _ ->
        model
    end
  end

  def update(%{current_version: current_version, state: state} = model, msg) do
    case msg do
      {:stream_loaded, events} ->
        %{model | state: events}

      {:event, %{ch: ?k}} ->
        %{model | current_version: max(current_version - 1, 0)}

      {:event, %{ch: ?j}} ->
        %{model | current_version: min(current_version + 1, length(state) - 1)}

      {:event, %{key: key}} when key in [@arrow_up, @arrow_down] ->
        new_version =
          case key do
            @arrow_up -> max(current_version - 1, 0)
            @arrow_down -> min(current_version + 1, length(state) - 1)
          end

        %{model | current_version: new_version}

      _ ->
        model
    end
  end

  def render(%{eventstore_loaded: false, eventstore: eventstore}) do
    view do
      panel title: "Enter EventStore module" do
        label(content: eventstore <> "▌")
      end
    end
  end

  def render(%{stream_loaded: false, stream: stream}) do
    view do
      panel title: "Enter stream_uuid" do
        label(content: stream <> "▌")
      end
    end
  end

  def render(%{aggregate_loaded: false, aggregate: aggregate}) do
    view do
      panel title: "Enter aggregate module" do
        label(content: aggregate <> "▌")
      end
    end
  end

  def render(model) do
    view do
      render_metadata_row(model)

      row do
        column size: 4 do
          render_events_panel(model)
        end

        column size: 8 do
          render_state_panel(model)
        end
      end
    end
  end

  defp render_events_panel(%{current_version: current_version, state: state}) do
    title = "Events (#{current_version} of #{length(state) - 1})"

    panel title: title, height: :fill, color: :blue do
      viewport offset_y: current_version do
        for {event, index} <- Enum.with_index(state) do
          type = Map.fetch!(event, :event_type)

          if index == current_version do
            label(content: "> v#{index} " <> type, attributes: [:bold])
          else
            label(content: "v#{index} " <> type)
          end
        end
      end
    end
  end

  defp render_state_panel(%{current_version: current_version, state: state}) do
    current_state =
      state
      |> Enum.at(current_version, %{})
      |> Map.get(:state)

    title = "State @ version #{current_version}"

    panel title: title, height: :fill, color: :blue do
      viewport do
        label(content: inspect(current_state, pretty: true, limit: :infinity))
      end
    end
  end

  defp render_metadata_row(%{aggregate: aggregate, stream: stream, eventstore: eventstore}) do
    row do
      column size: 12 do
        render_metadata_row("eventstore", inspect(eventstore))
        render_metadata_row("aggregate", inspect(aggregate))
        render_metadata_row("stream", stream)
      end
    end
  end

  defp render_metadata_row(title, content) do
    row do
      column size: 1 do
        label(content: title, color: :blue)
      end

      column size: 11 do
        label(content: content)
      end
    end
  end
end
