alias Prismic.Fragment.StructuredText.Span

defmodule Span.Em do
  defstruct [:start, :end]

  @type t :: %__MODULE__{start: Integer.t(), end: Integer.t()}
end

defimpl Span, for: Span.Em do
  # TODO
  def serialize(_, _link_resolver), do: ""
end
