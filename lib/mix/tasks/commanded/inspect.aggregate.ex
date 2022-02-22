defmodule Mix.Tasks.Commanded.Inspect.Aggregate do
  use Mix.Task

  import Ratatouille.Constants, only: [key: 1]

  def run(_args) do
    case Mix.Project.config()[:app] do
      nil ->
        raise "not in a mix project"

      app ->
        Mix.Task.run("app.start", ["--no-start"])
        Logger.configure(level: :warning)

        with {:ok, _} <- Application.ensure_all_started(app) do
          Ratatouille.run(Commanded.AggregateInspector, quit_events: [{:key, key(:ctrl_c)}])
        end
    end
  end
end
