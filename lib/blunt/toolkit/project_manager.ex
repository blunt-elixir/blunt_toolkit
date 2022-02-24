defmodule Blunt.Toolkit.ProjectManager do
  @behaviour Ratatouille.App
  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  alias Blunt.Toolkit.ProjectManager.Screens.{BoundedContexts, Navigator}

  def init(_context) do
    %{
      view: BoundedContexts,
      show_navigator: false
    }
  end

  @spacebar key(:space)

  def update(%{show_navigator: true} = model, message),
    do: Navigator.update(model, message)

  def update(model, message) do
    case message do
      {:event, %{key: @spacebar}} ->
        %{model | show_navigator: true}

      _ ->
        model
    end
  end

  def render(%{view: active_view} = model) do
    view(top_bar: top_bar(), bottom_bar: bottom_bar()) do
      active_view.render(model)
      Navigator.render(model)
    end
  end

  defp top_bar do
    bar do
      label(content: "A top bar for the view")
    end
  end

  defp bottom_bar do
    bar do
      label(content: "A bottom bar for the view")
    end
  end
end
