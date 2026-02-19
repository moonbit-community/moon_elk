///|
pub struct GraphvizException {
  message : String
  cause : String?
}

///|
pub fn new_graphviz_exception(message : String) -> GraphvizException {
  { message, cause: None }
}

///|
pub fn new_graphviz_exception_with_cause(
  message : String,
  cause : String,
) -> GraphvizException {
  { message, cause: Some(cause) }
}

///|
pub fn GraphvizException::get_message(self : GraphvizException) -> String {
  self.message
}

///|
pub fn GraphvizException::get_cause(self : GraphvizException) -> String? {
  self.cause
}

///|
pub fn GraphvizException::to_string(self : GraphvizException) -> String {
  match self.cause {
    Some(cause) => self.message + ": " + cause
    None => self.message
  }
}
