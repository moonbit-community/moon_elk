///|
pub fn graphviz_layouter_preference_initializer_initialize_default_preferences() -> Unit {
  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  store.set_default_int(
    graphviz_tool_pref_timeout,
    graphviz_tool_get_process_default_timeout(),
  )
  store.set_default_boolean(
    graphviz_layout_provider_pref_graphviz_reuse_process, graphviz_layout_provider_reuse_process_default,
  )
}
