defmodule Prismic.Fragment.Number do
  @type t :: %__MODULE__{value: String.t()}

  defstruct [:value]
end

defimpl Prismic.Fragment, for: Prismic.Fragment.Number do
  def as_html(_, _, _), do: ""
end
