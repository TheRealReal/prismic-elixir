defmodule Prismic.PredicateTest do
  use ExUnit.Case

  describe "at/2" do
    import Prismic.Predicate, only: [at: 2]
    test "returns at fragement" do
      assert at("document.id", "UrjI1gEAALOCeO5i") == ["at", "document.id", "UrjI1gEAALOCeO5i"]
    end
  end

  describe "where_not/2" do
    import Prismic.Predicate, only: [where_not: 2, to_query: 1]
    test "with document.something" do
      query = where_not("document.id", "UrjI1gEAALOCeO5i")
      |> to_query

      assert query == ~s{[:d = not(document.id, "UrjI1gEAALOCeO5i")]}
    end

    test "with my.something" do
      query = where_not("my.custom-type.uid", "UrjI1gEAALOCeO5i")
      |> to_query

      assert query == ~s{[:d = not(my.custom-type.uid, "UrjI1gEAALOCeO5i")]}
    end
  end

  describe "to_query/1" do
    import Prismic.Predicate, only: [to_query: 1]
    test "serializes value-less queries" do
      query = to_query(["has", "my.blog-post.author"])
      assert query == ~s{[:d = has(my.blog-post.author)]}
    end

    test "serializes number values" do
      query = to_query(["number.inRange", "my.product.price", 2, 10])
      assert query == ~s{[:d = number.inRange(my.product.price, 2, 10)]}
    end

    test "serializes string values" do
      query = to_query(["date.month", "my.blog-post.publication-date", "December"])
      assert query == ~s{[:d = date.month(my.blog-post.publication-date, "December")]}
    end

    test "serializes list values" do
      query = to_query(["fulltext", "document.type", ["article", "blog-post"]])
      assert query == ~s{[:d = fulltext(document.type, ["article", "blog-post"])]}
    end
  end

end
