defmodule Rephex.SliceWithoutMacro.CounterSlice do
  @behaviour Rephex.SliceWithoutMacro.SliceBehaviour
  alias Rephex.SliceWithoutMacro.Base
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
    Base.init_slice(socket, @slice_name, %State{})
  end

  @impl true
  @spec async_modules() :: [atom()]
  def async_modules(), do: [AddCountAsync]

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    Base.update_slice(socket, @slice_name, &State.add_count(&1, 1))
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    Base.update_slice(socket, @slice_name, &State.add_count(&1, am))
  end

  # Async action
  @spec add_count_async(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count_async(%Socket{} = socket, %{amount: _am} = payload) do
    AddCountAsync.start(socket, payload)
  end

  # Selector

  @spec count(%{counter2: State.t()}) :: integer()
  def count(%{counter2: %State{count: c}} = _state), do: c
end

defmodule AddCountAsync do
  @behaviour Rephex.SliceWithoutMacro.AsyncBehaviour

  alias Rephex.SliceWithoutMacro.CounterSlice.State

  alias Rephex.SliceWithoutMacro.Base
  import Phoenix.LiveComponent
  alias Phoenix.LiveView.Socket
  # alias Phoenix.LiveView.AsyncResult

  @impl true
  @spec start(Socket.t(), %{amount: integer()}) :: Socket.t()
  def start(%Socket{} = socket, %{amount: am}) do
    Base.start_async(socket, __MODULE__, fn ->
      :timer.sleep(1000)
      am
    end)
  end

  @impl true
  def finish(%Socket{} = socket, result) do
    Base.update_slice(socket, :counter2, fn %{} = state ->
      case result do
        {:ok, amount} -> State.add_count(state, amount)
        {:exit, _reason} -> state
      end
    end)
  end

  # TODO: start / finish はも socket を扱わない関数にできるのでは？
end
