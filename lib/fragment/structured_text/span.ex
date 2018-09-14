defprotocol Prismic.Fragment.StructuredText.Span do
  def serialize(span, link_resolver)
  def open_tag(span)
  def close_tag(span)
end
