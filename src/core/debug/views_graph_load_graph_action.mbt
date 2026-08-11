///|
pub let load_graph_action_id : String = "org.eclipse.elk.debug.actions.loadGraph"

///|
let load_graph_action_last_file_name_pref : String = "loadGraphAction.lastGraphFile"

///|
pub(all) struct LoadGraphAction {
  runtime : @core.LayoutRuntime
  session : @core.LayoutSession
  view : LayoutGraphView
  mut selected_file_name : String?
}

///|
pub fn new_load_graph_action(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  view : LayoutGraphView,
) -> LoadGraphAction {
  {
    runtime,
    session,
    view,
    selected_file_name: Some(
      core_debug_plugin_get_string_preference(
        load_graph_action_last_file_name_pref, "",
      ),
    ),
  }
}

///|
pub fn LoadGraphAction::set_selected_file_name_for_test(
  self : LoadGraphAction,
  file_name : String?,
) -> Unit {
  self.selected_file_name = file_name
}

///|
pub fn LoadGraphAction::run(self : LoadGraphAction) -> Unit raise {
  load_graph_action_run_file(
    self.runtime,
    self.session,
    self.selected_file_name,
    self.view,
  )
}

///|
pub fn load_graph_action_run_file(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  full_file_path : String?,
  layout_graph_view : LayoutGraphView,
) -> Unit raise {
  match full_file_path {
    None => ()
    Some(file_name) => {
      core_debug_plugin_set_string_preference(
        load_graph_action_last_file_name_pref, file_name,
      )
      let graph = load_graph_action_load_from_file(file_name)
      let info = load_graph_action_layout(runtime, session, file_name, graph)
      match elk_debug_plugin_get_default() {
        Some(plugin) => plugin.get_model().add_execution(info)
        None => ()
      }
      layout_graph_view.set_selected_execution_infos([info])
    }
  }
}

///|
pub fn load_graph_action_load_from_file(
  file_name : String,
) -> @graph.ElkNode raise {
  core_debug_load_graph_from_registered_file(file_name)
}

///|
pub fn load_graph_action_layout(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  file_name : String,
  graph : @graph.ElkNode,
) -> ExecutionInfo raise {
  load_graph_action_layout_internal(
    runtime,
    session,
    file_name,
    layout_upon_load_setting_action_should_layout_upon_load(),
    graph,
  )
}

///|
pub fn load_graph_action_layout_internal(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  file_name : String,
  perform_layout : Bool,
  graph : @graph.ElkNode,
) -> ExecutionInfo raise {
  let monitor = @core.new_basic_progress_monitor()
  ignore(monitor.begin(file_name, 1.0))

  if perform_layout {
    let layout_engine = @core.new_recursive_graph_layout_engine(
      runtime, session,
    )
    layout_engine.layout(graph, monitor)
  }

  monitor.done()
  monitor.log_graph("Result")
  execution_info_from_progress_monitor_and_file(
    monitor, file_name, perform_layout,
  )
}
