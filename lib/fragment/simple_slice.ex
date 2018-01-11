defmodule Prismic.Fragment.SimpleSlice do
  @type t :: %__MODULE__{
          slice_type: String.t(),
          slice_label: String.t(),
          value: any
        }

  defstruct [:slice_type, :slice_label, :value]
end
