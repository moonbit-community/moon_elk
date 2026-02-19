///|
pub let graph_json_text_reference_elk_edge_section_outgoing_sections : String = "ELK_EDGE_SECTION__OUTGOING_SECTIONS"

///|
pub struct AbstractElkGraphJsonScopeProvider {
  marker : Unit
}

///|
pub fn new_abstract_elk_graph_json_scope_provider() -> AbstractElkGraphJsonScopeProvider {
  { marker: () }
}

///|
pub fn AbstractElkGraphJsonScopeProvider::get_scope(
  self : AbstractElkGraphJsonScopeProvider,
  _context : ElkEdgeSection,
  _reference : String,
) -> Array[String] {
  ignore(self)
  []
}
