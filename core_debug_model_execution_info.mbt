///|
pub type ExecutionInfo = Int

///|
priv struct ExecutionInfoData {
  mut name : String
  creation_tick : Int
  mut parent : ExecutionInfo?
  children : Array[ExecutionInfo]
  mut file_name : String?
  mut laid_out_after_load : Bool
  mut execution_time_measured : Bool
  mut execution_time_including_children : Double
  mut execution_time_local : Double
  mut debug_folder : String
  mut log_messages : Array[String]
  mut has_descendants_with_log_messages : Bool
  mut log_graphs : Array[LoggedGraph]
  mut has_descendants_with_log_graphs : Bool
}

///|
let execution_info_store_ref : Ref[Array[ExecutionInfoData]] = Ref::new([])

///|
let execution_info_creation_tick_ref : Ref[Int] = Ref::new(0)

///|
fn checked_execution_info(info : ExecutionInfo) -> Unit {
  if info < 0 || info >= execution_info_store_ref.val.length() {
    abort("invalid execution info")
  }
}

///|
pub fn execution_info_reset_for_test() -> Unit {
  execution_info_store_ref.val.clear()
  execution_info_creation_tick_ref.val = 0
}

///|
fn execution_info_new() -> ExecutionInfo {
  let id = execution_info_store_ref.val.length()
  execution_info_creation_tick_ref.val = execution_info_creation_tick_ref.val +
    1
  execution_info_store_ref.val.push({
    name: "Unnamed",
    creation_tick: execution_info_creation_tick_ref.val,
    parent: None,
    children: [],
    file_name: None,
    laid_out_after_load: false,
    execution_time_measured: false,
    execution_time_including_children: 0.0,
    execution_time_local: 0.0,
    debug_folder: "",
    log_messages: [],
    has_descendants_with_log_messages: false,
    log_graphs: [],
    has_descendants_with_log_graphs: false,
  })
  id
}

///|
fn execution_info_from_progress_monitor_internal(
  monitor : IElkProgressMonitor,
  parent : ExecutionInfo?,
) -> ExecutionInfo {
  let info = execution_info_new()
  let data = execution_info_store_ref.val[info]
  let task_name = monitor.get_task_name()
  data.name = if task_name.is_empty() { "Unnamed" } else { task_name }
  data.execution_time_measured = monitor.is_execution_time_measured()
  data.execution_time_including_children = monitor.get_execution_time()
  data.execution_time_local = data.execution_time_including_children
  data.parent = parent
  data.log_messages = monitor.get_logs().copy()
  data.log_graphs = monitor.get_logged_graphs().copy()

  let child_monitors = monitor.get_sub_monitors()
  for child_monitor in child_monitors {
    let child_info = execution_info_from_progress_monitor_internal(
      child_monitor,
      Some(info),
    )
    data.children.push(child_info)
    data.execution_time_local = data.execution_time_local -
      execution_info_get_execution_time_including_children(child_info)
    data.has_descendants_with_log_messages = data.has_descendants_with_log_messages ||
      execution_info_has_log_messages(child_info) ||
      execution_info_has_descendants_with_log_messages(child_info)
    data.has_descendants_with_log_graphs = data.has_descendants_with_log_graphs ||
      execution_info_has_logged_graphs(child_info) ||
      execution_info_has_descendants_with_logged_graphs(child_info)
  }
  if data.execution_time_local < 0.0 {
    data.execution_time_local = 0.0
  }
  execution_info_store_ref.val[info] = data
  info
}

///|
pub fn execution_info_from_progress_monitor(
  monitor : IElkProgressMonitor,
) -> ExecutionInfo {
  execution_info_from_progress_monitor_internal(monitor, None)
}

///|
pub fn execution_info_from_progress_monitor_and_file(
  monitor : IElkProgressMonitor,
  file_name : String,
  laid_out_after_load : Bool,
) -> ExecutionInfo {
  let info = execution_info_from_progress_monitor(monitor)
  let data = execution_info_store_ref.val[info]
  data.file_name = Some(file_name)
  data.laid_out_after_load = laid_out_after_load
  execution_info_store_ref.val[info] = data
  info
}

///|
pub fn execution_info_get_name(info : ExecutionInfo) -> String {
  checked_execution_info(info)
  execution_info_store_ref.val[info].name
}

