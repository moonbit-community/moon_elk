///|
pub fn new_null_elk_progress_monitor() -> IElkProgressMonitor {
  {
    running: false,
    task_name: "",
    canceled: false,
    logs: [],
    logged_graphs: [],
    null_mode: true,
  }
}
