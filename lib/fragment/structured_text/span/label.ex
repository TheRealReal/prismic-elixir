alias Prismic.Fragment.StructuredText.Span

defmodule Span.Label do
  defstruct [:label, :start, :end]

  @type t :: %__MODULE__{label: String.t(), start: Integer.t(), end: Integer.t()}
end

defimpl Span, for: Span.Label do
  # TODO
  def serialize(_, _link_resolver), do: ""
end
