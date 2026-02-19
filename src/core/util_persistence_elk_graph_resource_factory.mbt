///|
pub(all) struct ElkGraphResourceFactory {
  initialized : Bool
}

///|
pub fn new_elk_graph_resource_factory() -> ElkGraphResourceFactory {
  { initialized: true }
}

///|
pub fn ElkGraphResourceFactory::create_resource(
  self : ElkGraphResourceFactory,
  uri : String,
) -> ElkGraphResource {
  ignore(self.initialized)
  new_elk_graph_resource(uri)
}
