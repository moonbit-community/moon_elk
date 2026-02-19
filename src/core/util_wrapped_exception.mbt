///|
pub(all) struct WrappedException {
  message : String?
  cause : String
}

///|
pub fn new_wrapped_exception(cause : String) -> WrappedException {
  { message: None, cause }
}

///|
pub fn new_wrapped_exception_message_cause(
  message : String,
  cause : String,
) -> WrappedException {
  { message: Some(message), cause }
}

///|
pub fn WrappedException::get_message(self : WrappedException) -> String? {
  self.message
}

///|
pub fn WrappedException::get_cause(self : WrappedException) -> String {
  self.cause
}
