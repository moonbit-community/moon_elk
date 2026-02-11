///|
pub struct ElkGraphJsonJsonTextUtil {
  marker : Unit
}

///|
pub fn new_elk_graph_json_json_text_util() -> ElkGraphJsonJsonTextUtil {
  { marker: () }
}

///|
fn graph_json_text_util_algorithm_node_for_label_parent(
  parent : ElkLabelParent,
) -> ElkNode? {
  match parent {
    NodeLabelParent(node) =>
      match node_parent(node) {
        Some(parent_node) => Some(parent_node)
        None => Some(node)
      }
    PortLabelParent(port) =>
      match port_parent(port) {
        Some(port_parent_node) =>
          match node_parent(port_parent_node) {
            Some(parent_node) => Some(parent_node)
            None => Some(port_parent_node)
          }
        None => None
      }
    EdgeLabelParent(edge) => edge_containing_node(edge)
    LabelLabelParent(label) =>
      match label_parent(label) {
        Some(label_parent_value) =>
          graph_json_text_util_algorithm_node_for_label_parent(
            label_parent_value,
          )
        None => None
      }
  }
}

///|
pub fn elk_graph_json_json_text_util_get_algorithm(
  element : GraphJsonTextElement,
) -> LayoutAlgorithmData? {
  let node = match element {
    GraphJsonTextNode(node) => Some(node)
    GraphJsonTextPort(port) =>
      match port_parent(port) {
        Some(parent_node) =>
          match node_parent(parent_node) {
            Some(grand_parent) => Some(grand_parent)
            None => Some(parent_node)
          }
        None => None
      }
    GraphJsonTextEdge(edge) => edge_containing_node(edge)
    GraphJsonTextLabel(label) =>
      match label_parent(label) {
        Some(parent_value) =>
          graph_json_text_util_algorithm_node_for_label_parent(parent_value)
        None => None
      }
  }
  match node {
    Some(container_node) =>
      match
        node_layout_option_string_value(container_node, algorithm.get_id()) {
        Some(algorithm_id) =>
          if algorithm_id == "" {
            None
          } else {
            layout_meta_data_service_get_algorithm_data_by_suffix(algorithm_id)
          }
        None => None
      }
    None => None
  }
}
