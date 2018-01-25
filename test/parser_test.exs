defmodule Prismic.ParserTest do
  use ExUnit.Case

  describe "parsing web links" do
    test "parses web link within structured text" do
      text = %{
        type: "StructuredText",
        value: [
          %{
            spans: [
              %{
                data: %{type: "Link.web", value: %{url: "https://prismic.io"}},
                end: 0,
                start: 4,
                type: "hyperlink"
              }
            ],
            text: "Who's the boom king?",
            type: "paragraph"
          }
        ]
      }

      parsed = Prismic.Parser.parse_structured_text(text)

      assert parsed == %Prismic.Fragment.StructuredText{
               blocks: [
                 %Prismic.Fragment.StructuredText.Block.Text.Paragraph{
                   label: nil,
                   spans: [
                     %Prismic.Fragment.StructuredText.Span.Hyperlink{
                       end: 0,
                       link: %Prismic.Fragment.WebLink{target: nil, url: "https://prismic.io"},
                       start: 4
                     }
                   ],
                   text: "Who's the boom king?"
                 }
               ]
             }
    end

    test "parses http link fragments" do
      parsed =
        %{type: "Link.web", value: %{url: "https://general.com"}}
        |> Prismic.Parser.parse_web_link()

      assert parsed == %Prismic.Fragment.WebLink{
               target: nil,
               url: "https://general.com"
             }
    end
  end
end
