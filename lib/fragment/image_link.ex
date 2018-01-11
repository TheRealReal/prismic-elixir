defmodule Prismic.Fragment.ImageLink do
  defstruct [:url, :target]

  @type t :: %__MODULE__{
          url: String.t(),
          target: String.t()
        }
end
