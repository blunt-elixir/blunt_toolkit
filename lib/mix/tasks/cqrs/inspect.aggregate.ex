defmodule Mix.Tasks.Cqrs.Inspect.Aggregate do
  use Mix.Task

  import Ratatouille.Constants, only: [key: 1]

  def run(_args) do
    case Mix.Project.config()[:app] do
      nil ->
        raise "not in a mix project"

      app ->
        Logger.configure(level: :warning)
        Mix.Task.run("app.start", ["--no-start"])

        with {:ok, _} <- Application.ensure_all_started(app) do
          Ratatouille.run(Cqrs.Toolkit.AggregateInspector, quit_events: [{:key, key(:ctrl_c)}])
        end
    end
  end
end
