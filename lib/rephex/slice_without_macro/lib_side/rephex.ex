defmodule Rephex.SliceWithoutMacro.Rephex do
  import Phoenix.Component
  import Phoenix.LiveComponent
  alias Phoenix.LiveView.Socket

  @root :__rephex__
  @type state :: map()
  @type slice_name :: module()

  # For slices

  @spec init_slice(Socket.t(), slice_name(), state()) :: Socket.t()
  def init_slice(%Socket{} = socket, slice_name, %{} = state) do
    socket
    |> assign_new(@root, fn -> %{} end)
    |> update(@root, fn root -> Map.put(root, slice_name, state) end)
  end

  @spec update_slice(Socket.t(), slice_name(), (state() -> state())) :: Socket.t()
  def update_slice(%Socket{} = socket, slice_name, func) do
    new_slice = func.(get_slice(socket, slice_name))

    socket
    |> update(@root, &%{&1 | slice_name => new_slice})
  end

  @spec get_slice(Socket.t(), slice_name()) :: state()
  def get_slice(%Socket{} = socket, slice_name) do
    socket.assigns[@root][slice_name]
  end

  @spec get_from_slice(Socket.t(), slice_name(), (state() -> val)) :: val when val: any()
  def get_from_slice(%Socket{} = socket, slice_name, getter) do
    socket
    |> get_slice(slice_name)
    |> getter.()
  end

  @spec start_async(Phoenix.LiveView.Socket.t(), module(), (-> any())) :: Socket.t()
  def start_async(%Socket{} = socket, module, fun)
      when is_atom(module) and is_function(fun, 0) do
    Phoenix.LiveView.start_async(socket, module, fun)
  end
end
