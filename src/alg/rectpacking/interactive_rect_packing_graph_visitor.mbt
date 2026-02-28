///|
pub struct InteractiveRectPackingGraphVisitor {
  visitor : @core.IGraphElementVisitor
}

///|
fn rectpacking_set_interactive_options(root : @graph.ElkNode) -> Unit {
  let algorithm_value = @graph.node_get_string_property(root, @core.algorithm)
  if !algorithm_value.is_empty() &&
    rectpacking_algorithm_id.has_suffix(algorithm_value) &&
    !@graph.node_children(root).is_empty() {
    @graph.node_set_bool_property(root, rectpacking_interactive, true)
  }
}

///|
pub fn new_interactive_rectpacking_graph_visitor() -> InteractiveRectPackingGraphVisitor {
  {
    visitor: @core.new_graph_element_visitor(root => {
      rectpacking_set_interactive_options(root)
    }),
  }
}

///|
pub fn InteractiveRectPackingGraphVisitor::visit(
  self : InteractiveRectPackingGraphVisitor,
  element : @graph.ElkNode,
) -> Unit {
  self.visitor.visit(element)
}

///|
pub fn InteractiveRectPackingGraphVisitor::set_interactive_options(
  self : InteractiveRectPackingGraphVisitor,
  root : @graph.ElkNode,
) -> Unit {
  ignore(self)
  rectpacking_set_interactive_options(root)
}
