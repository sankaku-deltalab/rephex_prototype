defmodule RephexPtWeb.UserLive.ChildComponent do
  use RephexPtWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p>Count: <%= Rephex.count(@__rephex__) %></p>
      <button phx-click="add_count" phx-value-amount="10">Add 10</button>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  # defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
