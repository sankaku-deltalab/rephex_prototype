defmodule Rephex2User.Slice.CounterSlice do
  @behaviour Rephex2.Slice
  alias Phoenix.LiveView.Socket
  alias Rephex2User.Slice.CounterSlice.AsyncAddCount

  defmodule State do
    defstruct count: 0
    @type t :: %State{count: integer()}

    @spec add_count(t(), integer()) :: t()
    def add_count(%__MODULE__{} = state, amount) when is_integer(amount) do
      %{state | count: state.count + amount}
    end
  end

  defmodule Support do
    use Rephex2.Slice.Support, struct: State, name: :counter3
  end

  @impl true
  @spec init(Socket.t()) :: Socket.t()
  def init(%Socket{} = socket) do
    Support.init_slice(socket, %State{})
  end

  @impl true
  @spec async_modules() :: [atom()]
  def async_modules(), do: [AsyncAddCount]

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    Support.update_slice(socket, &State.add_count(&1, 1))
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) when is_integer(am) do
    Support.update_slice(socket, &State.add_count(&1, am))
  end

  # Async action

  @spec add_count_async(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count_async(%Socket{} = socket, %{amount: _am} = payload) do
    AsyncAddCount.start(socket, payload)
  end

  # Selector

  @spec count(%{counter3: map()}) :: integer()
  def count(root) do
    root
    |> Support.slice_in_root()
    |> then(fn %State{count: c} -> c end)
  end
end

defmodule Rephex2User.Slice.CounterSlice.AsyncAddCount do
  @behaviour Rephex2.AsyncAction

  alias Rephex2User.Slice.CounterSlice
  alias Rephex2User.Slice.CounterSlice.Support
  import Phoenix.LiveComponent
  alias Phoenix.LiveView.Socket
  # alias Phoenix.LiveView.AsyncResult

  @impl true
  @spec start(Socket.t(), %{amount: integer()}) :: Socket.t()
  def start(%Socket{} = socket, %{amount: am}) do
    Support.start_async(socket, __MODULE__, fn _state ->
      :timer.sleep(1000)
      am
    end)
  end

  @impl true
  def resolve(%Socket{} = socket, result) do
    case result do
      {:ok, amount} when is_integer(amount) -> CounterSlice.add_count(socket, %{amount: amount})
      {:exit, _reason} -> socket
    end
  end
end
