defmodule RephexPtWeb.UserLive.ChildComponent do
  use RephexPtWeb, :live_component

  attr :__rephex__, :map, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p>Count: <%= Rephex.count(@__rephex__) %></p>
      <button phx-click="add_count" phx-value-amount="10">Add 10</button>
      <%= if @flip do %>
        flip
      <% else %>
        flop
      <% end %>
      <button phx-click="flipflop" phx-target={@myself}>
        [FlipFlop & Add count]
      </button>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket = socket |> assign(%{flip: true})
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("flipflop", _params, socket) do
    socket =
      socket
      |> update(:flip, fn f -> not f end)

    # Do NOT call Rephex action with LiveComponent socket
    # socket = socket |> Rephex.add_count(%{amount: 11})

    notify_parent({:add_count, 11})

    {:noreply, socket}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
