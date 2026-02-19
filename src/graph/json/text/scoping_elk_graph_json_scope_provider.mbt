///|
pub struct ElkGraphJsonScopeProvider {
  base : AbstractElkGraphJsonScopeProvider
}

///|
pub fn new_elk_graph_json_scope_provider(
  base? : AbstractElkGraphJsonScopeProvider = new_abstract_elk_graph_json_scope_provider(),
) -> ElkGraphJsonScopeProvider {
  { base, }
}

///|
fn graph_json_text_scope_find_parent_edge(
  section : @graph.ElkEdgeSection,
) -> @graph.ElkEdge? {
  for edge in @graph.all_edges() {
    for candidate in @graph.edge_sections(edge) {
      if candidate == section {
        return Some(edge)
      }
    }
  }
  None
}

///|
fn graph_json_text_scope_for_edge_section(
  section : @graph.ElkEdgeSection,
) -> Array[String] {
  match graph_json_text_scope_find_parent_edge(section) {
    Some(edge) => {
      let names : Array[String] = []
      for candidate in @graph.edge_sections(edge) {
        let id = @graph.edge_section_identifier(candidate)
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
pub fn ElkGraphJsonScopeProvider::get_scope(
  self : ElkGraphJsonScopeProvider,
  context : @graph.ElkEdgeSection,
  reference : String,
) -> Array[String] {
  if reference == graph_json_text_reference_elk_edge_section_outgoing_sections {
    graph_json_text_scope_for_edge_section(context)
  } else {
    self.base.get_scope(context, reference)
  }
}
