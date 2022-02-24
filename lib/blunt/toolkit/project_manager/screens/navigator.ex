defmodule Blunt.Toolkit.ProjectManager.Screens.Navigator do
  import Ratatouille.View

  alias Blunt.Toolkit.ProjectManager.Screens.{BoundedContexts, Configuration}

  def update(model, msg) do
    case msg do
      {:event, %{ch: ch}} when ch in [?q, ?Q] ->
        %{model | show_navigator: false}

      {:event, %{ch: ch}} when ch in [?b, ?B] ->
        set_view(model, BoundedContexts)

      {:event, %{ch: ch}} when ch in [?c, ?C] ->
        set_view(model, Configuration)

      _ ->
        model
    end
  end

  defp set_view(model, view),
    do: %{model | view: view, show_navigator: false}

  def render(%{show_navigator: true}) do
    overlay do
      panel(title: "Navigate") do
        label(content: "b) Bounded Contexts")
        label(content: "c) Project Configuration")
        label(content: "q) Close")
      end
    end
  end

  def render(_model), do: nil
end
