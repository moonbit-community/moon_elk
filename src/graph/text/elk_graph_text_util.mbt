///|
pub struct ElkGraphTextUtil {
  marker : Unit
}

///|
pub fn new_elk_graph_text_util() -> ElkGraphTextUtil {
  { marker: () }
}

///|
fn graph_text_util_algorithm_node_for_label_parent(
  parent : @graph.ElkLabelParent,
) -> @graph.ElkNode? {
  match parent {
    NodeLabelParent(node) =>
      match @graph.node_parent(node) {
        Some(parent_node) => Some(parent_node)
        None => Some(node)
      }
    PortLabelParent(port) =>
      match @graph.port_parent(port) {
        Some(port_parent_node) =>
          match @graph.node_parent(port_parent_node) {
            Some(parent_node) => Some(parent_node)
            None => Some(port_parent_node)
          }
        None => None
      }
    EdgeLabelParent(edge) => @graph.edge_containing_node(edge)
    LabelLabelParent(label) =>
      match @graph.label_parent(label) {
        Some(label_parent_value) =>
          graph_text_util_algorithm_node_for_label_parent(label_parent_value)
        None => None
      }
  }
}

///|
pub fn elk_graph_text_util_get_algorithm(
  element : GraphTextElement,
) -> @core.LayoutAlgorithmData? {
  let node = match element {
    GraphNode(node) => Some(node)
    GraphPort(port) =>
      match @graph.port_parent(port) {
        Some(parent_node) =>
          match @graph.node_parent(parent_node) {
            Some(grand_parent) => Some(grand_parent)
            None => Some(parent_node)
          }
        None => None
      }
    GraphEdge(edge) => @graph.edge_containing_node(edge)
    GraphLabel(label) =>
      match @graph.label_parent(label) {
        Some(parent_value) =>
          graph_text_util_algorithm_node_for_label_parent(parent_value)
        None => None
      }
  }
  match node {
    Some(container_node) =>
      match
        @graph.node_layout_option_string_value(container_node, @core.algorithm.get_id()) {
        Some(algorithm_id) =>
          if algorithm_id == "" {
            None
          } else {
            @core.layout_meta_data_service_get_algorithm_data_by_suffix(algorithm_id)
          }
        None => None
      }
    None => None
  }
}
