defmodule Prismic.Fragment.Timestamp do
  @type t :: %__MODULE__{value: DateTime.t()}

  defstruct [:value]
end
