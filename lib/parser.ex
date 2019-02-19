defmodule Prismic.Parser do
  alias Prismic.{AlternateLanguage, Document, Group, GroupDocument, Fragment, Response}

  alias Fragment.{
    Color,
    CompositeSlice,
    Date,
    DocumentLink,
    Embed,
    FileLink,
    Geopoint,
    Image,
    ImageLink,
    Multiple,
    Number,
    Select,
    Separator,
    SimpleSlice,
    StructuredText,
    Text,
    View,
    WebLink
  }

  alias StructuredText.{Block, Block.Embed, Block.Image}
  alias Block.{Text.ListItem, Text.Paragraph, Text.Preformatted}
  alias StructuredText.Span.{Em, Hyperlink, Label, Strong}

  require Logger

  @parsers %{
    "Color" => :parse_color,
    "Date" => :parse_date,
    "Embed" => :parse_embed,
    "GeoPoint" => :parse_geo_point,
    "Group" => :parse_group,
    "Image" => :parse_image,
    "Link.web" => :parse_web_link,
    "Multiple" => :parse_multiple,
    "Number" => :parse_number,
    "Select" => :parse_select,
    "Separator" => :parse_separator,
    "SliceZone" => :parse_slices,
    "StructuredText" => :parse_structured_text,
    "Text" => :parse_text,
    "Timestamp" => :parse_timestamp,
    "Link.document" => :parse_document_link,
    "Link.file" => :parse_file_link,
    "Link.image" => :parse_image_link
  }

  defmodule ParseError do
    defexception message: "Prismic document(s) contain errors"
  end

  def parse_document(
        %{data: data, first_publication_date: fpd, last_publication_date: lpd} = results_json
      ) do
    {first_publication_date, last_publication_date} = get_publication_dates(fpd, lpd)

    raw_fragments =
      data
      |> Map.values()
      |> List.first()
      |> Enum.filter(fn {_, %{type: fragment_type}} ->
        Map.has_key?(@parsers, fragment_type)
      end)

    fragment_map =
      for {name, fragment_json} <- raw_fragments,
          into: %{},
          do: {name, parse_fragment(fragment_json)}

    Document
    |> struct(results_json)
    |> Map.update!(:slugs, fn slugs -> Enum.map(slugs, &URI.decode_www_form/1) end)
    |> Map.put(:first_publication_date, first_publication_date)
    |> Map.put(:last_publication_date, last_publication_date)
    |> Map.put(:alternate_languages, parse_alternate_languages(results_json))
    |> Map.put(:fragments, fragment_map)
  end

  def parse_response(%{results: results} = documents) do
    Response
    |> struct(documents)
    |> Map.put(:results, parse_results(results))
  end

  def parse_response(%{error: error} = _documents) do
    raise ParseError, message: "Error : #{error}"
  end

  ## PARSERS

  def parse_color(%{type: "Color", value: value}) do
    %Color{value: String.slice(value, 1..-1)}
  end

  def parse_date(%{value: value} = _json) do
    %Date{value: DateTime.from_iso8601(value)}
  end

  def parse_document_link(
        %{value: %{document: %{slug: slug, type: doc_type, data: doc_data} = doc} = value} = _json
      ) do
    fragments =
      if raw_frags = doc_data[String.to_atom(doc_type)] do
        for {name, raw_fragment} <- raw_frags, do: {name, parse_fragment(raw_fragment)}
      end

    DocumentLink
    |> struct(doc)
    |> Map.put(:type, doc_type)
    |> Map.put(:slug, URI.decode_www_form(slug))
    |> Map.put(:fragments, fragments)
    |> Map.put(:broken, Map.get(value, :isBroken))
    |> Map.put(:target, Map.get(value, :target))
  end

  def parse_document_link(
        %{value: %{document: %{slug: slug, type: doc_type} = doc} = value} = _json
      ) do
    DocumentLink
    |> struct(doc)
    |> Map.put(:type, doc_type)
    |> Map.put(:slug, URI.decode_www_form(slug))
    |> Map.put(:broken, Map.get(value, :isBroken))
    |> Map.put(:target, Map.get(value, :target))
  end

  def parse_embed(%{value: %{oembed: oembed}} = _json) do
    Block.Embed
    |> struct(oembed)
    |> Map.put(:o_embed_json, parse_embed_object(oembed))
  end

  defp parse_embed_object(o_embed_json) do
    Fragment.Embed
    |> struct(o_embed_json)
    |> Map.put(:o_embed_json, o_embed_json)
  end

  def parse_file_link(%{value: %{file: file}} = _json) do
    struct(FileLink, file)
  end

  def parse_file_link(%{value: %{file: file, target: target}} = _json) do
    FileLink
    |> struct(file)
    |> Map.put(:target, target)
  end

  def parse_geo_point(%{value: value} = _json), do: struct(Geopoint, value)

  def parse_group(%{type: "Group", value: groups}) do
    group_docs =
      Enum.map(groups, fn group ->
        fragments =
          for {name, raw_fragment} <- group, into: %{} do
            {name, parse_fragment(raw_fragment)}
          end

        %GroupDocument{fragments: fragments}
      end)

    %Group{group_documents: group_docs}
  end

  def parse_image(%{value: %{main: main, views: views}} = _json) do
    views = for {name, raw_view} <- views, do: {name, parse_view(raw_view)}

    %Fragment.Image{main: parse_view(main), views: views}
  end

  def parse_image_link(%{value: %{image: %{url: url}}} = _json) do
    %ImageLink{url: url}
  end

  def parse_image_link(%{value: %{image: %{url: url}, target: target}} = _json) do
    %ImageLink{url: url, target: target}
  end

  def parse_link(%{linkTo: %{type: type}} = json) do
    if {:ok, parser} = Map.fetch(@parsers, type), do: apply(__MODULE__, parser, [json])
  end

  def parse_link(%{type: type} = json) do
    if {:ok, parser} = Map.fetch(@parsers, type), do: apply(__MODULE__, parser, [json])
  end

  def parse_link(_), do: nil

  def parse_number(json), do: struct(Number, json)

  def parse_select(json), do: struct(Select, json)

  def parse_separator(_json), do: %Separator{value: ""}

  def parse_slices(%{type: "SliceZone", value: value}) do
    Enum.reduce(value, [], fn
      %{value: value, slice_type: type, slice_label: label}, slices ->
        slice = %SimpleSlice{slice_type: type, slice_label: label, value: parse_fragment(value)}

        [slice | slices]

      %{:"non-repeat" => non_repeat, repeat: repeat} = raw_composite, slices ->
        non_repeat_fragments =
          Enum.reduce(non_repeat, %{}, fn {fragment_key, raw_fragment}, map ->
            Map.put(map, fragment_key, parse_fragment(raw_fragment))
          end)

        repeat_fragments = parse_group(%{type: "Group", value: repeat})

        slice =
          CompositeSlice
          |> struct(raw_composite)
          |> Map.put(:non_repeat, non_repeat_fragments)
          |> Map.put(:repeat, repeat_fragments)

        [slice | slices]

      # may not need this
      %{type: type}, slices ->
        Logger.warn(fn -> "Slice type: `#{type}` not supported; cannot parse" end)
        slices
    end)
    |> Enum.reverse()
  end

  def parse_structured_text(%{value: blocks}) do
    %StructuredText{blocks: Enum.map(blocks, &parse_structured_text_block/1)}
  end

  def parse_text(json), do: struct(Text, json)

  def parse_timestamp(%{value: value} = _json) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    %Date{value: date}
  end

  def parse_web_link(%{value: value} = _json), do: struct(WebLink, value)

  ## PRIVATE FUNCTIONS

  defp parse_alternate_languages(%{alternate_languages: docs}) do
    Enum.reduce(docs, %{}, fn %{lang: lang} = doc, map ->
      Map.put(map, lang, struct(AlternateLanguage, doc))
    end)
  end

  defp parse_alternate_languages(_), do: nil

  defp parse_fragment(fragments) when is_list(fragments) do
    parse_multiple(fragments)
  end

  defp parse_fragment(%{type: fragment_type} = raw_fragment) do
    case Map.fetch(@parsers, fragment_type) do
      {:ok, parser} ->
        apply(__MODULE__, parser, [raw_fragment])

      :error ->
        Logger.warn(fn -> "Parser for fragment of \"#{fragment_type}\" type not implemented" end)

        raw_fragment
    end
  end

  defp parse_multiple(raw_fragments, fragments \\ [])

  defp parse_multiple([], fragments) do
    %Multiple{fragments: fragments}
  end

  defp parse_multiple([fragment | tail], fragments) do
    parse_multiple(tail, [parse_fragment(fragment) | fragments])
  end

  defp parse_results(results), do: Enum.map(results, &parse_document/1)

  defp parse_span(%{type: "em"} = span_json), do: struct(Em, span_json)
  defp parse_span(%{type: "strong"} = span_json), do: struct(Strong, span_json)

  defp parse_span(%{type: "hyperlink", data: data} = span_json) do
    Hyperlink
    |> struct(span_json)
    |> Map.put(:link, parse_link(data))
  end

  defp parse_span(%{type: "label", data: %{label: label}} = span_json) do
    Label
    |> struct(span_json)
    |> Map.put(:label, label)
  end

  defp parse_span(%{type: "label"} = span_json), do: struct(Label, span_json)

  defp parse_structured_text_block(%{type: "paragraph"} = block) do
    Paragraph
    |> struct(block)
    |> Map.update!(:spans, fn spans -> Enum.map(spans, &parse_span/1) end)
  end

  defp parse_structured_text_block(%{type: "preformatted", spans: spans} = block) do
    Preformatted
    |> struct(block)
    |> Map.put(:spans, Enum.map(spans, &parse_span/1))
  end

  defp parse_structured_text_block(%{type: "o-list-item", spans: spans} = block) do
    ListItem
    |> struct(block)
    |> Map.put(:ordered?, true)
    |> Map.put(:spans, Enum.map(spans, &parse_span/1))
  end

  defp parse_structured_text_block(%{type: "list-item", spans: spans} = block) do
    ListItem
    |> struct(block)
    |> Map.put(:ordered?, false)
    |> Map.put(:spans, Enum.map(spans, &parse_span/1))
  end

  defp parse_structured_text_block(%{type: "image"} = block) do
    Image
    |> struct(block)
    |> Map.put(:view, parse_view(block))
  end

  defp parse_structured_text_block(%{type: "embed"} = block) do
    Embed
    |> struct(block)
    |> Map.put(:embed, parse_embed_object(block))
  end

  defp parse_structured_text_block(%{type: type} = block) do
    if Regex.match?(~r/^heading(\d+)$/, type) do
      level =
        ~r/\d+/
        |> Regex.run(type)
        |> List.first()
        |> Integer.parse()
        |> elem(0)

      Block.Text.Heading
      |> struct(block)
      |> Map.put(:level, level)
      |> Map.put(:spans, Enum.map(block.spans, &parse_span/1))
    else
      Logger.warn(fn -> "Unknown block type: #{type}" end)
      block
    end
  end

  defp parse_view(%{dimensions: %{height: height, width: width}} = json) do
    View
    |> struct(json)
    |> Map.put(:height, height)
    |> Map.put(:width, width)
    |> Map.put(:link_to, parse_link(json[:linkTo]))
  end

  defp get_publication_dates(fpb, lpb) do
    first = parse_pub_date(fpb)
    last = parse_pub_date(lpb)

    {first, last}
  end

  defp parse_pub_date(date) when is_binary(date) do
    case DateTime.from_iso8601(date) do
      {:ok, date, 0} -> date
      {:error, _} -> nil
    end
  end

  defp parse_pub_date(nil), do: nil
end
