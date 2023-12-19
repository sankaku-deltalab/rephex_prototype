defmodule Rephex.SliceWithoutMacro.SliceBehaviour do
  alias Phoenix.LiveView.Socket

  @callback init(socket :: Socket.t()) :: Socket.t()
  @callback async_modules() :: [atom()]
end
