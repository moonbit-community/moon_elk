///|
pub(all) struct IGraphElementVisitor {
  visit_fn : (@graph.ElkNode) -> Unit raise
}

///|
pub fn new_graph_element_visitor(
  visit_fn : (@graph.ElkNode) -> Unit raise,
) -> IGraphElementVisitor {
  { visit_fn, }
}

///|
pub fn IGraphElementVisitor::visit(
  self : IGraphElementVisitor,
  element : @graph.ElkNode,
) -> Unit raise {
  (self.visit_fn)(element)
}
