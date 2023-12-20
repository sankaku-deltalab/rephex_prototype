defmodule Rephex.SliceWithoutMacro.SliceMasterMacro do
  defmacro __using__(opt) when is_list(opt) do
    slices = Keyword.fetch!(opt, :slices)

    quote do
      alias Rephex.SliceWithoutMacro.SliceMasterMacroSupport
      alias Phoenix.LiveView.Socket

      @slices unquote(slices)
      @async_modules SliceMasterMacroSupport.collect_async_modules(@slices)

      @spec init(Socket.t()) :: Socket.t()
      def init(%Socket{} = socket) do
        SliceMasterMacroSupport.init_slices(socket, @slices)
      end

      def resolve_async(%Socket{} = socket, name, result) do
        SliceMasterMacroSupport.resolve_async(socket, @async_modules, name, result)
      end
    end
  end
end

defmodule Rephex.SliceWithoutMacro.SliceMasterMacroSupport do
  alias Phoenix.LiveView.Socket

  @spec init_slices(Socket.t(), [module()]) :: Socket.t()
  def init_slices(%Socket{} = socket, slice_modules) do
    slice_modules
    |> Enum.reduce(socket, fn module, socket -> module.init(socket) end)
  end

  @spec collect_async_modules([module()]) :: MapSet.t()
  def collect_async_modules(slice_modules) do
    slice_modules
    |> Enum.flat_map(& &1.async_modules())
    |> MapSet.new()
  end

  @spec resolve_async(Socket.t(), MapSet.t(), atom(), any()) :: any()
  def resolve_async(%Socket{} = socket, %MapSet{} = async_modules, name, result) do
    if name in async_modules do
      name.resolve(socket, result)
    else
      raise {:not_async_module, name}
    end
  end
end
