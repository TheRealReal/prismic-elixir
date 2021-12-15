alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text.Paragraph do
  @type t :: %__MODULE__{text: String.t(), spans: [Span.t()], label: String.t()}

  defstruct [:text, :label, spans: []]
end

defimpl Block, for: Block.Text.Paragraph do
  alias Prismic.Fragment.StructuredText.Span

  def as_html(para, _link_resolver, _html_serializer) do
    ~s(<p>#{process_spans(para)}</p>)
  end

  # TODO: All this should move out (unless paragraph is the only one with spans?)
  defp process_spans(%{text: text, spans: []}), do: text

  defp process_spans(%{text: text, spans: spans}) do
    text_stream = String.codepoints(text)
    do_process_spans(text_stream, 0, spans, [], [])
  end

  defp do_process_spans([], _pos, _spans, applied_spans, acc) do
    [acc | Enum.map(applied_spans, &Span.close_tag/1)]
  end

  # TODO: Not sure how efficient this is, since it is one character at a time
  # Could do something smarter by checking the next opening and chunk characters
  # from there. Uses an IO list so we aren't creating too many intermediate strings
  defp do_process_spans([h | t], pos, spans, applied_spans, acc) do
    {ending_here, still_to_end} = Enum.split_with(applied_spans, &match?(%{end: ^pos}, &1))
    starting_here = Enum.filter(spans, &match?(%{start: ^pos}, &1))

    ending_tags = Enum.map(ending_here, &Span.close_tag/1)
    starting_tags = Enum.map(starting_here, &Span.open_tag/1)

    # TODO: h should be html encoded
    acc = [acc | [ending_tags, starting_tags, h]]

    applied_spans =
      starting_here
      |> Enum.reverse()
      |> Enum.concat(still_to_end)

    do_process_spans(t, pos + 1, spans, applied_spans, acc)
  end
end
