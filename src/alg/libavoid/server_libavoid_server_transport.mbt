///|
pub struct LibavoidServerTransport {
  run_fn : (Array[Int], Int) -> Map[String, String]? raise
}

///|
pub fn new_libavoid_server_transport(
  run_fn : (Array[Int], Int) -> Map[String, String]? raise,
) -> LibavoidServerTransport {
  { run_fn, }
}

///|
pub fn LibavoidServerTransport::run(
  self : LibavoidServerTransport,
  input : Array[Int],
  timeout : Int,
) -> Map[String, String]? raise {
  (self.run_fn)(input, timeout)
}

///|
pub fn new_libavoid_server_transport_from_text_runner(
  run_fn : (Array[Int], Int) -> String? raise,
) -> LibavoidServerTransport {
  new_libavoid_server_transport((input, timeout) => {
    match run_fn(input, timeout) {
      Some(output) => Some(libavoid_parse_server_output(output))
      None => None
    }
  })
}
