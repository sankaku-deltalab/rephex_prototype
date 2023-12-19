# これはマクロにしちゃってもいいかも
# でもマクロにする必要性は全然ない
# defmodule Rephex.SliceWithoutMacro.SliceMaster do
#   alias Rephex.SliceWithoutMacro.CounterSlice
#   alias Rephex.SliceWithoutMacro.Rephex
#   alias Phoenix.LiveView.Socket

#   @slices [CounterSlice]

#   @async_modules Rephex.collect_async_modules(@slices)

#   @spec init(Socket.t()) :: Socket.t()
#   def init(%Socket{} = socket) do
#     Rephex.init_slices(socket, @slices)
#   end

#   def resolve_async(%Socket{} = socket, name, result) do
#     Rephex.resolve_async(socket, @async_modules, name, result)
#   end
# end

defmodule Rephex.SliceWithoutMacro.SliceMaster do
  alias Rephex.SliceWithoutMacro.CounterSlice
  use Rephex.SliceWithoutMacro.SliceMasterMacro, slices: [CounterSlice]
end
