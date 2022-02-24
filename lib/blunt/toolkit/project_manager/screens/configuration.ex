defmodule Blunt.Toolkit.ProjectManager.Screens.Configuration do
  import Ratatouille.View

  def update(model, msg) do
    case msg do
      _ ->
        model
    end
  end

  def render(%{view: __MODULE__}) do
    panel(title: "Project Configuration", height: :fill)
  end
end
