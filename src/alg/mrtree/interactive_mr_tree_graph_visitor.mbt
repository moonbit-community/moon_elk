///|
pub struct InteractiveMrtreeGraphVisitor {
  marker : Int
}

///|
pub fn new_interactive_mrtree_graph_visitor() -> InteractiveMrtreeGraphVisitor {
  { marker: 0 }
}

///|
fn interactive_mrtree_graph_visitor_algorithm_value(
  root : @graph.ElkNode,
) -> String? {
  match @graph.node_layout_option_string_value(root, @core.algorithm.get_id()) {
    Some(value) => Some(value)
    None =>
      if @graph.node_has_string_property(root, @core.algorithm) {
        Some(@graph.node_get_string_property(root, @core.algorithm))
      } else {
        None
      }
  }
}

///|
pub fn interactive_mrtree_graph_visitor_set_interactive_options(
  root : @graph.ElkNode,
) -> Unit {
  if @graph.node_children(root).is_empty() {
    return
  }
  match interactive_mrtree_graph_visitor_algorithm_value(root) {
    Some(configured_algorithm) =>
      if mrtree_algorithm_id.has_suffix(configured_algorithm) {
        @graph.node_set_bool_property(root, @core.interactive, true)
        @graph.node_set_string_property(root, mrtree_weighting, "CONSTRAINT")
      }
    None => ()
  }
}

///|
pub fn InteractiveMrtreeGraphVisitor::visit(
  self : InteractiveMrtreeGraphVisitor,
  element : @graph.ElkNode,
) -> Unit {
  ignore(self)
  interactive_mrtree_graph_visitor_set_interactive_options(element)
}

///|
pub fn new_interactive_mrtree_graph_element_visitor() -> @core.IGraphElementVisitor {
  let visitor = new_interactive_mrtree_graph_visitor()
  @core.new_graph_element_visitor(fn(element : @graph.ElkNode) {
    visitor.visit(element)
  })
}
