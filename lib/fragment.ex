defprotocol Prismic.Fragment do
  @doc """
  Generate usable HTML markup

  - You need to pass a proper link_resolver so that internal links are turned into the proper URL
  """
  def as_html(fragment, link_resolver, html_serializer \\ nil)
end
