///|
pub let elk_unknown_work = -1.0

///|
pub struct IElkProgressMonitor {
  mut running : Bool
  mut task_name : String
  canceled : Bool
  logs : Array[String]
  logged_graphs : Array[LoggedGraph]
  null_mode : Bool
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
  }
}

///|
pub fn IElkProgressMonitor::begin(
  self : IElkProgressMonitor,
  name : String,
  total_work : Double,
) -> Bool {
  ignore(total_work)
  if self.null_mode {
    return false
  }
  if self.running {
    false
  } else {
    self.running = true
    self.task_name = name
    true
  }
}

///|
pub fn IElkProgressMonitor::worked(
  self : IElkProgressMonitor,
  work : Double,
) -> Unit {
  ignore(self)
  ignore(work)
}

///|
pub fn IElkProgressMonitor::done(self : IElkProgressMonitor) -> Unit {
  if self.null_mode {
    return
  }
  self.running = false
}

///|
pub fn IElkProgressMonitor::is_running(self : IElkProgressMonitor) -> Bool {
  if self.null_mode {
    return false
  }
  self.running
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
  ignore(work)
  if self.null_mode {
    Some(self)
  } else {
    None
  }
}

///|
pub fn IElkProgressMonitor::get_sub_monitors(
  self : IElkProgressMonitor,
) -> Array[IElkProgressMonitor] {
  ignore(self)
  []
}

///|
pub fn IElkProgressMonitor::get_parent_monitor(
  self : IElkProgressMonitor,
) -> IElkProgressMonitor? {
  ignore(self)
  None
}

///|
pub fn IElkProgressMonitor::is_logging_enabled(
  self : IElkProgressMonitor,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn IElkProgressMonitor::is_log_persistence_enabled(
  self : IElkProgressMonitor,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn IElkProgressMonitor::log(
  self : IElkProgressMonitor,
  object : String,
) -> Unit {
  if self.null_mode {
    return
  }
  self.logs.push(object)
}

///|
pub fn IElkProgressMonitor::get_logs(
  self : IElkProgressMonitor,
) -> Array[String] {
  if self.null_mode {
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
  if self.null_mode {
    return
  }
  self.logged_graphs.push(new_logged_graph(tag, graph_type))
}

///|
pub fn IElkProgressMonitor::get_logged_graphs(
  self : IElkProgressMonitor,
) -> Array[LoggedGraph] {
  if self.null_mode {
    return []
  }
  self.logged_graphs.copy()
}

///|
pub fn IElkProgressMonitor::is_execution_time_measured(
  self : IElkProgressMonitor,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn IElkProgressMonitor::get_execution_time(
  self : IElkProgressMonitor,
) -> Double {
  ignore(self)
  0.0
}

///|
pub fn IElkProgressMonitor::is_canceled(self : IElkProgressMonitor) -> Bool {
  self.canceled
}
