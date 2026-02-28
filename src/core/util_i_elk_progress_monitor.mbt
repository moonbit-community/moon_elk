///|
pub let elk_unknown_work = -1.0

///|
let elk_progress_monitor_infinite_hierarchy_levels = -1

///|
let elk_progress_monitor_root_debug_folder_name = "logs"

///|
let elk_progress_monitor_debug_folder_counter_ref : Ref[Int] = Ref::new(0)

///|
priv suberror ElkProgressMonitorException {
  ElkProgressMonitorException(String)
} derive(Show, ToJson)

///|
fn elk_progress_monitor_raise(
  message : String,
) -> Unit raise ElkProgressMonitorException {
  raise ElkProgressMonitorException(message)
}

///|
fn elk_progress_monitor_exception_message(
  err : ElkProgressMonitorException,
) -> String {
  match err {
    ElkProgressMonitorException(message) => message
  }
}

///|
fn elk_progress_monitor_next_debug_folder_counter() -> Int {
  let next = elk_progress_monitor_debug_folder_counter_ref.val + 1
  elk_progress_monitor_debug_folder_counter_ref.val = next
  next
}

///|
fn elk_progress_monitor_safe_path_name(name : String) -> String {
  let fallback = if name.is_empty() { "Unnamed" } else { name }
  fallback
  .replace_all(old=" ", new="_")
  .replace_all(old="/", new="_")
  .replace_all(old="\\", new="_")
}

