///|
pub struct JsonImportException {
  message : String?
  cause : String?
}

///|
pub fn new_json_import_exception() -> JsonImportException {
  { message: None, cause: None }
}

///|
pub fn new_json_import_exception_message(
  message : String,
) -> JsonImportException {
  { message: Some(message), cause: None }
}

///|
pub fn new_json_import_exception_cause(cause : String) -> JsonImportException {
  { message: None, cause: Some(cause) }
}

///|
pub fn new_json_import_exception_message_cause(
  message : String,
  cause : String,
) -> JsonImportException {
  { message: Some(message), cause: Some(cause) }
}

///|
pub fn JsonImportException::get_message(self : JsonImportException) -> String? {
  self.message
}

///|
pub fn JsonImportException::get_cause(self : JsonImportException) -> String? {
  self.cause
}
