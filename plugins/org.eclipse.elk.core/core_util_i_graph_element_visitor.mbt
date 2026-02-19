///|
pub struct IGraphElementVisitor {
  visit_fn : (ElkNode) -> Unit
}

///|
pub fn new_graph_element_visitor(
  visit_fn : (ElkNode) -> Unit,
) -> IGraphElementVisitor {
  { visit_fn, }
}

///|
pub fn IGraphElementVisitor::visit(
  self : IGraphElementVisitor,
  element : ElkNode,
) -> Unit {
  (self.visit_fn)(element)
}
