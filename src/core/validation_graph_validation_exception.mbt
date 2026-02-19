///|
pub(all) struct GraphValidationException {
  message : String?
  issues : Array[GraphIssue]?
}

///|
pub fn new_graph_validation_exception() -> GraphValidationException {
  { message: None, issues: None }
}

///|
pub fn new_graph_validation_exception_message(
  message : String,
) -> GraphValidationException {
  { message: Some(message), issues: None }
}

///|
pub fn new_graph_validation_exception_message_issues(
  message : String,
  issues : Array[GraphIssue],
) -> GraphValidationException {
  { message: Some(message), issues: Some(issues.copy()) }
}

///|
pub fn GraphValidationException::get_message(
  self : GraphValidationException,
) -> String? {
  self.message
}

///|
pub fn GraphValidationException::get_issues(
  self : GraphValidationException,
) -> Array[GraphIssue]? {
  match self.issues {
    Some(issues) => Some(issues.copy())
    None => None
  }
}
