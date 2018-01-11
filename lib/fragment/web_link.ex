defmodule Prismic.Fragment.WebLink do
  @type t :: %__MODULE__{url: String.t(), target: String.t()}

  defstruct [:url, :target]
end
