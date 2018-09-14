alias Prismic.Fragment.StructuredText.Span

defmodule Span.Em do
  defstruct [:start, :end]

  @type t :: %__MODULE__{start: Integer.t(), end: Integer.t()}
end

defimpl Span, for: Span.Em do
  # TODO
  def serialize(_, _link_resolver), do: ""
  def open_tag(_span), do: "<i>"
  def close_tag(_span), do: "</i>"
end
