defmodule Mix.Tasks.Teddy.Stats do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Echoes arguments"
  @requirements ["app.config", "app.start"]

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Slurper.slurp_redemption()
    Slurper.slurp_tsd()
    Reducer.write()
  end
end
