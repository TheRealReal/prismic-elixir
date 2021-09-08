defmodule Prismic.ParserTest do
  use ExUnit.Case

  alias Prismic.Fragment.{
    Boolean,
    CompositeSlice,
    DocumentLink,
    IntegrationFields,
    StructuredText,
    Text,
    WebLink
  }

  alias Prismic.{Document, Parser}

  @sample_document_result %{
    id: "valid_id",
    uid: "valid_uid",
    type: "page",
    slugs: ["slug1", "slug2"],
    first_publication_date: "2021-07-16T21:06:13+0000",
    last_publication_date: "2021-08-23T19:03:34+0000",
    data: %{
      page: %{
        body: %{
          type: "SliceZone",
          value: [
            %{
              type: "Slice",
              slice_type: "Carousel",
              slice_label: nil,
              repeat: [
                %{
                  image: %{
                    type: "Image",
                    value: %{
                      main: %{
                        dimensions: %{
                          width: 1200,
                          height: 600
                        },
                        alt: nil,
                        copyright: nil,
                        url: "https://images.prismic.io/example-repo/totally-real-image.png"
                      },
                      views: %{}
                    }
                  }
                }
              ],
              "non-repeat": %{
                desktop_only: %{
                  type: "Boolean",
                  value: false
                }
              }
            }
          ]
        }
      }
    }
  }

  describe "parse_document/1" do
    test "parses boolean fragments" do
      assert %Document{
               fragments: %{
                 body: [
                   %CompositeSlice{
                     non_repeat: %{
                       desktop_only: %Boolean{
                         value: false
                       }
                     },
                     repeat: %Prismic.Group{}
                   }
                 ]
               }
             } = Parser.parse_document(@sample_document_result)
    end
  end

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

      parsed = Parser.parse_structured_text(text)

      assert parsed == %StructuredText{
               blocks: [
                 %StructuredText.Block.Text.Paragraph{
                   label: nil,
                   spans: [
                     %StructuredText.Span.Hyperlink{
                       end: 0,
                       link: %WebLink{target: nil, url: "https://prismic.io"},
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
        |> Parser.parse_web_link()

      assert parsed == %WebLink{
               target: nil,
               url: "https://general.com"
             }
    end
  end

  describe "parse_structured_text/1" do
    test "parses spans" do
      text = %{
        type: "StructuredText",
        value: [
          %{
            spans: [
              %{
                start: 0,
                end: 22,
                type: "label",
                data: %{label: "Suisse Intl"}
              },
              %{
                start: 0,
                end: 11,
                type: "em"
              },
              %{
                start: 11,
                end: 22,
                type: "strong"
              }
            ],
            text: "Is there life on Mars?",
            type: "paragraph"
          }
        ]
      }

      parsed = Parser.parse_structured_text(text)

      assert parsed ==
               %Prismic.Fragment.StructuredText{
                 blocks: [
                   %Prismic.Fragment.StructuredText.Block.Text.Paragraph{
                     label: nil,
                     spans: [
                       %Prismic.Fragment.StructuredText.Span.Label{
                         end: 22,
                         label: "Suisse Intl",
                         start: 0
                       },
                       %Prismic.Fragment.StructuredText.Span.Em{end: 11, start: 0},
                       %Prismic.Fragment.StructuredText.Span.Strong{end: 22, start: 11}
                     ],
                     text: "Is there life on Mars?"
                   }
                 ]
               }
    end
  end

  @prismic_document_link %{
    type: "Link.document",
    value: %{
      document: %{
        id: "XBLlVREAACsA5_9J",
        type: "measurement",
        tags: [],
        lang: "en-us",
        slug: "womens-shoulder"
      },
      isBroken: false
    }
  }

  @parsed_document_link %DocumentLink{
    broken: false,
    id: "XBLlVREAACsA5_9J",
    lang: "en-us",
    slug: "womens-shoulder",
    tags: [],
    target: nil,
    type: "measurement",
    uid: nil
  }

  describe "parse_document_link/1" do
    test "translates Prismic v1 response format into DocumentLink struct" do
      assert Parser.parse_document_link(@prismic_document_link) == @parsed_document_link
    end

    test "includes fragments in DocumentLink when Prismic response includes linked data" do
      prismic_data = %{
        measurement: %{
          description: %{
            type: "Text",
            value: "Measured across the back, from shoulder seam to shoulder seam."
          }
        }
      }

      parsed_fragments = [
        description: %Text{
          value: "Measured across the back, from shoulder seam to shoulder seam."
        }
      ]

      prismic_link_with_data =
        put_in(@prismic_document_link, [:value, :document, :data], prismic_data)

      parsed_link_with_data = Map.put(@parsed_document_link, :fragments, parsed_fragments)

      assert Parser.parse_document_link(prismic_link_with_data) == parsed_link_with_data
    end
  end

  @prismic_integration_fields %{
    type: "IntegrationFields",
    value: %{
      a_key: "a value"
    }
  }

  @parsed_integration_fields %IntegrationFields{
    value: %{
      a_key: "a value"
    }
  }

  describe "parse_integration_fields/1" do
    test "translates Prismic v1 response format into IntegrationFields struct" do
      assert Parser.parse_integration_fields(@prismic_integration_fields) ==
               @parsed_integration_fields
    end
  end
end
