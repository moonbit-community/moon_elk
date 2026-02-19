///|
test "ExecutionInfo can be built from monitor and file metadata" {
  execution_info_reset_for_test()
  let monitor = new_elk_progress_monitor(task_name="Layout Task")
  ignore(monitor.with_logging(true))
  monitor.log("log-1")
  monitor.log_graph("graph-1")

  let info = execution_info_from_progress_monitor_and_file(
    monitor, "/tmp/demo.elkt", true,
  )

  inspect(execution_info_get_name(info), content="Layout Task")
  inspect(execution_info_is_loaded_from_file(info), content="true")
  inspect(
    execution_info_get_file_name(info),
    content="Some(\"/tmp/demo.elkt\")",
  )
  inspect(execution_info_is_laid_out_after_load(info), content="true")
  inspect(execution_info_has_log_messages(info), content="true")
  inspect(execution_info_has_logged_graphs(info), content="true")
  inspect(execution_info_get_children(info).length(), content="0")
}

///|
test "ExecutionInfo copies monitor debug folder when persistence is enabled" {
  execution_info_reset_for_test()
  let monitor = new_elk_progress_monitor()
  ignore(monitor.with_logging(true))
  ignore(monitor.with_log_persistence(true))
  ignore(monitor.begin("root", 2.0))
  let child_monitor = match monitor.sub_task(1.0) {
    Some(child) => child
    None => abort("expected child monitor")
  }
  ignore(child_monitor.begin("child", 1.0))
  child_monitor.done()
  monitor.done()

  let info = execution_info_from_progress_monitor(monitor)
  inspect(execution_info_get_debug_folder(info).is_empty(), content="false")
  inspect(execution_info_get_children(info).length(), content="1")
  let child_info = execution_info_get_children(info)[0]
  inspect(
    execution_info_get_debug_folder(child_info).is_empty(),
    content="false",
  )
}

///|
test "ExecutionInfoModel add replace remove notifies listener" {
  execution_info_reset_for_test()
  let model = new_execution_info_model()
  let count = Ref::new(0)
  let listener = new_execution_info_model_listener(() => {
    count.val = count.val + 1
  })
  model.add_execution_info_model_listener(listener)

  let info_a = execution_info_from_progress_monitor(
    new_elk_progress_monitor(task_name="A"),
  )
  let info_b = execution_info_from_progress_monitor(
    new_elk_progress_monitor(task_name="B"),
  )

  model.add_execution(info_a)
  model.replace_execution(info_a, info_b)
  model.remove_execution_infos([info_b])
  model.remove_all_execution_infos()

  inspect(count.val, content="4")
}

///|
test "ExecutionInfoContentProvider filters elements and children" {
  execution_info_reset_for_test()
  let monitor_a = new_elk_progress_monitor(task_name="with-log")
  ignore(monitor_a.with_logging(true))
  monitor_a.log("x")
  let info_a = execution_info_from_progress_monitor(monitor_a)
  let info_b = execution_info_from_progress_monitor(
    new_elk_progress_monitor(task_name="without-log"),
  )

  let provider = new_execution_info_content_provider()
  provider.set_filter(Some(info => execution_info_has_log_messages(info)))

  let filtered = provider.get_elements(Some([info_a, info_b]))
  inspect(filtered.length(), content="1")
  inspect(filtered[0], content="\{info_a}")
  inspect(provider.has_children(Some(info_a)), content="false")
  inspect(provider.get_parent(Some(info_a)), content="None")
}
