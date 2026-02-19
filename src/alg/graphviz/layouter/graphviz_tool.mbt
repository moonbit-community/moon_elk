///|
pub enum GraphvizToolCleanup {
  GraphvizCleanupNormal
  GraphvizCleanupError
  GraphvizCleanupStop
}

///|
pub fn graphviz_cleanup_normal() -> GraphvizToolCleanup {
  GraphvizCleanupNormal
}

///|
pub fn graphviz_cleanup_error() -> GraphvizToolCleanup {
  GraphvizCleanupError
}

///|
pub fn graphviz_cleanup_stop() -> GraphvizToolCleanup {
  GraphvizCleanupStop
}

///|
pub let graphviz_tool_pref_graphviz_executable : String = "graphviz.executable"

///|
pub let graphviz_tool_pref_timeout : String = "graphviz.timeout"

///|
let graphviz_tool_process_def_timeout_ref : Ref[Int] = Ref::new(20000)

///|
pub let graphviz_tool_process_min_timeout : Int = 200

///|
let graphviz_tool_program_files_folders : Array[String] = [
  "Program Files", "Program Files (x86)", "Programme", "Programme (x86)",
]

///|
let graphviz_tool_arg_command : String = "-K"

///|
let graphviz_tool_arg_nowarnings : String = "-q"

///|
let graphviz_tool_arg_invertyaxis : String = "-y"

///|
let graphviz_tool_max_error_output : Int = 512

///|
let graphviz_tool_default_locs_ref : Ref[Array[String]] = Ref::new([])

///|
let graphviz_tool_file_separator_ref : Ref[String] = Ref::new("/")

///|
let graphviz_tool_path_separator_ref : Ref[String] = Ref::new(":")

///|
let graphviz_tool_env_path_ref : Ref[String?] = Ref::new(None)

///|
let graphviz_tool_exec_probe_ref : Ref[(String) -> Bool] = Ref::new(_ => false)

///|
let graphviz_tool_handle_exec_path_ref : Ref[() -> Bool] = Ref::new(() => false)

///|
let graphviz_tool_last_exec_args_ref : Ref[Array[String]] = Ref::new([])

///|
fn graphviz_tool_default_process_factory(
  _args : Array[String],
) -> GraphvizProcess? {
  None
}

///|
let graphviz_tool_process_factory_ref : Ref[(Array[String]) -> GraphvizProcess?] = Ref::new(
  graphviz_tool_default_process_factory,
)

///|
fn graphviz_tool_add_default_location(location : String) -> Unit {
  let mut normalized = location.trim().to_string()
  if normalized.is_empty() {
    return
  }
  if normalized.starts_with("\"") &&
    normalized.ends_with("\"") &&
    normalized.length() >= 2 {
    normalized = normalized.substring(start=1, end=normalized.length() - 1)
  }
  if !normalized.ends_with(graphviz_tool_file_separator_ref.val) {
    normalized = normalized + graphviz_tool_file_separator_ref.val
  }
  graphviz_tool_default_locs_ref.val.push(normalized)
}

///|
fn graphviz_tool_rebuild_default_locations() -> Unit {
  graphviz_tool_default_locs_ref.val.clear()

  match graphviz_tool_env_path_ref.val {
    Some(env_path) =>
      for token in env_path.split(graphviz_tool_path_separator_ref.val) {
        graphviz_tool_add_default_location(token.to_string())
      }
    None => ()
  }

  if graphviz_tool_file_separator_ref.val == "/" {
    graphviz_tool_add_default_location("/opt/local/bin/")
    graphviz_tool_add_default_location("/usr/local/bin/")
    graphviz_tool_add_default_location("/usr/bin/")
  } else if graphviz_tool_file_separator_ref.val == "\\" {
    for program_files_name in graphviz_tool_program_files_folders {
      graphviz_tool_add_default_location(
        "C:\\" + program_files_name + "\\Graphviz\\bin\\",
      )
    }
  }
}

///|
let _graphviz_tool_default_locs_init : Unit = graphviz_tool_rebuild_default_locations()

///|
pub struct GraphvizProcess {
  output_stream : GraphvizOutputStream
  input_stream : GraphvizInputStream
  error_stream : GraphvizInputStream
  destroy_fn : () -> Unit
  close_fn : () -> Unit
  exit_value_fn : () -> Int?
}

