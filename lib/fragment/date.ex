defmodule Prismic.Fragment.Date do
  @type t :: %__MODULE__{value: DateTime.t()}

  defstruct [:value]
end
