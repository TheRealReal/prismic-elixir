defmodule Prismic.SearchFormTest do
  use ExUnit.Case

  alias Prismic.{Predicate, SearchForm}
  import SearchForm, only: [set_query_predicates: 2]

  @api Prismic.Factory.build(:api)

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
      search_form = SearchForm.from_api(@api, :arguments, %{:q => "eggs"})

      assert is_nil(search_form.data[:ref])
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
      assert is_nil(search_form.data[:ref])
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
