///|
pub struct InteractiveMrtreeGraphVisitor {
  marker : Int
}

///|
pub fn new_interactive_mrtree_graph_visitor() -> InteractiveMrtreeGraphVisitor {
  { marker: 0 }
}

///|
pub fn interactive_mrtree_graph_visitor_set_interactive_options(
  root : ElkNode,
) -> Unit {
  let configured_algorithm = node_get_string_property(root, algorithm)
  if !configured_algorithm.is_empty() &&
    mrtree_algorithm_id.has_suffix(configured_algorithm) &&
    !node_children(root).is_empty() {
    node_set_bool_property(root, interactive, true)
    node_set_string_property(root, mrtree_weighting, "CONSTRAINT")
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
