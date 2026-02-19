///|
pub let graph_text_reference_elk_edge_section_outgoing_sections : String = "ELK_EDGE_SECTION__OUTGOING_SECTIONS"

///|
pub struct AbstractElkGraphScopeProvider {
  marker : Unit
}

///|
pub fn new_abstract_elk_graph_scope_provider() -> AbstractElkGraphScopeProvider {
  { marker: () }
}

///|
pub fn AbstractElkGraphScopeProvider::get_scope(
  self : AbstractElkGraphScopeProvider,
  _context : ElkEdgeSection,
  _reference : String,
) -> Array[String] {
  ignore(self)
  []
}
