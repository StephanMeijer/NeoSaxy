defmodule Bench.NoopHandler do
  @behaviour NeoSaxy.Handler

  @impl true
  def handle_event(_, _, state), do: {:ok, state}

  # Handler for Erlsom.
  def handle_event(_, state), do: state
end
