///|
pub struct IValidatingGraphElementVisitor {
  visitor : IGraphElementVisitor
  get_issues_fn : () -> Array[GraphIssue]
}

///|
pub fn new_validating_graph_element_visitor(
  visit_fn : (ElkNode) -> Unit,
  get_issues_fn : () -> Array[GraphIssue],
) -> IValidatingGraphElementVisitor {
  { visitor: new_graph_element_visitor(visit_fn), get_issues_fn }
}

///|
pub fn IValidatingGraphElementVisitor::visit(
  self : IValidatingGraphElementVisitor,
  element : ElkNode,
) -> Unit {
  self.visitor.visit(element)
}

///|
pub fn IValidatingGraphElementVisitor::get_issues(
  self : IValidatingGraphElementVisitor,
) -> Array[GraphIssue] {
  (self.get_issues_fn)().copy()
}

///|
pub fn IValidatingGraphElementVisitor::to_visitor(
  self : IValidatingGraphElementVisitor,
) -> IGraphElementVisitor {
  self.visitor
}
