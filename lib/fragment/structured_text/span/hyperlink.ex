alias Prismic.Fragment.StructuredText.Span

defmodule Span.Hyperlink do
  defstruct [:start, :end, :link]

  @type t :: %__MODULE__{start: Integer.t(), end: Integer.t(), link: String.t()}
end

defimpl Span, for: Span.Hyperlink do
  # TODO
  def serialize(_, _link_resolver), do: ""
end
