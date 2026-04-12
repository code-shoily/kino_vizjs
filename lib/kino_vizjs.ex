defmodule KinoVizjs do
  @moduledoc """
  Kino integration for Viz.js.
  """

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(Kino.VizJS.SmartCell)

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
