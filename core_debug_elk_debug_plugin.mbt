///|
pub struct ElkDebugPlugin {
  model : ExecutionInfoModel
  layout_listener : CoreDebugLayoutListener
}

///|
let elk_debug_plugin_ref : Ref[ElkDebugPlugin?] = Ref::new(None)

///|
pub fn new_elk_debug_plugin() -> ElkDebugPlugin {
  let model = new_execution_info_model()
  let layout_listener = new_core_debug_layout_listener(
    (_mapping, _progress_monitor) => (),
    (_mapping, progress_monitor) => {
      model.add_execution(
        execution_info_from_progress_monitor(progress_monitor),
      )
    },
  )
  { model, layout_listener }
}

///|
pub fn elk_debug_plugin_start(plugin : ElkDebugPlugin) -> Unit {
  elk_debug_plugin_ref.val = Some(plugin)
  core_debug_layout_connectors_add_layout_listener(plugin.layout_listener)
}

///|
pub fn elk_debug_plugin_stop(plugin : ElkDebugPlugin) -> Unit {
  core_debug_layout_connectors_remove_layout_listener(plugin.layout_listener)
  elk_debug_plugin_ref.val = None
}

///|
pub fn elk_debug_plugin_get_default() -> ElkDebugPlugin? {
  elk_debug_plugin_ref.val
}

///|
pub fn ElkDebugPlugin::get_model(self : ElkDebugPlugin) -> ExecutionInfoModel {
  self.model
}

///|
pub fn elk_debug_plugin_image_descriptor_from_plugin(
  plugin_id : String,
  icon_path : String,
) -> String {
  plugin_id + ":" + icon_path
}