///|
pub fn new_graphviz_process(
  output_stream : GraphvizOutputStream,
  input_stream : GraphvizInputStream,
  error_stream : GraphvizInputStream,
  destroy_fn? : () -> Unit = () => (),
  close_fn? : () -> Unit = () => (),
  exit_value_fn? : () -> Int? = () => None,
) -> GraphvizProcess {
  {
    output_stream,
    input_stream,
    error_stream,
    destroy_fn,
    close_fn,
    exit_value_fn,
  }
}

///|
pub fn GraphvizProcess::get_output_stream(
  self : GraphvizProcess,
) -> GraphvizOutputStream {
  self.output_stream
}

///|
pub fn GraphvizProcess::get_input_stream(
  self : GraphvizProcess,
) -> GraphvizInputStream {
  self.input_stream
}

///|
pub fn GraphvizProcess::get_error_stream(
  self : GraphvizProcess,
) -> GraphvizInputStream {
  self.error_stream
}

///|
pub fn GraphvizProcess::destroy(self : GraphvizProcess) -> Unit {
  (self.destroy_fn)()
}

///|
pub fn GraphvizProcess::close(self : GraphvizProcess) -> Unit {
  (self.close_fn)()
}

///|
pub fn GraphvizProcess::exit_value(self : GraphvizProcess) -> Int? {
  (self.exit_value_fn)()
}

///|
pub struct GraphvizWatchdog {
  mut running : Bool
}

///|
fn new_graphviz_watchdog() -> GraphvizWatchdog {
  { running: true }
}

///|
pub struct GraphvizTool {
  mut process : GraphvizProcess?
  command : @dot.Command
  mut watchdog : GraphvizWatchdog?
  mut graphviz_stream : GraphvizInputStream?
}

///|
pub fn new_graphviz_tool(thecommand : @dot.Command) -> GraphvizTool {
  match thecommand {
    @dot.Invalid => abort("Invalid Graphviz command.")
    _ => ()
  }
  { process: None, command: thecommand, watchdog: None, graphviz_stream: None }
}

///|
pub fn graphviz_tool_get_process_default_timeout() -> Int {
  graphviz_tool_process_def_timeout_ref.val
}

///|
pub fn graphviz_tool_set_process_default_timeout_for_test(
  timeout : Int,
) -> Unit {
  graphviz_tool_process_def_timeout_ref.val = timeout
}

///|
pub fn graphviz_tool_reset_process_default_timeout_for_test() -> Unit {
  graphviz_tool_process_def_timeout_ref.val = 20000
}

///|
pub fn graphviz_tool_set_default_locations_for_test(
  locations : Array[String],
) -> Unit {
  graphviz_tool_default_locs_ref.val.clear()
  for location in locations {
    graphviz_tool_add_default_location(location)
  }
}

///|
pub fn graphviz_tool_set_environment_for_test(
  env_path : String?,
  file_separator? : String = "/",
  path_separator? : String = ":",
) -> Unit {
  graphviz_tool_env_path_ref.val = env_path
  graphviz_tool_file_separator_ref.val = file_separator
  graphviz_tool_path_separator_ref.val = path_separator
  graphviz_tool_rebuild_default_locations()
}

///|
pub fn graphviz_tool_set_executable_probe_for_test(
  probe : (String) -> Bool,
) -> Unit {
  graphviz_tool_exec_probe_ref.val = probe
}

///|
pub fn graphviz_tool_set_handle_exec_path_for_test(
  handler : () -> Bool,
) -> Unit {
  graphviz_tool_handle_exec_path_ref.val = handler
}

///|
pub fn graphviz_tool_set_process_factory_for_test(
  factory : (Array[String]) -> GraphvizProcess?,
) -> Unit {
  graphviz_tool_process_factory_ref.val = factory
}

///|
pub fn graphviz_tool_get_last_exec_args_for_test() -> Array[String] {
  graphviz_tool_last_exec_args_ref.val
}

///|
pub fn graphviz_tool_reset_runtime_for_test() -> Unit {
  graphviz_tool_env_path_ref.val = None
  graphviz_tool_file_separator_ref.val = "/"
  graphviz_tool_path_separator_ref.val = ":"
  graphviz_tool_exec_probe_ref.val = _ => false
  graphviz_tool_handle_exec_path_ref.val = () => false
  graphviz_tool_process_factory_ref.val = graphviz_tool_default_process_factory
  graphviz_tool_last_exec_args_ref.val.clear()
  graphviz_tool_rebuild_default_locations()
}

