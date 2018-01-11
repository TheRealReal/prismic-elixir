defprotocol Prismic.Fragment.StructuredText.Span do
  def serialize(span, link_resolver)
end
