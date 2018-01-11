defmodule Prismic.Response do
  alias Document

  defstruct [
    :page,
    :results_per_page,
    :results_size,
    :total_results_size,
    :total_pages,
    :next_page,
    :prev_page,
    :results
  ]

  @type t :: %__MODULE__{
          page: String.t(),
          results_per_page: Integer.t(),
          results_size: Integer.t(),
          total_results_size: Integer.t(),
          total_pages: Integer.t(),
          next_page: String.t(),
          prev_page: String.t(),
          results: [Document.t()]
        }
end
