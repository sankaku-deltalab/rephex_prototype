defmodule Rephex2User.State do
  alias Rephex2User.Slice
  use Rephex2.State, slices: [Slice.CounterSlice]
end
