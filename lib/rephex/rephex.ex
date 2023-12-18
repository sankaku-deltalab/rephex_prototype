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

  import Phoenix.Component
  import Phoenix.LiveComponent
  # import Phoenix.LiveView
  # alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.Socket
  # use KinWeb, :live_component

  @root :__rephex__

  @type state :: %{count: integer()}
  @initial_state %{count: 0}

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
    assign(socket, @root, @initial_state)
  end

  @doc """
  Update Rephex state.

  ## Example

  ```ex
  def add_count(%Socket{} = socket, %{amount: am}) do
    update_Rephex(socket, fn state ->
      %{state | count: state.count + am}
    end)
  end
  ```
  """
  @spec update_Rephex(Socket.t(), (state() -> state())) :: Socket.t()
  def update_Rephex(%Socket{} = socket, func) do
    socket
    |> assign(@root, func.(socket.assigns[@root]))
  end

  @spec get_Rephex(Socket.t()) :: state()
  def get_Rephex(%Socket{} = socket) do
    socket.assigns[@root]
  end

  @spec get_from_Rephex(Socket.t(), (state() -> val)) :: val when val: any()
  def get_from_Rephex(%Socket{} = socket, getter) do
    socket.assigns[@root]
    |> getter.()
  end

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    update_Rephex(socket, fn state ->
      %{state | count: state.count + 1}
    end)
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    update_Rephex(socket, fn state ->
      %{state | count: state.count + am}
    end)
  end

  # defmodule AddCountAsync do
  #   import Rephex
  #   @add_count_async_key :add_count_async

  #   @spec start(Socket.t(), %{amount: integer()}) :: Socket.t()
  #   def start(%Socket{} = socket, %{amount: am}) do
  #     start_async(socket, @add_count_async_key, fn ->
  #       :timer.sleep(1000)
  #       am
  #     end)
  #   end

  #   @spec finish(Socket.t(), any()) :: Socket.t()
  #   def finish(%Socket{} = socket, result) do
  #     update_Rephex(socket, fn state ->
  #       case result do
  #         {:ok, amount} -> %{state | count: state.count + amount}
  #         {:exit, _reason} -> state
  #       end
  #     end)
  #   end
  # end

  # Selector

  @spec count(state()) :: integer()
  def count(state) do
    state.count
  end
end
