///|
pub(all) struct UnsupportedGraphException {
  message : String?
  cause : String?
}

///|
pub fn new_unsupported_graph_exception() -> UnsupportedGraphException {
  { message: None, cause: None }
}

///|
pub fn new_unsupported_graph_exception_message(
  message : String,
) -> UnsupportedGraphException {
  { message: Some(message), cause: None }
}

///|
pub fn new_unsupported_graph_exception_message_cause(
  message : String,
  cause : String,
) -> UnsupportedGraphException {
  { message: Some(message), cause: Some(cause) }
}

///|
pub fn UnsupportedGraphException::get_message(
  self : UnsupportedGraphException,
) -> String? {
  self.message
}

///|
pub fn UnsupportedGraphException::get_cause(
  self : UnsupportedGraphException,
) -> String? {
  self.cause
}