///|
pub fn graphviz_tool_get_dot_executable_with_prompt(
  prompt_user : Bool,
) -> String? {
  if graphviz_layouter_is_eclipse_running() {
    let preference = graphviz_layouter_preference_store_access_get_ui_save_string(
      graphviz_tool_pref_graphviz_executable,
    )
    if !preference.is_empty() && (graphviz_tool_exec_probe_ref.val)(preference) {
      return Some(preference)
    }
  }

  for location in graphviz_tool_default_locs_ref.val {
    let unix_path = location + "dot"
    if (graphviz_tool_exec_probe_ref.val)(unix_path) {
      return Some(unix_path)
    }
    let windows_path = location + "dot.exe"
    if (graphviz_tool_exec_probe_ref.val)(windows_path) {
      return Some(windows_path)
    }
  }

  if prompt_user &&
    graphviz_layouter_is_eclipse_running() &&
    (graphviz_tool_handle_exec_path_ref.val)() {
    let preference = graphviz_layouter_preference_store_access_get_ui_save_string(
      graphviz_tool_pref_graphviz_executable,
    )
    if !preference.is_empty() && (graphviz_tool_exec_probe_ref.val)(preference) {
      return Some(preference)
    }
  }
  None
}

///|
pub fn graphviz_tool_get_dot_executable() -> String {
  match graphviz_tool_get_dot_executable_with_prompt(true) {
    Some(executable) => executable
    None =>
      abort(
        "The dot executable was not found in default paths. Please check your Graphviz installation.",
      )
  }
}

///|
pub fn graphviz_tool_current_timeout() -> Int {
  let mut timeout = graphviz_tool_process_def_timeout_ref.val
  if graphviz_layouter_is_eclipse_running() {
    let preference = graphviz_layouter_preference_store_access_get_ui_save_int(
      graphviz_tool_pref_timeout,
    )
    if preference >= graphviz_tool_process_min_timeout {
      timeout = preference
    }
  }
  timeout
}

///|
fn graphviz_tool_read_limited(
  stream : GraphvizInputStream,
  max_bytes : Int,
) -> Array[Int] {
  let bytes : Array[Int] = []
  let mut next = stream.read()
  while next >= 0 && bytes.length() < max_bytes {
    bytes.push(next)
    next = stream.read()
  }
  bytes
}

///|
fn graphviz_tool_exit_value_error(exit_value : Int) -> String {
  let buffer = @buffer.new()
  buffer.write_string("Process terminated with exit value ")
  buffer.write_string(exit_value.to_string())
  if exit_value > 128 {
    let signal_no = exit_value - 128
    let suffix = if signal_no == 2 {
      " (interrupted)"
    } else if signal_no == 3 {
      " (quit)"
    } else if signal_no == 4 {
      " (illegal instruction)"
    } else if signal_no == 6 {
      " (aborted)"
    } else if signal_no == 8 {
      " (floating point error)"
    } else if signal_no == 9 {
      " (killed)"
    } else if signal_no == 11 {
      " (segmentation fault)"
    } else if signal_no == 13 {
      " (broken pipe)"
    } else if signal_no == 15 {
      " (terminated)"
    } else {
      ""
    }
    buffer.write_string(suffix)
  }
  buffer.write_char('.')
  buffer.to_string()
}

///|
priv struct GraphvizStreamState {
  stream : GraphvizInputStream
  mut depth : Int
  mut finished : Int
  mut buf : Int
}

///|
fn graphviz_stream_read(state : GraphvizStreamState) -> Int {
  if state.buf >= 0 {
    let c = state.buf
    state.buf = -1
    return c
  }
  if state.finished > 0 && state.stream.available() == 0 {
    return -1
  }

  let mut c = state.stream.read()
  if c == 123 {
    state.depth = state.depth + 1
  } else if c == 125 {
    state.depth = state.depth - 1
    if state.depth == 0 {
      state.finished = state.finished + 1
    }
  } else if c == 92 {
    state.buf = state.stream.read()
    if state.buf == 10 || state.buf == 13 {
      c = state.stream.read()
      if state.buf == 13 && c == 10 {
        c = state.stream.read()
      }
      state.buf = -1
    }
  }
  c
}

