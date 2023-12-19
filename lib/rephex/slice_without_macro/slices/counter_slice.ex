defmodule Rephex.SliceWithoutMacro.CounterSlice do
  @behaviour Rephex.SliceWithoutMacro.SliceBehaviour
  alias Rephex.SliceWithoutMacro.Rephex
  alias Phoenix.LiveView.Socket

  @slice_name :counter2

  defmodule State do
    defstruct count: 0
    @type t :: %State{count: integer()}

    @spec add_count(t(), integer()) :: t()
    def add_count(%__MODULE__{} = state, amount) when is_integer(amount) do
      %{state | count: state.count + amount}
    end
  end

  @impl true
  @spec init(Socket.t()) :: Socket.t()
  def init(%Socket{} = socket) do
    Rephex.init_slice(socket, @slice_name, %State{})
  end

  @impl true
  @spec async_modules() :: [atom()]
  def async_modules(), do: [AddCountAsync]

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    Rephex.update_slice(socket, @slice_name, &State.add_count(&1, 1))
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    Rephex.update_slice(socket, @slice_name, &State.add_count(&1, am))
  end

  # Async action

  defmodule AddCountAsync do
    import Phoenix.LiveComponent
    alias Phoenix.LiveView.Socket
    # alias Phoenix.LiveView.AsyncResult

    @spec start(Socket.t(), %{amount: integer()}) :: Socket.t()
    def start(%Socket{} = socket, %{amount: am}) do
      Rephex.start_async(socket, __MODULE__, fn ->
        :timer.sleep(1000)
        am
      end)
    end

    def finish(%Socket{} = socket, result) do
      Rephex.update_slice(socket, :counter2, fn %{} = state ->
        case result do
          {:ok, amount} -> State.add_count(state, amount)
          {:exit, _reason} -> state
        end
      end)
    end

    # TODO: start / finish はも socket を扱わない関数にできるのでは？
  end

  @spec add_count_async(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count_async(%Socket{} = socket, %{amount: _am} = payload) do
    # TODO: こんな風に呼んだ方がいい？
    Rephex.cast_async(socket, @slice_name, AddCountAsync, payload)
    # AddCountAsync.start(socket, payload)
  end

  # Selector

  @spec count(%{counter2: State.t()}) :: integer()
  def count(%{counter2: %State{count: c}} = _state), do: c
end
