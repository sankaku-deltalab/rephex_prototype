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

  def handle_event("add_2_async", _params, socket) do
    socket =
      socket
      |> Rephex.AddCountAsync.start(%{amount: 2})

    {:noreply, socket}
  end

  def handle_info({RephexPtWeb.UserLive.ChildComponent, {:add_count, amount}} = _msg, socket)
      when is_integer(amount) do
    {:noreply, Rephex.add_count(socket, %{amount: amount})}
  end

  def handle_async(name, result, socket) do
    {:noreply, Rephex.resolve_async(socket, name, result)}
  end
end
