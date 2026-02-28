///|
pub type ElkGraphJsonResource = String

///|
pub type ElkGraphJsonFileSystemAccess2 = String

///|
pub type ElkGraphJsonGeneratorContext = String

///|
pub struct ElkGraphJsonGenerator {
  marker : Unit
}

///|
pub fn new_elk_graph_json_generator() -> ElkGraphJsonGenerator {
  { marker: () }
}

///|
pub fn ElkGraphJsonGenerator::do_generate(
  self : ElkGraphJsonGenerator,
  resource : ElkGraphJsonResource,
  fsa : ElkGraphJsonFileSystemAccess2,
  context : ElkGraphJsonGeneratorContext,
) -> Unit {
  ignore(self)
  ignore(resource)
  ignore(fsa)
  ignore(context)
}
