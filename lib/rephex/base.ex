defmodule Rephex.Base do
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

  # For prototyping, use only 1 slice
  @root :__rephex__

  @type state :: map()

  @doc """
  Initialize Rephex state.

  ## Example

  ```ex
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, Rephex.init(socket)}
  end
  ```
  """
  @spec init(Socket.t(), map()) :: Socket.t()
  def init(%Socket{} = socket, %{} = state) do
    assign(socket, @root, state)
  end

  @doc """
  Update Rephex state.

  ## Example

  ```ex
  def add_count(%Socket{} = socket, %{amount: am}) do
    update_rephex(socket, fn state ->
      %{state | count: state.count + am}
    end)
  end
  ```
  """
  @spec update_rephex(Socket.t(), (st -> st)) :: Socket.t() when st: state()
  def update_rephex(%Socket{} = socket, func) do
    socket
    |> assign(@root, func.(socket.assigns[@root]))
  end

  @spec get_rephex(Socket.t()) :: st when st: state()
  def get_rephex(%Socket{} = socket) do
    socket.assigns[@root]
  end

  @spec get_from_rephex(Socket.t(), (st -> val)) :: val when st: state(), val: any()
  def get_from_rephex(%Socket{} = socket, getter) do
    socket.assigns[@root]
    |> getter.()
  end

  def start_async(%Socket{} = socket, module, fun) do
    Phoenix.LiveView.start_async(socket, module, fun)
  end
end
