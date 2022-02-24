defmodule Blunt.Toolkit.ProjectManager.Screens.BoundedContexts do
  import Ratatouille.View

  def update(model, msg) do
    case msg do
      _ ->
        model
    end
  end

  def render(%{view: __MODULE__}) do
    panel(title: "Bounded Contexts", height: :fill)
  end
end
