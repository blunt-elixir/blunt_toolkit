defmodule Mix.Tasks.Blunt.Project do
  use Mix.Task

  def run(_args) do
    CqrsToolkit.run_tui(Blunt.Toolkit.ProjectManager)
  end
end