///|
pub fn execution_info_get_creation_tick(info : ExecutionInfo) -> Int {
  checked_execution_info(info)
  execution_info_store_ref.val[info].creation_tick
}

///|
pub fn execution_info_get_parent(info : ExecutionInfo) -> ExecutionInfo? {
  checked_execution_info(info)
  execution_info_store_ref.val[info].parent
}

///|
pub fn execution_info_get_children(
  info : ExecutionInfo,
) -> Array[ExecutionInfo] {
  checked_execution_info(info)
  execution_info_store_ref.val[info].children
}

///|
pub fn execution_info_remove_child(
  parent : ExecutionInfo,
  child : ExecutionInfo,
) -> Unit {
  checked_execution_info(parent)
  checked_execution_info(child)
  let data = execution_info_store_ref.val[parent]
  let kept : Array[ExecutionInfo] = []
  for current in data.children {
    if current != child {
      kept.push(current)
    }
  }
  data.children.clear()
  for current in kept {
    data.children.push(current)
  }
  execution_info_store_ref.val[parent] = data
}

///|
pub fn execution_info_is_loaded_from_file(info : ExecutionInfo) -> Bool {
  checked_execution_info(info)
  execution_info_store_ref.val[info].file_name is Some(_)
}

///|
pub fn execution_info_get_file_name(info : ExecutionInfo) -> String? {
  checked_execution_info(info)
  execution_info_store_ref.val[info].file_name
}

///|
pub fn execution_info_is_laid_out_after_load(info : ExecutionInfo) -> Bool {
  checked_execution_info(info)
  execution_info_store_ref.val[info].laid_out_after_load
}

///|
pub fn execution_info_is_execution_time_measured(info : ExecutionInfo) -> Bool {
  checked_execution_info(info)
  execution_info_store_ref.val[info].execution_time_measured
}

///|
pub fn execution_info_get_execution_time_including_children(
  info : ExecutionInfo,
) -> Double {
  checked_execution_info(info)
  execution_info_store_ref.val[info].execution_time_including_children
}

///|
pub fn execution_info_get_execution_time_local(info : ExecutionInfo) -> Double {
  checked_execution_info(info)
  execution_info_store_ref.val[info].execution_time_local
}

///|
pub fn execution_info_set_execution_time_for_test(
  info : ExecutionInfo,
  measured : Bool,
  including_children : Double,
  local_time : Double,
) -> Unit {
  checked_execution_info(info)
  let data = execution_info_store_ref.val[info]
  data.execution_time_measured = measured
  data.execution_time_including_children = including_children
  data.execution_time_local = local_time
  execution_info_store_ref.val[info] = data
}

///|
pub fn execution_info_get_debug_folder(info : ExecutionInfo) -> String {
  checked_execution_info(info)
  execution_info_store_ref.val[info].debug_folder
}

///|
pub fn execution_info_set_debug_folder_for_test(
  info : ExecutionInfo,
  debug_folder : String,
) -> Unit {
  checked_execution_info(info)
  let data = execution_info_store_ref.val[info]
  data.debug_folder = debug_folder
  execution_info_store_ref.val[info] = data
}

///|
pub fn execution_info_get_log_messages(info : ExecutionInfo) -> Array[String] {
  checked_execution_info(info)
  execution_info_store_ref.val[info].log_messages.copy()
}

///|
pub fn execution_info_has_log_messages(info : ExecutionInfo) -> Bool {
  checked_execution_info(info)
  !execution_info_store_ref.val[info].log_messages.is_empty()
}

///|
pub fn execution_info_has_descendants_with_log_messages(
  info : ExecutionInfo,
) -> Bool {
  checked_execution_info(info)
  execution_info_store_ref.val[info].has_descendants_with_log_messages
}

///|
pub fn execution_info_get_logged_graphs(
  info : ExecutionInfo,
) -> Array[LoggedGraph] {
  checked_execution_info(info)
  execution_info_store_ref.val[info].log_graphs.copy()
}

///|
pub fn execution_info_has_logged_graphs(info : ExecutionInfo) -> Bool {
  checked_execution_info(info)
  !execution_info_store_ref.val[info].log_graphs.is_empty()
}

///|
pub fn execution_info_has_descendants_with_logged_graphs(
  info : ExecutionInfo,
) -> Bool {
  checked_execution_info(info)
  execution_info_store_ref.val[info].has_descendants_with_log_graphs
}
