///|
pub(all) struct IGraphElementVisitor {
  visit_fn : (@graph.ElkNode) -> Unit
}

///|
pub fn new_graph_element_visitor(
  visit_fn : (@graph.ElkNode) -> Unit,
) -> IGraphElementVisitor {
  { visit_fn, }
}

///|
pub fn IGraphElementVisitor::visit(
  self : IGraphElementVisitor,
  element : @graph.ElkNode,
) -> Unit {
  (self.visit_fn)(element)
}
