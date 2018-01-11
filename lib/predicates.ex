defmodule Prismic.Predicate do
  @moduledoc """
  Predicates are for generating the queries supported by the prismic api.
  They take the form of a list where the first element is the operator ( think from or where in sql).
  The second element "fragment" points to a "key" that a prismic document may have, such as "document.type" or "my.product.price".
  The rest of the elements are like "arguments" to the operator ( there can be 0 to unlimited remaining elements, though 3 elements is the largest and 0 is smallest )
  e.g ["number.lt", "my.product.price", 2, 10] will generate a query for documents with the field product price between two and ten.
  A query can support several predicates that are chained in an AND fashion
  Queries are added to a search form, which is then submitted.
  """

  def at(fragment, value) do
    ["at", fragment, value]
  end

  # "not" is not a valid elixir function name
  def where_not(fragment, value) do
    ["not", fragment, value]
  end

  # "in" is not a valid elixir function name
  def where_in(fragment, value) do
    ["in", fragment, value]
  end

  def any(fragment, values) do
    ["any", fragment, values]
  end

  def fulltext(fragment, values) do
    ["fulltext", fragment, values]
  end

  def similar(fragment, value) do
    ["similar", fragment, value]
  end

  def has(fragment) do
    ["has", fragment]
  end

  def missing(fragment) do
    ["missing", fragment]
  end

  def gt(fragment, value) do
    ["number.gt", fragment, value]
  end

  def lt(fragment, value) do
    ["number.lt", fragment, value]
  end

  def in_range(fragment, start, finish) do
    ["number.inRange", fragment, start, finish]
  end

  # punting on handling dates
  # def date_before(fragment, before) do
  #   ["date.before", fragment, as_timestamp(before)]
  # end

  # def date_after(fragment, after) do
  #   ["date.after", fragment, as_timestamp(after)]
  # end

  # def date_between(fragment, before, after) do
  #   ["date.between", fragment, as_timestamp(before), as_timestamp(after)]
  # end

  def day_of_month(fragment, day) do
    ["date.day-of-month", fragment, day]
  end

  def day_of_month_after(fragment, day) do
    ["date.day-of-month-after", fragment, day]
  end

  def day_of_month_before(fragment, day) do
    ["date.day-of-month-before", fragment, day]
  end

  def day_of_week(fragment, day) do
    ["date.day-of-week", fragment, day]
  end

  def day_of_week_after(fragment, day) do
    ["date.day-of-week-after", fragment, day]
  end

  def day_of_week_before(fragment, day) do
    ["date.day-of-week-before", fragment, day]
  end

  def month(fragment, month) do
    ["date.month", fragment, month]
  end

  def month_before(fragment, month) do
    ["date.month-before", fragment, month]
  end

  def month_after(fragment, month) do
    ["date.month-after", fragment, month]
  end

  def year(fragment, year) do
    ["date.year", fragment, year]
  end

  def year_before(fragment, year) do
    ["date.year-before", fragment, year]
  end

  def year_after(fragment, year) do
    ["date.year-after", fragment, year]
  end

  def hour(fragment, hour) do
    ["date.hour", fragment, hour]
  end

  def hour_before(fragment, hour) do
    ["date.hour-before", fragment, hour]
  end

  def hour_after(fragment, hour) do
    ["date.hour-after", fragment, hour]
  end

  def near(fragment, latitude, longitude, radius) do
    ["geopoint.near", fragment, latitude, longitude, radius]
  end

  @doc "turn predicate into query string for primic.io"
  def to_query([operator, path]), do: "[:d = #{operator}(#{path})]"

  def to_query([operator, path | values]) do
    serialized_values = Enum.map_join(values, ", ", &serialize_field/1)
    "[:d = #{operator}(#{path}, #{serialized_values})]"
  end

  # helper for maintaining "types" when generating query strings
  defp serialize_field(field) when is_binary(field), do: ~s("#{field}")

  defp serialize_field(field) when is_list(field) do
    internal_serialization = Enum.map_join(field, ", ", &serialize_field/1)
    "[" <> internal_serialization <> "]"
  end

  defp serialize_field(field), do: field
  def finalize_query(query), do: serialize_field(query)
end
