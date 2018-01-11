defmodule Prismic.Fragment.CompositeSlice do
  alias Prismic.Group
  @type t :: %__MODULE__{
          slice_type: String.t(),
          slice_label: String.t(),
          non_repeat: map,
          repeat: Group.t()
        }

  defstruct [:slice_type, :slice_label, :non_repeat, :repeat]
end
