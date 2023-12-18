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

  # import Phoenix.Component
  import Phoenix.LiveComponent
  # import Phoenix.LiveView
  # alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.Socket
  # use KinWeb, :live_component

  alias Rephex.Base

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
    Base.init(socket, @initial_state)
  end

  # Action

  @spec count_up(Socket.t(), %{}) :: Socket.t()
  def count_up(%Socket{} = socket, _payload) do
    Base.update_Rephex(socket, fn state ->
      %{state | count: state.count + 1}
    end)
  end

  @spec add_count(Socket.t(), %{amount: integer()}) :: Socket.t()
  def add_count(%Socket{} = socket, %{amount: am}) do
    Base.update_Rephex(socket, fn state ->
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
