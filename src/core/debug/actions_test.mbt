///|
fn new_execution_info_for_core_debug_test(
  name : String,
  debug_folder? : String? = None,
  with_log? : Bool = false,
) -> ExecutionInfo {
  let monitor = @core.new_elk_progress_monitor(task_name=name)
  if with_log {
    ignore(monitor.with_logging(true))
    monitor.log("log:" + name)
  }
  let info = execution_info_from_progress_monitor(monitor)
  match debug_folder {
    Some(path) => execution_info_set_debug_folder_for_test(info, path)
    None => ()
  }
  info
}

///|
test "ElkDebugPlugin listens to layout done events" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let mapping = new_core_debug_layout_mapping(None)
  let monitor = @core.new_elk_progress_monitor(task_name="layout-one")
  core_debug_layout_connectors_fire_layout_done(mapping, monitor)

  debug_inspect(plugin.get_model().get_execution_infos().length(), content="1")
  debug_inspect(
    execution_info_get_name(plugin.get_model().get_execution_infos()[0]),
    content=(
      #|"layout-one"
    ),
  )

  elk_debug_plugin_stop(plugin)
}

///|
test "Clear actions remove selected and all executions" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info_a = new_execution_info_for_core_debug_test("A")
  let info_b = new_execution_info_for_core_debug_test("B")
  plugin.get_model().add_execution(info_a)
  plugin.get_model().add_execution(info_b)

  let view = new_abstract_layout_debug_view("view", "pref", _ => true)
  view.set_selected_execution_infos([info_a])

  let clear_selected = new_clear_execution_action(view)
  clear_selected.update_enablement()
  debug_inspect(clear_selected.is_enabled(), content="true")
  clear_selected.run()
  debug_inspect(plugin.get_model().get_execution_infos().length(), content="1")
  debug_inspect(
    execution_info_get_name(plugin.get_model().get_execution_infos()[0]),
    content=(
      #|"B"
    ),
  )

  let clear_all = new_clear_executions_action()
  clear_all.update_enablement()
  debug_inspect(clear_all.is_enabled(), content="true")
  clear_all.run()
  debug_inspect(plugin.get_model().get_execution_infos().length(), content="0")

  elk_debug_plugin_stop(plugin)
}

///|
test "Filter collapse expand and preference actions update view state" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info_with_log = new_execution_info_for_core_debug_test(
    "with-log",
    with_log=true,
  )
  let info_without_log = new_execution_info_for_core_debug_test("without-log")
  plugin.get_model().add_execution(info_with_log)
  plugin.get_model().add_execution(info_without_log)

  let view = new_abstract_layout_debug_view("view", "pref", info => {
    execution_info_has_log_messages(info)
  })
  let filter_action = new_filter_execution_tree_action(view)
  filter_action.set_checked(true)
  filter_action.run()

  debug_inspect(view.is_filter_tree_enabled(), content="true")
  debug_inspect(view.get_visible_root_infos_for_test(), content="[0]")

  let collapse = new_collapse_execution_tree_action(view)
  collapse.run()
  debug_inspect(view.is_tree_expanded(), content="false")

  let expand = new_expand_execution_tree_action(view)
  expand.run()
  debug_inspect(view.is_tree_expanded(), content="true")

  let pref_action = new_preference_action(core_debug_pref_debug_logging)
  debug_inspect(pref_action.is_checked(), content="false")
  pref_action.run()
  debug_inspect(pref_action.is_checked(), content="true")
  debug_inspect(
    core_debug_service_get_boolean_preference(
      core_debug_pref_debug_logging, false,
    ),
    content="true",
  )

  elk_debug_plugin_stop(plugin)
}

///|
test "RevealLogFolderAction enables and launches only for a single directory-backed selection" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info = new_execution_info_for_core_debug_test(
    "info",
    debug_folder=Some("/logs/run1"),
  )
  core_debug_register_directory_for_test("/logs/run1", [])

  let view = new_abstract_layout_debug_view("view", "pref", _ => true)
  view.set_selected_execution_infos([info])
  let reveal = new_reveal_log_folder_action(view)

  reveal.update_enablement()
  debug_inspect(reveal.is_enabled(), content="true")
  reveal.run()
  debug_inspect(
    core_debug_get_launched_programs_for_test(),
    content="[\"/logs/run1\"]",
  )

  view.set_selected_execution_infos([])
  reveal.update_enablement()
  debug_inspect(reveal.is_enabled(), content="false")

  elk_debug_plugin_stop(plugin)
}

///|
test "CompressLogFolderAction mirrors zip extension completion and records zip entries" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()

  let info = new_execution_info_for_core_debug_test(
    "zip-info",
    debug_folder=Some("/logs/run1"),
  )
  let view = new_abstract_layout_debug_view("view", "pref", _ => true)
  view.set_selected_execution_infos([info])

  core_debug_register_directory_for_test("/logs/run1", [
    "/logs/run1/root.log", "/logs/run1/sub",
  ])
  core_debug_register_regular_file_for_test("/logs/run1/root.log")
  core_debug_register_directory_for_test("/logs/run1/sub", [
    "/logs/run1/sub/inner.log",
  ])
  core_debug_register_regular_file_for_test("/logs/run1/sub/inner.log")

  let compress = new_compress_log_folder_action(view)
  compress.update_enablement()
  debug_inspect(compress.is_enabled(), content="true")
  compress.set_selected_output_file_name(Some("archive.zi"))
  compress.run()

  let outputs = core_debug_get_zip_outputs_for_test()
  debug_inspect(outputs.length(), content="1")
  debug_inspect(
    outputs[0].file_name,
    content=(
      #|"archive.zip"
    ),
  )
  debug_inspect(
    outputs[0].entries,
    content="[\"/\", \"/run1/\", \"/run1/root.log\", \"/run1/sub/\", \"/run1/sub/inner.log\"]",
  )
}
