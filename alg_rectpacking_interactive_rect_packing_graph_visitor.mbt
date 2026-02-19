///|
pub struct InteractiveRectPackingGraphVisitor {
  visitor : IGraphElementVisitor
}

///|
fn rectpacking_set_interactive_options(root : ElkNode) -> Unit {
  let algorithm_value = node_get_string_property(root, algorithm)
  if !algorithm_value.is_empty() &&
    rectpacking_algorithm_id.has_suffix(algorithm_value) &&
    !node_children(root).is_empty() {
    node_set_bool_property(root, rectpacking_interactive, true)
  }
}

///|
pub fn new_interactive_rectpacking_graph_visitor() -> InteractiveRectPackingGraphVisitor {
  {
    visitor: new_graph_element_visitor(root => {
      rectpacking_set_interactive_options(root)
    }),
  }
}

///|
pub fn InteractiveRectPackingGraphVisitor::visit(
  self : InteractiveRectPackingGraphVisitor,
  element : ElkNode,
) -> Unit {
  self.visitor.visit(element)
}

///|
pub fn InteractiveRectPackingGraphVisitor::set_interactive_options(
  self : InteractiveRectPackingGraphVisitor,
  root : ElkNode,
) -> Unit {
  ignore(self)
  rectpacking_set_interactive_options(root)
}
