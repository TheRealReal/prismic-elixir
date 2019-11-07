defmodule Prismic.Fragment.FileLink do
  defstruct [:url, :name, :kind, :size, :target]

  @type t :: %__MODULE__{
          url: String.t(),
          name: String.t(),
          kind: String.t(),
          size: String.t(),
          target: String.t()
        }
end
