defmodule Prismic.Fragment.SliceZone do
  @type slice :: CompositeSlice.t() | SimpleSlice.t()
  @type t :: %__MODULE__{slices: [slice]}

  defstruct slices: []
end
