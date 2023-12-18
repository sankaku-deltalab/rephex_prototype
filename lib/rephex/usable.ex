# Using slice
defmodule Rephex.Slice do
  import Phoenix.Component
  import Phoenix.LiveComponent
  alias Phoenix.LiveView.Socket

  defmacro __using__(opt) when is_list(opt) do
    slice_struct = Keyword.fetch!(opt, :struct)
    slice_name = Keyword.get(opt, :name, slice_struct)
    async_modules = Keyword.fetch!(opt, :async_modules)

    quote do
      @root :__rephex__
      @type state :: unquote(slice_struct).t()
      @slice_name unquote(slice_name)
      @slice_struct unquote(slice_struct)
      @async_modules unquote(async_modules) |> MapSet.new()

      @doc """
      Initialize Rephex slice.

      ## Example

      ```ex
      def mount(_params, _session, %Socket{} = socket) do
        socket = socket |> SliceA.init() |> SliceB.init()
        {:ok, socket}
      end
      ```
      """
      @spec init_slice(Socket.t(), state()) :: Socket.t()
      def init_slice(%Socket{} = socket, %slice_struct{} = state) do
        socket
        |> update(@root, fn root -> Map.put(root, @slice_name, state) end)
      end

      @doc """
      Update Rephex slice.

      ## Example

      ```ex
      def add_count(%Socket{} = socket, %{amount: am}) do
        update_slice(socket, fn state ->
          %{state | count: state.count + am}
        end)
      end
      ```
      """
      @spec update_slice(Socket.t(), (state() -> state())) :: Socket.t()
      def update_slice(%Socket{} = socket, func) do
        socket
        |> assign(@root, func.(get_slice(socket)))
      end

      @spec get_slice(Socket.t()) :: state()
      def get_slice(%Socket{} = socket) do
        socket.assigns[@root][@slice_name]
      end

      @spec get_from_slice(Socket.t(), (state() -> val)) :: val when val: any()
      def get_from_slice(%Socket{} = socket, getter) do
        socket
        |> get_slice()
        |> getter.()
      end

      def start_async(%Socket{} = socket, module, fun)
          when is_atom(module) and is_function(fun, 0) do
        Phoenix.LiveView.start_async(socket, module, fun)
      end

      def resolve_async(%Socket{} = socket, name, result) do
        if name in @async_modules do
          name.finish(socket, result)
        else
          raise {:not_async_module, name}
        end
      end
    end
  end
end

defmodule Rephex.CounterSlice do
  use Rephex.Slice, name: :counter, struct: State, async_modules: [Rephex.AddCountAsync]
  alias Phoenix.LiveView.Socket

  defmodule State do
    defstruct count: 0
    @type t :: %State{count: integer()}

    def add_count(%__MODULE__{} = state, amount) when is_integer(amount) do
      %{state | count: state.count + amount}
    end
  end

  @spec init(Socket.t()) :: Socket.t()
  def init(%Socket{} = socket) do
    init_slice(socket, %State{})
  end

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    socket |> update_slice(&State.add_count(&1, 1))
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    socket |> update_slice(&State.add_count(&1, am))
  end

  # Selector

  @spec count(%{counter: State.t()}) :: integer()
  def count(%{counter: %State{count: c}} = _state), do: c
end
