///|
pub enum MonitoredOperationStatus {
  OperationOk
  OperationWarning
  OperationError
  OperationCanceled
} derive(Eq, Show)

///|
pub fn monitored_operation_status_ok() -> MonitoredOperationStatus {
  OperationOk
}

///|
let monitored_operation_timestamp_ref : Ref[Int] = Ref::new(0)

///|
fn next_monitored_operation_timestamp() -> Int {
  let next = monitored_operation_timestamp_ref.val + 1
  monitored_operation_timestamp_ref.val = next
  next
}

///|
pub fn reset_monitored_operation_timestamp_for_test() -> Unit {
  monitored_operation_timestamp_ref.val = 0
}

///|
pub struct MonitoredOperation {
  mut timestamp : Int
  mut is_canceled_flag : Bool
  cancel_indicator : IElkCancelIndicator?
  create_monitor_fn : () -> IElkProgressMonitor
  pre_uiexec_fn : () -> Unit
  execute_fn : (IElkProgressMonitor) -> MonitoredOperationStatus
  post_uiexec_fn : () -> Unit
  handle_status_fn : (MonitoredOperationStatus) -> Unit
}

///|
pub fn new_monitored_operation(
  execute_fn : (IElkProgressMonitor) -> MonitoredOperationStatus,
  create_monitor_fn? : () -> IElkProgressMonitor = () => {
    new_basic_progress_monitor()
  },
  pre_uiexec_fn? : () -> Unit = () => (),
  post_uiexec_fn? : () -> Unit = () => (),
  cancel_indicator? : IElkCancelIndicator? = None,
  handle_status_fn? : (MonitoredOperationStatus) -> Unit = _ => (),
) -> MonitoredOperation {
  {
    timestamp: 0,
    is_canceled_flag: false,
    cancel_indicator,
    create_monitor_fn,
    pre_uiexec_fn,
    execute_fn,
    post_uiexec_fn,
    handle_status_fn,
  }
}

///|
pub fn MonitoredOperation::is_canceled(self : MonitoredOperation) -> Bool {
  let canceled_by_indicator = match self.cancel_indicator {
    Some(indicator) => indicator.is_canceled()
    None => false
  }
  self.is_canceled_flag || canceled_by_indicator
}

///|
pub fn MonitoredOperation::cancel(self : MonitoredOperation) -> Unit {
  self.is_canceled_flag = true
}

///|
pub fn MonitoredOperation::get_timestamp(self : MonitoredOperation) -> Int {
  self.timestamp
}

///|
fn monitored_operation_run(
  operation : MonitoredOperation,
  monitor : IElkProgressMonitor,
) -> MonitoredOperationStatus {
  operation.timestamp = next_monitored_operation_timestamp()

  (operation.pre_uiexec_fn)()
  if operation.is_canceled() {
    (operation.handle_status_fn)(OperationCanceled)
    return OperationCanceled
  }

  let status = (operation.execute_fn)(monitor)
  let final_status = if operation.is_canceled() {
    OperationCanceled
  } else {
    status
  }

  if final_status == OperationOk {
    (operation.post_uiexec_fn)()
  }
  (operation.handle_status_fn)(final_status)
  final_status
}

///|
pub fn MonitoredOperation::run_monitored(
  self : MonitoredOperation,
) -> MonitoredOperationStatus {
  monitored_operation_run(self, (self.create_monitor_fn)())
}

///|
pub fn MonitoredOperation::run_unmonitored(
  self : MonitoredOperation,
) -> MonitoredOperationStatus {
  monitored_operation_run(self, new_null_elk_progress_monitor())
}
