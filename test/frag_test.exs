defmodule Prismic.FragText do
  use ExUnit.Case
  alias Prismic.Fragment.StructuredText.Block.Text.Paragraph
  alias Prismic.Fragment.StructuredText.Span.{Em, Strong, Hyperlink}

  describe "structured text render" do
    defp render_para(spans, text \\ "abc") do
      st = %Prismic.Fragment.StructuredText{
        blocks: [
          %Paragraph{
            label: nil,
            spans: spans,
            text: text
          }
        ]
      }

      Prismic.Fragment.as_html(st, nil)
    end

    test "renders em" do
      spans = [
        %Em{end: 3, start: 0}
      ]

      assert ~s(<p><i>abc</i></p>) == render_para(spans)
    end

    test "renders strong" do
      spans = [
        %Strong{end: 3, start: 0}
      ]

      assert ~s(<p><b>abc</b></p>) == render_para(spans)
    end

    test "renders link" do
      spans = [
        %Hyperlink{end: 3, start: 0, link: "somelink"}
      ]

      assert ~s(<p><a href="somelink">abc</a></p>) == render_para(spans)
    end

    test "renders multiple" do
      spans = [
        %Em{end: 3, start: 0},
        %Em{end: 6, start: 4}
      ]

      text = "abcdef"
      assert ~s(<p><i>abc</i>d<i>ef</i></p>) == render_para(spans, text)
    end

    test "handles nesting" do
      spans = [
        %Em{end: 6, start: 0},
        %Strong{end: 5, start: 3}
      ]

      text = "abcdef"
      assert ~s(<p><i>abc<b>de</b>f</i></p>) == render_para(spans, text)
    end

    test "ignores starts longer than input" do
      spans = [
        %Em{end: 6, start: 999}
      ]

      assert ~s(<p>abc</p>) == render_para(spans)
    end

    test "closes tag if end greater than input" do
      spans = [
        %Em{end: 999, start: 0}
      ]

      assert ~s(<p><i>abc</i></p>) == render_para(spans)
    end

    test "can do single characters" do
      spans = [
        %Em{end: 2, start: 1}
      ]

      assert ~s(<p>a<i>b</i>c</p>) == render_para(spans)
    end

    test "can do middle" do
      spans = [
        %Em{end: 4, start: 2}
      ]

      text = "abcdef"
      assert ~s(<p>ab<i>cd</i>ef</p>) == render_para(spans, text)
    end

    test "leaves tags balanced" do
      spans = [
        %Em{end: 3, start: 0},
        %Strong{end: 3, start: 0}
      ]

      assert ~s(<p><i><b>abc</b></i></p>) == render_para(spans)
    end
  end
end
