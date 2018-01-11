defmodule Prismic.Fragment.Select do
  @type t :: %__MODULE__{value: String.t()}

  defstruct [:value]
end

defimpl Prismic.Fragment, for: Prismic.Fragment.Select do
  def as_html(_, _, _), do: ""
end
