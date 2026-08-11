///|
pub(all) struct ElkGraphResourceFactory {
  metadata : OptionMetadata
  initialized : Bool
}

///|
pub fn new_elk_graph_resource_factory(
  metadata : OptionMetadata,
) -> ElkGraphResourceFactory {
  { metadata, initialized: true }
}

///|
pub fn ElkGraphResourceFactory::create_resource(
  self : ElkGraphResourceFactory,
  uri : String,
) -> ElkGraphResource {
  ignore(self.initialized)
  new_elk_graph_resource(self.metadata, uri)
}
