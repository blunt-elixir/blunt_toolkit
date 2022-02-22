defmodule Mix.Tasks.Commanded.Inspect.Aggregate do
  use Mix.Task

  def run(_args) do
    Ratatouille.run(Commanded.AggregateInspector)
  end
end
