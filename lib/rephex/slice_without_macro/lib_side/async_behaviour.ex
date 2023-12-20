defmodule Rephex.SliceWithoutMacro.AsyncBehaviour do
  alias Phoenix.LiveView.Socket

  @callback start(Socket.t(), map()) :: Socket.t()
  @callback finish(Socket.t(), {:ok, any()} | {:exit, any()}) :: Socket.t()
end
