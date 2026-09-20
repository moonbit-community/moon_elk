///|
priv enum LibavoidServerOutputState {
  Type
  Data
  Error
}

///|
pub suberror LibavoidServerOutputException {
  LibavoidServerOutputException(String)
} derive(Debug, ToJson)

///|
fn[T] libavoid_server_output_raise(
  message : String,
) -> T raise LibavoidServerOutputException {
  raise LibavoidServerOutputException(message)
}

///|
pub fn libavoid_parse_server_output(
  output : String,
) -> Map[String, String] raise LibavoidServerOutputException {
  let data : Map[String, String] = Map([])
  let mut state = Type
  let error = StringBuilder()
  let mut has_error = false
  for raw_line in output.split("\n") {
    let owned = raw_line.to_owned()
    let line = if owned.has_suffix("\r") {
      owned[:owned.length() - 1].to_owned()
    } else {
      owned
    }
    if line.has_prefix("DEBUG") {
      continue
    }
    match state {
      Type =>
        if line == "LAYOUT" {
          state = Data
        } else if line == "ERROR" {
          state = Error
        }
      Data =>
        if line == "DONE" {
          return data
        } else {
          let tokens = line.split("=").to_array()
          if tokens.length() == 2 && !tokens[0].is_empty() {
            data[tokens[0].to_owned()] = tokens[1].to_owned()
          }
        }
      Error =>
        if line == "DONE" {
          libavoid_server_output_raise(error.to_string())
        } else {
          if has_error {
            error.write_char('\n')
          }
          error.write_string(line)
          has_error = true
        }
    }
  }
  libavoid_server_output_raise("Incomplete Libavoid output.")
}

///|
pub fn libavoid_server_output_exception_message(
  error : LibavoidServerOutputException,
) -> String {
  match error {
    LibavoidServerOutputException(message) => message
  }
}

///|
pub extend LibavoidServerOutputException with Debug::{to_repr}

///|
pub extend LibavoidServerOutputException with ToJson::{to_json}
