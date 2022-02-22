defmodule CommandedToolkit do
  def main(_args) do
    # IO.puts "choose tool: "

    Ratatouille.run(Cqrs.Toolkit.AggregateInspector)
  end
end