///|
fn graphviz_stream_wrap(stream : GraphvizInputStream) -> GraphvizInputStream {
  let state = { stream, depth: 0, finished: 0, buf: -1 }
  let read_fn = () => graphviz_stream_read(state)
  let read_bytes_with_offset_fn = (bytes : Array[Int], off : Int, len : Int) => {
    if len <= 0 {
      return 0
    }
    let mut index = 0
    while index < len {
      let next = graphviz_stream_read(state)
      if next < 0 {
        return if index == 0 { -1 } else { index }
      }
      bytes[off + index] = next
      index = index + 1
    }
    len
  }
  let read_bytes_fn = (bytes : Array[Int]) => {
    read_bytes_with_offset_fn(bytes, 0, bytes.length())
  }
  let skip_fn = (n : Int) => {
    let mut count = 0
    while count < n {
      if graphviz_stream_read(state) < 0 {
        break
      }
      count = count + 1
    }
    count
  }
  let available_fn = () => state.stream.available()
  let close_fn = () => state.stream.close()
  let mark_fn = (readlimit : Int) => state.stream.mark(readlimit)
  let reset_fn = () => state.stream.reset()
  let mark_supported_fn = () => state.stream.mark_supported()
  new_graphviz_input_stream(
    read_fn, read_bytes_fn, read_bytes_with_offset_fn, skip_fn, available_fn, close_fn,
    mark_fn, reset_fn, mark_supported_fn,
  )
}

///|
fn graphviz_tool_cleanup_is_error(mode : GraphvizToolCleanup) -> Bool {
  match mode {
    GraphvizCleanupError => true
    _ => false
  }
}

///|
fn graphviz_tool_cleanup_is_stop(mode : GraphvizToolCleanup) -> Bool {
  match mode {
    GraphvizCleanupStop => true
    _ => false
  }
}

///|
pub fn GraphvizTool::initialize(
  self : GraphvizTool,
  arguments? : Array[String]? = None,
) -> Unit {
  if self.watchdog is None {
    self.watchdog = Some(new_graphviz_watchdog())
  }
  if self.process is Some(_) {
    return
  }

  let executable = graphviz_tool_get_dot_executable()
  let args : Array[String] = [
    executable,
    graphviz_tool_arg_nowarnings,
    graphviz_tool_arg_invertyaxis,
    graphviz_tool_arg_command + @dot.command_to_string(self.command),
  ]
  match arguments {
    Some(values) =>
      for value in values {
        args.push(value)
      }
    None => ()
  }

  graphviz_tool_last_exec_args_ref.val = args.copy()
  match (graphviz_tool_process_factory_ref.val)(args) {
    Some(process) => self.process = Some(process)
    None =>
      abort(
        "Failed to start Graphviz process. Please check your Graphviz installation.",
      )
  }
}

///|
pub fn GraphvizTool::input(self : GraphvizTool) -> GraphvizOutputStream {
  match self.process {
    Some(process) => process.get_output_stream()
    None => abort("Graphviz tool has not been initialized.")
  }
}

///|
pub fn GraphvizTool::output(self : GraphvizTool) -> GraphvizInputStream {
  match self.process {
    Some(process) => {
      let wrapped = graphviz_stream_wrap(process.get_input_stream())
      self.graphviz_stream = Some(wrapped)
      wrapped
    }
    None => abort("Graphviz tool has not been initialized.")
  }
}

///|
pub fn GraphvizTool::cleanup(
  self : GraphvizTool,
  cleanup_mode : GraphvizToolCleanup,
) -> Unit {
  let mut error_message : String? = None
  match self.process {
    Some(process) => {
      let error_stream = process.get_error_stream()
      if graphviz_tool_cleanup_is_error(cleanup_mode) &&
        self.graphviz_stream is Some(_) {
        let error_bytes = graphviz_tool_read_limited(
          error_stream, graphviz_tool_max_error_output,
        )
        if error_bytes.is_empty() {
          match process.exit_value() {
            Some(exit_value) =>
              if exit_value != 0 {
                error_message = Some(graphviz_tool_exit_value_error(exit_value))
              }
            None => ()
          }
        } else {
          error_message = Some("Graphviz process reported errors")
        }
      }

      while error_stream.available() > 0 {
        ignore(error_stream.read())
      }

      if graphviz_tool_cleanup_is_error(cleanup_mode) ||
        graphviz_tool_cleanup_is_stop(cleanup_mode) {
        process.close()
        process.destroy()
        self.process = None
      }
    }
    None => ()
  }

  match error_message {
    Some(message) => abort("Graphviz error: " + message)
    None => {
      self.graphviz_stream = None
      match self.watchdog {
        Some(watchdog) =>
          if graphviz_tool_cleanup_is_stop(cleanup_mode) {
            watchdog.running = false
            self.watchdog = None
          } else {
            watchdog.running = true
          }
        None => ()
      }
    }
  }
}
