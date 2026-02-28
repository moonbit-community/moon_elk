///|
pub(all) struct ProgressMonitorAdapter {
  progress_monitor : @core.IElkProgressMonitor
  mut submitted_work : Int
  max_hierarchy_levels : Int
}

///|
pub fn new_progress_monitor_adapter(
  progress_monitor : @core.IElkProgressMonitor,
  max_hierarchy_levels? : Int = -1,
) -> ProgressMonitorAdapter {
  { progress_monitor, submitted_work: 0, max_hierarchy_levels }
}

///|
pub fn ProgressMonitorAdapter::begin(
  self : ProgressMonitorAdapter,
  name : String,
  total_work : Double,
  top_instance? : Bool = true,
) -> Unit {
  if top_instance {
    ignore(self.progress_monitor.begin(name, total_work))
  } else if self.max_hierarchy_levels != 0 {
    self.progress_monitor.log("subtask: " + name)
  }
}

///|
pub fn ProgressMonitorAdapter::done(
  self : ProgressMonitorAdapter,
  top_instance? : Bool = true,
) -> Unit {
  if top_instance {
    self.progress_monitor.done()
  }
}

///|
pub fn ProgressMonitorAdapter::is_canceled(
  self : ProgressMonitorAdapter,
) -> Bool {
  self.progress_monitor.is_canceled()
}

///|
pub fn ProgressMonitorAdapter::sub_task(
  self : ProgressMonitorAdapter,
  work : Double,
) -> ProgressMonitorAdapter {
  ignore(work)
  let next_levels = if self.max_hierarchy_levels > 0 {
    self.max_hierarchy_levels - 1
  } else {
    self.max_hierarchy_levels
  }
  new_progress_monitor_adapter(
    self.progress_monitor,
    max_hierarchy_levels=next_levels,
  )
}

///|
pub fn ProgressMonitorAdapter::worked(
  self : ProgressMonitorAdapter,
  completed_work : Double,
  total_work : Double,
  top_instance? : Bool = true,
) -> Unit {
  ignore(total_work)
  if top_instance {
    let new_work = completed_work.to_int()
    if new_work > self.submitted_work {
      let diff = (new_work - self.submitted_work).to_double()
      self.progress_monitor.worked(diff)
      self.submitted_work = new_work
    }
  }
}
