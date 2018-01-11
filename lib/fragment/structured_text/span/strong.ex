alias Prismic.Fragment.StructuredText.Span

defmodule Span.Strong do
  defstruct [:start, :end]

  @type t :: %__MODULE__{start: Integer.t(), end: Integer.t()}
end

defimpl Span, for: Span.Strong do
  # TODO
  def serialize(_, _link_resolver), do: ""
end
