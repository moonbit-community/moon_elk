///|
fn new_execution_info_for_core_debug_views_test(
  name : String,
  with_log? : Bool = false,
  with_graph? : Bool = false,
) -> ExecutionInfo {
  let monitor = new_elk_progress_monitor(task_name=name)
  if with_log {
    monitor.log("log:" + name)
  }
  if with_graph {
    monitor.log_graph("graph:" + name)
  }
  execution_info_from_progress_monitor(monitor)
}

///|
fn[T] option_is_some(value : T?) -> Bool {
  match value {
    Some(_) => true
    None => false
  }
}

///|
test "LayoutLogView joins selected execution logs like Java view" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info_a = new_execution_info_for_core_debug_views_test("a", with_log=true)
  let info_b = new_execution_info_for_core_debug_views_test("b")
  let view = new_layout_log_view()
  view.set_selected_execution_infos([info_a, info_b])

  inspect(view.get_log_text(), content="log:a\n\n")
  elk_debug_plugin_stop(plugin)
}

///|
test "ExecutionTimeView persists widths and filter state" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let view = new_execution_time_view()
  view.get_base().set_filter_tree(true)
  view.set_column_widths_for_test(111, 222, 333)
  view.persist_state()

  let restored = new_execution_time_view()
  restored.load_state()
  inspect(restored.get_base().is_filter_tree_enabled(), content="true")
  inspect(restored.get_column_widths_for_test(), content="(111, 222, 333)")

  elk_debug_plugin_stop(plugin)
}

///|
test "ExecutionTimeLabelProvider formats total and local times" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()

  let info = new_execution_info_for_core_debug_views_test("timed")
  execution_info_set_execution_time_for_test(info, true, 1.23456, 0.34567)

  let total_provider = new_execution_time_label_provider(
    execution_time_display_total(),
  )
  let local_provider = new_execution_time_label_provider(
    execution_time_display_local(),
  )
  let name_provider = new_execution_time_label_provider(
    execution_time_display_name(),
  )

  inspect(total_provider.get_text(info), content="1234.560")
  inspect(local_provider.get_text(info), content="")
  inspect(name_provider.get_text(info), content="timed (1)")
}

///|
test "LayoutGraphView shows logged graph selection and canvas mode" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info = new_execution_info_for_core_debug_views_test("g", with_graph=true)
  let view = new_layout_graph_view()
  view.set_selected_execution_infos([info])

  inspect(view.get_logged_graphs_for_test().length(), content="1")
  inspect(view.is_showing_visual_graph_for_test(), content="true")
  inspect(option_is_some(view.get_canvas_graph_for_test()), content="true")

  elk_debug_plugin_stop(plugin)
}

///|
test "LayoutUponLoadSettingAction default true and persists choice" {
  core_debug_reset_foundation_for_test()

  inspect(
    layout_upon_load_setting_action_should_layout_upon_load(),
    content="true",
  )
  let action = new_layout_upon_load_setting_action()
  action.set_checked(false)
  action.run()
  inspect(
    layout_upon_load_setting_action_should_layout_upon_load(),
    content="false",
  )
}

///|
test "LoadGraphAction, ReloadFromFileAction and DropAdapter update model" {
  core_debug_reset_foundation_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let graph_a = create_graph()
  node_set_dimensions(graph_a, 10.0, 10.0)
  core_debug_register_graph_file_for_test("/tmp/a.elkg", graph_a)

  let graph_b = create_graph()
  node_set_dimensions(graph_b, 20.0, 20.0)
  core_debug_register_graph_file_for_test("/tmp/b.elkg", graph_b)

  let view = new_layout_graph_view()
  let load = new_load_graph_action(view)
  load.set_selected_file_name_for_test(Some("/tmp/a.elkg"))
  load.run()

  inspect(plugin.get_model().get_execution_infos().length(), content="1")
  let old_info = plugin.get_model().get_execution_infos()[0]
  inspect(execution_info_is_loaded_from_file(old_info), content="true")
  inspect(
    execution_info_get_file_name(old_info),
    content="Some(\"/tmp/a.elkg\")",
  )

  core_debug_register_graph_file_for_test("/tmp/a.elkg", graph_b)
  view.set_selected_execution_infos([old_info])
  let reload = new_reload_from_file_action(view)
  reload.update_enablement()
  inspect(reload.is_enabled(), content="true")
  reload.run()

  inspect(plugin.get_model().get_execution_infos().length(), content="1")
  let new_info = plugin.get_model().get_execution_infos()[0]
  inspect(new_info == old_info, content="false")

  let drop = new_layout_graph_view_drop_adapter(view)
  inspect(drop.validate_drop(), content="true")
  inspect(drop.perform_drop(["/tmp/b.elkg"]), content="true")
  inspect(plugin.get_model().get_execution_infos().length(), content="2")

  elk_debug_plugin_stop(plugin)
}

///|
test "ImageExportAction completes png extension and records exports" {
  core_debug_reset_foundation_for_test()
  image_export_action_reset_for_test()
  execution_info_reset_for_test()
  let plugin = new_elk_debug_plugin()
  elk_debug_plugin_start(plugin)

  let info = new_execution_info_for_core_debug_views_test(
    "export",
    with_graph=true,
  )
  let view = new_layout_graph_view()
  view.set_selected_execution_infos([info])

  let export_action = new_image_export_action(view)
  export_action.update_enablement()
  inspect(export_action.is_enabled(), content="true")
  export_action.set_selected_file_name_for_test(Some("render.p"))
  export_action.run()

  inspect(
    image_export_action_get_exported_files_for_test(),
    content="[\"render.png\"]",
  )
  inspect(
    core_debug_plugin_get_string_preference(
      "imageExportAction.lastImageFile", "",
    ),
    content="render.png",
  )

  elk_debug_plugin_stop(plugin)
}
