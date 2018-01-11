defmodule Prismic.Form do
  defstruct [:name, :method, :rel, :enctype, :action, :fields]

  @type t :: %__MODULE__{
          name: String.t(),
          method: String.t(),
          rel: String.t(),
          enctype: String.t(),
          action: String.t(),
          fields: Map.t()
        }
end
