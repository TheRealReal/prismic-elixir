defmodule Prismic.SearchFormTest do
  use ExUnit.Case

  import Prismic.SearchForm, only: [set_query_predicates: 2]

  alias ExUnit.CaptureLog
  alias Prismic.{Predicate, Ref, SearchForm}

  @api Prismic.Factory.build(:api)
  @everything_form @api.forms[:everything]

  describe "from_api/3" do
    test "returns a `SearchForm` using the API form with the given name" do
      search_form = SearchForm.from_api(@api, :everything, %{})
      assert %SearchForm{} = search_form
      assert search_form.form == @everything_form
    end

    test "returns nil if there's no form with the given name" do
      assert SearchForm.from_api(@api, :not_a_real_name, %{}) == nil
    end
  end

  describe "new/3" do
    test "respects settings for after, fetchLinks, orderings, page, and pageSize" do
      settings = %{
        after: "document_id",
        fetchLinks: "some.link",
        orderings: "[my.object.field]",
        page: "5",
        pageSize: "10"
      }

      search_form = SearchForm.new(@api, @everything_form, settings)
      assert Map.take(search_form.data, Map.keys(settings)) == settings
    end

    test "uses form's defaults for fields which are not provided" do
      api_fields = @everything_form.fields

      defaults = %{
        page: api_fields.page.default,
        pageSize: api_fields.pageSize.default
      }

      search_form = SearchForm.new(@api, @everything_form, %{})
      assert Map.take(search_form.data, [:page, :pageSize]) == defaults
    end

    test "orders documents by last publication date if `:orderings` isn't provided" do
      search_form = SearchForm.new(@api, @everything_form)
      assert search_form.data.orderings == "[document.last_publication_date desc]"
    end

    test "uses preview token as ref if given a preview token" do
      search_form = SearchForm.new(@api, @everything_form, %{preview_token: "preview"})
      assert search_form.data.ref == "preview"
    end

    test "uses preview_token, not ref, if both are given" do
      search_form =
        SearchForm.new(@api, @everything_form, %{ref: "ref", preview_token: "preview"})

      assert search_form.data.ref == "preview"
    end

    test "uses ref directly if it's a Ref struct" do
      search_form = SearchForm.new(@api, @everything_form, %{ref: %Ref{ref: "ref"}})
      assert search_form.data.ref == "ref"
    end

    test "interprets ref as a label if it's a string" do
      search_form = SearchForm.new(@api, @everything_form, %{ref: "Master"})
      assert search_form.data.ref == "WH8MzyoAAGoSGJwT"
    end

    test "throws an error if no ref with the given label exists" do
      CaptureLog.capture_log(fn ->
        assert_raise(RuntimeError, fn ->
          SearchForm.new(@api, @everything_form, %{ref: "Fake Label"})
        end)
      end)
    end

    test "uses master ref by default" do
      search_form = SearchForm.new(@api, @everything_form)
      assert search_form.data.ref == "WH8MzyoAAGoSGJwT"
    end
  end

  describe "get_search_form/3" do
    test "initializes default data from form" do
      search_form = SearchForm.from_api(@api, :arguments)
      refute Enum.empty?(search_form.data[:q])
    end

    test "intializes with passed data" do
      search_form = SearchForm.from_api(@api, :arguments, %{"bacon" => "eggs"})
      assert search_form.data["bacon"] == "eggs"
    end

    test "passed data prioritizes over default data" do
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})
      assert search_form.data[:q] == "eggs"
    end
  end

  describe "submit/1" do
    #TODO: use bypass, which can be removed when http client is injectable
    # and a test http client will not actually submit
    test "defaults to master ref" do

    end

    test "submits to form action with data as query string" do

    end
  end

  describe "set_ref/2" do
    test "sets ref from api" do
      search_form =
        SearchForm.from_api(@api, :arguments, %{q: "eggs", ref: %Ref{ref: "some_ref"}})

      reffed = SearchForm.set_ref(search_form, "Master")
      assert reffed.data[:ref] == "WH8MzyoAAGoSGJwT"
    end

    test "raises ref not found error" do
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})

      assert_raise RuntimeError, fn ->
        SearchForm.set_ref(search_form, "not a ref")
      end
    end
  end

  describe "set_orderings/2" do
    test "sets the given ordering" do
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})

      orderings = SearchForm.set_orderings(search_form, "[document.first_publication_date]")
      assert orderings.data[:orderings] == "[document.first_publication_date]"
    end

    test "sets the default ordering if it receives blank" do
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})

      orderings = SearchForm.set_orderings(search_form, "")
      assert orderings.data[:orderings] == "[document.last_publication_date desc]"
    end

    test "sets the default ordering if it receives nil" do
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})

      orderings = SearchForm.set_orderings(search_form, nil)
      assert orderings.data[:orderings] == "[document.last_publication_date desc]"
    end
  end

  describe "finalize_query/1" do
    import SearchForm, only: [finalize_query: 1]
    test "makes string version of a list" do
      assert finalize_query(["a"]) == "[a]"
    end

    test "no op on non-lists" do
      assert finalize_query(1) == 1
      assert finalize_query("a") == "a"
    end
  end

  describe "set_data_field/3" do
    import SearchForm, only: [set_data_field: 3, new: 2]

    setup do
      search_form = SearchForm.from_api(@api)
      {:ok, search_form: search_form}
    end

    test "sets fields tagged multiple by concatenation", %{search_form: search_form} do
      assert set_data_field(search_form, :q, 1).data[:q] == [1]
      double_updated =
        search_form
        |> set_data_field(:q, 1)
        |> set_data_field(:q, 2)

      assert double_updated.data[:q] == [2, 1]
    end

    test "sets non multiple fields by replacement", %{search_form: search_form} do
      assert set_data_field(search_form, :ref, 1).data[:ref] == 1
      double_updated =
        search_form
        |> set_data_field(:ref, 1)
        |> set_data_field(:ref, 2)

      assert double_updated.data[:ref] == 2
    end
  end

  describe "set_predicates/2 without default query" do
    import SearchForm, only: [set_query_predicates: 2]

    test "adds single query to everything form" do
      search_form = SearchForm.from_api(@api)

      predicate = Predicate.at("document.id", "UrjI1gEAALOCeO5i")
      updated_search_form = set_query_predicates(search_form, [predicate])
      assert updated_search_form.data[:q] == [~s{[:d = at(document.id, "UrjI1gEAALOCeO5i")]}]
    end
  end

  describe "set_predicates/2 with default query" do

    setup do
      {:ok, search_form: SearchForm.from_api(@api, :arguments)}
    end

    test "adds single query to form with default values", %{search_form: search_form}  do
      predicate = Predicate.at("document.id", "UrjI1gEAALOCeO5i")
      updated_search_form = set_query_predicates(search_form, [predicate])

      assert updated_search_form.data[:q] == [
        ~s{[:d = at(document.id, "UrjI1gEAALOCeO5i")]},
        ~s{[:d = any(document.type, ["argument"])]}
      ]
    end

    test "adds multiple queries to form with default value", %{search_form: search_form}  do
      predicate = Predicate.at("document.id", "UrjI1gEAALOCeO5i")
      predicate2 = Predicate.at("document.type", "eggs")

      updated_search_form = set_query_predicates(search_form, [predicate, predicate2])
      assert updated_search_form.data[:q] == [
        ~s{[:d = at(document.id, "UrjI1gEAALOCeO5i")]},
        ~s{[:d = at(document.type, "eggs")]},
        ~s{[:d = any(document.type, ["argument"])]}
      ]
    end
  end

end
