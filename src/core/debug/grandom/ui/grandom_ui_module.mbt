///|
pub(all) struct CoreDebugGRandomUiModule {
  plugin_id : String
  base : AbstractCoreDebugGRandomUiModule
}

///|
pub fn new_core_debug_grandom_ui_module(
  plugin_id? : String = core_debug_grandom_ui_plugin_id,
) -> CoreDebugGRandomUiModule {
  { plugin_id, base: new_abstract_core_debug_grandom_ui_module(plugin_id~) }
}

///|
pub fn CoreDebugGRandomUiModule::get_base(
  self : CoreDebugGRandomUiModule,
) -> AbstractCoreDebugGRandomUiModule {
  self.base
}
