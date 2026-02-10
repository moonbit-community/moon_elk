///|
pub enum LibavoidServerCleanup {
  LibavoidServerCleanupNormal
  LibavoidServerCleanupError
  LibavoidServerCleanupStop
}

///|
pub fn libavoid_server_cleanup_normal() -> LibavoidServerCleanup {
  LibavoidServerCleanupNormal
}

///|
pub fn libavoid_server_cleanup_error() -> LibavoidServerCleanup {
  LibavoidServerCleanupError
}

///|
pub fn libavoid_server_cleanup_stop() -> LibavoidServerCleanup {
  LibavoidServerCleanupStop
}

///|
pub let libavoid_server_process_def_timeout : Int = 60000

///|
pub struct LibavoidServer {
  mut running : Bool
  mut canceled : Bool
  mut process_timeout : Int
  input_sink : GraphvizByteArrayOutputStream
}

///|
pub fn new_libavoid_server() -> LibavoidServer {
  {
    running: false,
    canceled: false,
    process_timeout: libavoid_server_process_def_timeout,
    input_sink: new_graphviz_byte_array_output_stream(),
  }
}

///|
pub fn LibavoidServer::initialize(self : LibavoidServer) -> Unit {
  self.running = true
  self.canceled = false
}

///|
pub fn LibavoidServer::set_process_timeout(
  self : LibavoidServer,
  timeout : Int,
) -> Unit {
  self.process_timeout = timeout
}

///|
pub fn LibavoidServer::get_process_timeout(self : LibavoidServer) -> Int {
  self.process_timeout
}

///|
pub fn LibavoidServer::input(self : LibavoidServer) -> GraphvizOutputStream {
  if !self.running {
    abort("Libavoid server has not been initialized.")
  }
  self.input_sink.as_output_stream()
}

///|
pub fn LibavoidServer::read_output_data(
  self : LibavoidServer,
) -> Map[String, String]? {
  if !self.running {
    abort("Libavoid server has not been initialized.")
  }
  Some({})
}

///|
fn libavoid_server_cleanup_is_stop_or_error(
  mode : LibavoidServerCleanup,
) -> Bool {
  match mode {
    LibavoidServerCleanupError => true
    LibavoidServerCleanupStop => true
    _ => false
  }
}

///|
pub fn LibavoidServer::cleanup(
  self : LibavoidServer,
  cleanup_mode : LibavoidServerCleanup,
) -> Unit {
  if libavoid_server_cleanup_is_stop_or_error(cleanup_mode) {
    self.running = false
  }
}

///|
pub fn LibavoidServer::cancel_process(self : LibavoidServer) -> Unit {
  self.canceled = true
  self.running = false
}

///|
pub fn LibavoidServer::is_running(self : LibavoidServer) -> Bool {
  self.running
}

///|
pub fn LibavoidServer::is_canceled(self : LibavoidServer) -> Bool {
  self.canceled
}

///|
pub fn LibavoidServer::get_input_bytes(self : LibavoidServer) -> Array[Int] {
  self.input_sink.get_bytes()
}
