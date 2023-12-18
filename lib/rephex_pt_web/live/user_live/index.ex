defmodule RephexPtWeb.UserLive.Index do
  use RephexPtWeb, :live_view
  alias Phoenix.LiveView.Socket

  # Init at root component
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, Rephex.init(socket)}
  end

  # Update Rephex state by event
  def handle_event("add_count", %{"amount" => am}, socket) do
    {:noreply, Rephex.add_count(socket, %{amount: am |> String.to_integer()})}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p>Count: <%= Rephex.count(@__rephex__) %></p>
      <button phx-click="add_count" phx-value-amount="10">Add 10</button>
    </div>
    """
  end
end
