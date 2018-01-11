defprotocol Prismic.Fragment.StructuredText.Block do
  def as_html(block, link_resolver, html_serializer)
end
