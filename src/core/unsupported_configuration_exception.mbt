///|
pub(all) struct UnsupportedConfigurationException {
  message : String?
  cause : String?
}

///|
pub fn new_unsupported_configuration_exception() -> UnsupportedConfigurationException {
  { message: None, cause: None }
}

///|
pub fn new_unsupported_configuration_exception_message(
  message : String,
) -> UnsupportedConfigurationException {
  { message: Some(message), cause: None }
}

///|
pub fn new_unsupported_configuration_exception_message_cause(
  message : String,
  cause : String,
) -> UnsupportedConfigurationException {
  { message: Some(message), cause: Some(cause) }
}

///|
pub fn UnsupportedConfigurationException::get_message(
  self : UnsupportedConfigurationException,
) -> String? {
  self.message
}

///|
pub fn UnsupportedConfigurationException::get_cause(
  self : UnsupportedConfigurationException,
) -> String? {
  self.cause
}
