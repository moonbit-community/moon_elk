///|
pub suberror JsonImportException {
  JsonImportException(String?, String?)
} derive(Debug, ToJson)

///|
pub fn new_json_import_exception() -> JsonImportException {
  JsonImportException(None, None)
}

///|
pub fn new_json_import_exception_message(
  message : String,
) -> JsonImportException {
  JsonImportException(Some(message), None)
}

///|
pub fn new_json_import_exception_cause(cause : String) -> JsonImportException {
  JsonImportException(None, Some(cause))
}

///|
pub fn new_json_import_exception_message_cause(
  message : String,
  cause : String,
) -> JsonImportException {
  JsonImportException(Some(message), Some(cause))
}

///|
pub fn JsonImportException::get_message(self : JsonImportException) -> String? {
  match self {
    JsonImportException(message, _) => message
  }
}

///|
pub fn JsonImportException::get_cause(self : JsonImportException) -> String? {
  match self {
    JsonImportException(_, cause) => cause
  }
}
