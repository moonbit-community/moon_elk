///|
pub struct LibavoidServerException {
  message : String
  cause : String?
}

///|
pub fn new_libavoid_server_exception() -> LibavoidServerException {
  { message: "", cause: None }
}

///|
pub fn new_libavoid_server_exception_with_message(
  message : String,
) -> LibavoidServerException {
  { message, cause: None }
}

///|
pub fn new_libavoid_server_exception_with_cause(
  message : String,
  cause : String,
) -> LibavoidServerException {
  { message, cause: Some(cause) }
}

///|
pub fn LibavoidServerException::get_message(
  self : LibavoidServerException,
) -> String {
  self.message
}

///|
pub fn LibavoidServerException::get_cause(
  self : LibavoidServerException,
) -> String? {
  self.cause
}

///|
pub fn LibavoidServerException::to_string(
  self : LibavoidServerException,
) -> String {
  match self.cause {
    Some(cause) => self.message + ": " + cause
    None => self.message
  }
}
