///|
pub struct GraphValidator {
  issues : Array[GraphIssue]
}

///|
pub fn new_graph_validator() -> GraphValidator {
  { issues: [] }
}

///|
fn append_issues(
  target : Array[GraphIssue],
  issues : Array[GraphIssue],
) -> Unit {
  for issue in issues {
    target.push(issue)
  }
}

///|
fn maybe_algorithm_id(node : ElkNode) -> String? {
  let id = node_get_string_property(node, resolved_algorithm)
  if id.is_empty() {
    None
  } else {
    Some(id)
  }
}

///|
fn run_algorithm_specific_validation(
  validator : GraphValidator,
  node : ElkNode,
  algorithm_id : String,
) -> Unit {
  match layout_meta_data_service_get_algorithm_data(algorithm_id) {
    Some(algorithm_data) =>
      match algorithm_data.get_validator() {
        Some(visit_algorithm) =>
          append_issues(validator.issues, visit_algorithm(node))
        None => ()
      }
    None => ()
  }
}

///|
pub fn GraphValidator::visit(self : GraphValidator, node : ElkNode) -> Unit {
  for edge in node_contained_edges(node) {
    if !edge_is_connected(edge) {
      self.issues.push(
        new_graph_issue_edge(edge, "Edge is not connected.", issue_error),
      )
    }
  }
  let parent_algorithm_id = match node_parent(node) {
    Some(parent) => maybe_algorithm_id(parent)
    None => None
  }
  if parent_algorithm_id is Some(parent_id) {
    run_algorithm_specific_validation(self, node, parent_id)
  }
  if maybe_algorithm_id(node) is Some(local_id) {
    if parent_algorithm_id is None || parent_algorithm_id != Some(local_id) {
      run_algorithm_specific_validation(self, node, local_id)
    }
  }
}

///|
pub fn GraphValidator::get_issues(self : GraphValidator) -> Array[GraphIssue] {
  self.issues.copy()
}

///|
pub fn GraphValidator::to_visitor(
  self : GraphValidator,
) -> IGraphElementVisitor {
  new_graph_element_visitor(node => self.visit(node))
}
