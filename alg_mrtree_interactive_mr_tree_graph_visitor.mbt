///|
pub struct InteractiveMrtreeGraphVisitor {
  marker : Int
}

///|
pub fn new_interactive_mrtree_graph_visitor() -> InteractiveMrtreeGraphVisitor {
  { marker: 0 }
}

///|
fn interactive_mrtree_graph_visitor_algorithm_value(root : ElkNode) -> String? {
  match node_layout_option_string_value(root, algorithm.get_id()) {
    Some(value) => Some(value)
    None =>
      if node_has_string_property(root, algorithm) {
        Some(node_get_string_property(root, algorithm))
      } else {
        None
      }
  }
}

///|
pub fn interactive_mrtree_graph_visitor_set_interactive_options(
  root : ElkNode,
) -> Unit {
  if node_children(root).is_empty() {
    return
  }
  match interactive_mrtree_graph_visitor_algorithm_value(root) {
    Some(configured_algorithm) =>
      if mrtree_algorithm_id.has_suffix(configured_algorithm) {
        node_set_bool_property(root, interactive, true)
        node_set_string_property(root, mrtree_weighting, "CONSTRAINT")
      }
    None => ()
  }
}

///|
pub fn InteractiveMrtreeGraphVisitor::visit(
  self : InteractiveMrtreeGraphVisitor,
  element : ElkNode,
) -> Unit {
  ignore(self)
  interactive_mrtree_graph_visitor_set_interactive_options(element)
}

///|
pub fn new_interactive_mrtree_graph_element_visitor() -> IGraphElementVisitor {
  let visitor = new_interactive_mrtree_graph_visitor()
  new_graph_element_visitor(fn(element : ElkNode) { visitor.visit(element) })
}
