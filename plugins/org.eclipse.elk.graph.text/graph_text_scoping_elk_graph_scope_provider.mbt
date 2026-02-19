///|
pub struct ElkGraphScopeProvider {
  base : AbstractElkGraphScopeProvider
}

///|
pub fn new_elk_graph_scope_provider(
  base? : AbstractElkGraphScopeProvider = new_abstract_elk_graph_scope_provider(),
) -> ElkGraphScopeProvider {
  { base, }
}

///|
fn graph_text_scope_find_parent_edge(section : ElkEdgeSection) -> ElkEdge? {
  for edge in all_edges() {
    for candidate in edge_sections(edge) {
      if candidate == section {
        return Some(edge)
      }
    }
  }
  None
}

///|
fn graph_text_scope_for_edge_section(section : ElkEdgeSection) -> Array[String] {
  match graph_text_scope_find_parent_edge(section) {
    Some(edge) => {
      let names : Array[String] = []
      for candidate in edge_sections(edge) {
        let id = edge_section_identifier(candidate)
        if id != "" {
          names.push(id)
        }
      }
      names
    }
    None => []
  }
}

///|
pub fn ElkGraphScopeProvider::get_scope(
  self : ElkGraphScopeProvider,
  context : ElkEdgeSection,
  reference : String,
) -> Array[String] {
  if reference == graph_text_reference_elk_edge_section_outgoing_sections {
    graph_text_scope_for_edge_section(context)
  } else {
    self.base.get_scope(context, reference)
  }
}
