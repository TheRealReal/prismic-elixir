alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text do
  alias Prismic.Fragment.StructuredText.Span

  defstruct [:text, :label, spans: []]

  @type t :: %__MODULE__{text: String.t(), spans: [Span.t()], label: String.t()}

  @spec prepare_spans(t) :: {list(Span.t()), list(Span.t())}
  def prepare_spans(%{spans: spans}) do
    default = %{start_spans: %{}, end_spans: %{}}
    spans = Enum.reduce(spans, default, &span_inject/2)

    {spans.start_spans, spans.end_spans}
  end

  defp span_inject(
         %{start: span_start, end: span_end} = span,
         %{start_spans: ss, end_spans: es} = acc
       ) do
    new_start_spans = Map.put(ss, span_start, span)
    new_end_spans = Map.put(es, span_end, span)

    %{acc | start_spans: new_start_spans, end_spans: new_end_spans}
  end
end

defimpl Block, for: Block.Text do
  # TODO
  def as_html(_, _link_resolver, _html_serializer), do: ""
end
