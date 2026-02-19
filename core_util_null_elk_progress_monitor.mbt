///|
pub fn new_null_elk_progress_monitor() -> IElkProgressMonitor {
  {
    running: false,
    task_name: "",
    canceled: false,
    logs: [],
    logged_graphs: [],
    null_mode: true,
    parent_monitor: None,
    children: [],
    max_levels: -1,
    closed: false,
    total_work: 0.0,
    completed_work: 0.0,
    current_child_work: -1.0,
    record_logs: false,
    persist_logs: false,
    record_execution_time: false,
    execution_time: 0.0,
  }
}
