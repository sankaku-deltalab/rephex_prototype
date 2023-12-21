defmodule RephexPtWeb.UserLive.Index do
  use RephexPtWeb, :live_view
  alias Phoenix.LiveView.Socket
  alias Rephex2User.State
  alias Rephex2User.Slice.CounterSlice

  # Init at root component
  def mount(_params, _session, %Socket{} = socket) do
    {:ok, State.init(socket)}
  end

  # Update Rephex state by event
  def handle_event("add_count", %{"amount" => am}, socket) when is_bitstring(am) do
    am = am |> String.to_integer()
    socket = socket |> CounterSlice.add_count(%{amount: am})
    {:noreply, socket}
  end

  def handle_event("add_2_async", _params, socket) do
    socket = socket |> CounterSlice.add_count_async(%{amount: 2})

    {:noreply, socket}
  end

  def handle_info({RephexPtWeb.UserLive.ChildComponent, {:add_count, amount}} = _msg, socket)
      when is_integer(amount) do
    {:noreply, CounterSlice.add_count(socket, %{amount: amount})}
  end

  def handle_async(name, result, socket) do
    {:noreply, State.resolve_async(socket, name, result)}
  end
end
