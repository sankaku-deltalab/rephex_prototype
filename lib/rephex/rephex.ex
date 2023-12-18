defmodule Rephex do
  @moduledoc """
  State manager like Redux-toolkit for LiveView.

  ## Example

  ```ex
  # Init at root component
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, Rephex.init(socket)}
  end

  # Update Rephex state by event
  def handle_event("add_count", %{"amount" => am}, socket) do
    {:noreply, Rephex.add_count(socket, %{amount: am})}
  end
  ```

  # Pass Rephex state to child component
  ```heex
  <.live_component module={HeroComponent} id="hero" __rephex__={@__rephex__} />
  ```

  ```ex
  # Use Rephex state in child component
  # NOTE: do not target @self at action
  defmodule HeroComponent do
    use Phoenix.LiveComponent
    alias Rephex

    def render(assigns) do
      ~H'''
      <div>
        <p>Count: {Rephex.count(@socket)}</p>
        <button phx-click="add_count" phx-value-amount="10">Add 10</button>
      </div>
      '''
    end
  end
  ```
  """

  import Phoenix.LiveComponent
  # alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.Socket

  alias Rephex.Base

  defstruct count: 0

  @type t :: %__MODULE__{count: integer()}

  @async MapSet.new([Rephex.AddCountAsync])

  @doc """
  Initialize Rephex state.

  ## Example

  ```ex
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, Rephex.init(socket)}
  end
  ```
  """
  @spec init(Socket.t()) :: Socket.t()
  def init(%Socket{} = socket) do
    Base.init(socket, %__MODULE__{})
  end

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    Base.update_rephex(socket, fn %__MODULE__{} = state ->
      %{state | count: state.count + 1}
    end)
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    Base.update_rephex(socket, fn %__MODULE__{} = state ->
      %{state | count: state.count + am}
    end)
  end

  # Selector

  @spec count(t()) :: integer()
  def count(%__MODULE__{} = state) do
    state.count
  end

  def resolve_async(%Socket{} = socket, name, result) do
    if name in @async do
      name.finish(socket, result)
    else
      raise {:not_async_module, name}
    end
  end
end

defmodule Rephex.AddCountAsync do
  alias Rephex.Base
  alias Rephex
  alias Phoenix.LiveView.Socket

  import Phoenix.LiveComponent
  # alias Phoenix.LiveView.AsyncResult

  @spec start(Socket.t(), %{amount: integer()}) :: Socket.t()
  def start(%Socket{} = socket, %{amount: am}) do
    Base.start_async(socket, __MODULE__, fn ->
      :timer.sleep(1000)
      am
    end)
  end

  def finish(%Socket{} = socket, result) do
    Base.update_rephex(socket, fn %Rephex{} = state ->
      case result do
        {:ok, amount} -> %{state | count: state.count + amount}
        {:exit, _reason} -> state
      end
    end)
  end
end
