///|
pub struct ElkGraphJsonUiModule {
  plugin_id : String
  base : AbstractElkGraphJsonUiModule
}

///|
pub fn new_elk_graph_json_ui_module(
  plugin_id? : String = graph_json_text_ui_plugin_id,
) -> ElkGraphJsonUiModule {
  { plugin_id, base: new_abstract_elk_graph_json_ui_module(plugin_id~) }
}

///|
pub fn ElkGraphJsonUiModule::get_base(
  self : ElkGraphJsonUiModule,
) -> AbstractElkGraphJsonUiModule {
  self.base
}