///|
fn elk_progress_monitor_two_digit_index(value : Int) -> String {
  if value >= 0 && value < 10 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
pub(all) struct IElkProgressMonitor {
  mut running : Bool
  mut task_name : String
  canceled : Bool
  logs : Array[String]
  logged_graphs : Array[LoggedGraph]
  null_mode : Bool
  mut parent_monitor : IElkProgressMonitor?
  children : Array[IElkProgressMonitor]
  mut max_levels : Int
  mut closed : Bool
  mut total_work : Double
  mut completed_work : Double
  mut current_child_work : Double
  mut record_logs : Bool
  mut persist_logs : Bool
  mut record_execution_time : Bool
  mut execution_time : Double
  mut debug_folder : String
  mut child_index : Int
}

///|
pub fn new_elk_progress_monitor(
  task_name? : String = "",
) -> IElkProgressMonitor {
  {
    running: false,
    task_name,
    canceled: false,
    logs: [],
    logged_graphs: [],
    null_mode: false,
    parent_monitor: None,
    children: [],
    max_levels: elk_progress_monitor_infinite_hierarchy_levels,
    closed: false,
    total_work: 0.0,
    completed_work: 0.0,
    current_child_work: -1.0,
    record_logs: false,
    persist_logs: false,
    record_execution_time: false,
    execution_time: 0.0,
    debug_folder: "",
    child_index: -1,
  }
}

///|
pub fn IElkProgressMonitor::with_max_hierarchy_levels(
  self : IElkProgressMonitor,
  levels : Int,
) -> IElkProgressMonitor {
  self.max_levels = if levels < 0 {
    elk_progress_monitor_infinite_hierarchy_levels
  } else {
    levels
  }
  self
}

///|
pub fn IElkProgressMonitor::with_logging(
  self : IElkProgressMonitor,
  enabled : Bool,
) -> IElkProgressMonitor {
  self.record_logs = enabled
  self.logs.clear()
  self.logged_graphs.clear()
  self.debug_folder = ""
  self
}

///|
pub fn IElkProgressMonitor::with_log_persistence(
  self : IElkProgressMonitor,
  enabled : Bool,
) -> IElkProgressMonitor {
  self.persist_logs = enabled
  self.debug_folder = ""
  self
}

///|
pub fn IElkProgressMonitor::with_execution_time_measurement(
  self : IElkProgressMonitor,
  enabled : Bool,
) -> IElkProgressMonitor {
  self.record_execution_time = enabled
  self
}

///|
pub fn IElkProgressMonitor::begin(
  self : IElkProgressMonitor,
  name : String,
  total_work : Double,
) -> Bool {
  if self.null_mode {
    return false
  }
  if self.closed {
    try elk_progress_monitor_raise("The task is already done.") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          elk_progress_monitor_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return false
  }
  if self.running || !self.task_name.is_empty() {
    false
  } else {
    self.running = true
    self.task_name = name
    self.total_work = total_work
    self.completed_work = 0.0
    self.current_child_work = -1.0
    self.execution_time = 0.0
    self.debug_folder = ""
    true
  }
}

///|
fn elk_progress_monitor_internal_worked(
  monitor : IElkProgressMonitor,
  work : Double,
) -> Unit {
  if monitor.total_work > 0.0 && monitor.completed_work < monitor.total_work {
    monitor.completed_work = monitor.completed_work + work
    if monitor.parent_monitor is Some(parent) &&
      parent.current_child_work > 0.0 &&
      monitor.max_levels != 0 {
      elk_progress_monitor_internal_worked(
        parent,
        work / monitor.total_work * parent.current_child_work,
      )
    }
  }
}

///|
pub fn IElkProgressMonitor::worked(
  self : IElkProgressMonitor,
  work : Double,
) -> Unit {
  if self.null_mode || self.closed || work <= 0.0 {
    return
  }
  elk_progress_monitor_internal_worked(self, work)
}

///|
pub fn IElkProgressMonitor::done(self : IElkProgressMonitor) -> Unit {
  if self.null_mode {
    return
  }
  if !self.running && !self.closed {
    try elk_progress_monitor_raise("The task has not begun yet.") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          elk_progress_monitor_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return
  }
  if !self.closed {
    if self.total_work > self.completed_work {
      elk_progress_monitor_internal_worked(
        self,
        self.total_work - self.completed_work,
      )
    }
    self.closed = true
    self.running = false
  }
}

///|
pub fn IElkProgressMonitor::is_running(self : IElkProgressMonitor) -> Bool {
  if self.null_mode {
    return false
  }
  self.running && !self.closed
}

///|
pub fn IElkProgressMonitor::get_task_name(self : IElkProgressMonitor) -> String {
  if self.null_mode {
    return ""
  }
  self.task_name
}

///|
pub fn IElkProgressMonitor::sub_task(
  self : IElkProgressMonitor,
  work : Double,
) -> IElkProgressMonitor? {
  if self.null_mode {
    Some(self)
  } else if self.closed {
    None
  } else {
    let sub_monitor = new_elk_progress_monitor()
    sub_monitor.child_index = self.children.length()
    ignore(
      sub_monitor.with_max_hierarchy_levels(
        if self.max_levels > 0 {
          self.max_levels - 1
        } else {
          self.max_levels
        },
      ),
    )
    ignore(sub_monitor.with_logging(self.record_logs))
    ignore(sub_monitor.with_log_persistence(self.persist_logs))
    ignore(
      sub_monitor.with_execution_time_measurement(self.record_execution_time),
    )
    sub_monitor.parent_monitor = Some(self)
    self.children.push(sub_monitor)
    self.current_child_work = work
    Some(sub_monitor)
  }
}

///|
pub fn IElkProgressMonitor::get_sub_monitors(
  self : IElkProgressMonitor,
) -> Array[IElkProgressMonitor] {
  if self.null_mode {
    []
  } else {
    self.children.copy()
  }
}

///|
pub fn IElkProgressMonitor::get_parent_monitor(
  self : IElkProgressMonitor,
) -> IElkProgressMonitor? {
  if self.null_mode {
    None
  } else {
    self.parent_monitor
  }
}

///|
pub fn IElkProgressMonitor::get_debug_folder(
  self : IElkProgressMonitor,
) -> String {
  if self.null_mode || !self.record_logs || !self.persist_logs {
    return ""
  }
  if !self.debug_folder.is_empty() {
    return self.debug_folder
  }

  let safe_task_name = elk_progress_monitor_safe_path_name(self.task_name)
  if self.parent_monitor is Some(parent_monitor) {
    let parent_folder = parent_monitor.get_debug_folder()
    if parent_folder.is_empty() {
      self.debug_folder = ""
    } else {
      let child_index = if self.child_index < 0 { 0 } else { self.child_index }
      self.debug_folder = parent_folder +
        "/" +
        elk_progress_monitor_two_digit_index(child_index) +
        "-" +
        safe_task_name
    }
  } else {
    self.debug_folder = elk_progress_monitor_root_debug_folder_name +
      "/" +
      elk_progress_monitor_next_debug_folder_counter().to_string() +
      "-" +
      safe_task_name
  }
  self.debug_folder
}

///|
pub fn IElkProgressMonitor::is_logging_enabled(
  self : IElkProgressMonitor,
) -> Bool {
  if self.null_mode {
    false
  } else {
    self.record_logs
  }
}

///|
pub fn IElkProgressMonitor::is_log_persistence_enabled(
  self : IElkProgressMonitor,
) -> Bool {
  if self.null_mode {
    false
  } else {
    self.persist_logs
  }
}

///|
pub fn IElkProgressMonitor::log(
  self : IElkProgressMonitor,
  object : String,
) -> Unit {
  if self.null_mode || !self.record_logs {
    return
  }
  self.logs.push(object)
}

///|
pub fn IElkProgressMonitor::get_logs(
  self : IElkProgressMonitor,
) -> Array[String] {
  if self.null_mode || !self.record_logs {
    return []
  }
  self.logs.copy()
}

///|
pub fn IElkProgressMonitor::log_graph(
  self : IElkProgressMonitor,
  tag : String,
  graph_type? : LoggedGraphType = ElkGraph,
) -> Unit {
  if self.null_mode || !self.record_logs {
    return
  }
  self.logged_graphs.push(new_logged_graph(tag, graph_type))
}

///|
pub fn IElkProgressMonitor::get_logged_graphs(
  self : IElkProgressMonitor,
) -> Array[LoggedGraph] {
  if self.null_mode || !self.record_logs {
    return []
  }
  self.logged_graphs.copy()
}

///|
pub fn IElkProgressMonitor::is_execution_time_measured(
  self : IElkProgressMonitor,
) -> Bool {
  if self.null_mode {
    false
  } else {
    self.record_execution_time
  }
}

///|
pub fn IElkProgressMonitor::get_execution_time(
  self : IElkProgressMonitor,
) -> Double {
  if self.null_mode {
    0.0
  } else {
    self.execution_time
  }
}

///|
pub fn IElkProgressMonitor::is_canceled(self : IElkProgressMonitor) -> Bool {
  if self.null_mode {
    false
  } else {
    self.canceled
  }
}
