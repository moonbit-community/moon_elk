///|
pub struct ElkGraphUiModule {
  plugin_id : String
  base : AbstractElkGraphUiModule
}

///|
pub fn new_elk_graph_ui_module(
  plugin_id? : String = graph_text_ui_plugin_id,
) -> ElkGraphUiModule {
  { plugin_id, base: new_abstract_elk_graph_ui_module(plugin_id~) }
}

///|
pub fn ElkGraphUiModule::get_base(
  self : ElkGraphUiModule,
) -> AbstractElkGraphUiModule {
  self.base
}
