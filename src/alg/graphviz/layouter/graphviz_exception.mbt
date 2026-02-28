///|
pub suberror GraphvizException {
  GraphvizException(String, String?)
} derive(Show, ToJson)

///|
pub fn new_graphviz_exception(message : String) -> GraphvizException {
  GraphvizException(message, None)
}

///|
pub fn new_graphviz_exception_with_cause(
  message : String,
  cause : String,
) -> GraphvizException {
  GraphvizException(message, Some(cause))
}

///|
pub fn GraphvizException::get_message(self : GraphvizException) -> String {
  match self {
    GraphvizException(message, _) => message
  }
}

///|
pub fn GraphvizException::get_cause(self : GraphvizException) -> String? {
  match self {
    GraphvizException(_, cause) => cause
  }
}

///|
pub fn GraphvizException::to_string(self : GraphvizException) -> String {
  match self {
    GraphvizException(message, Some(cause)) => message + ": " + cause
    GraphvizException(message, None) => message
  }
}
