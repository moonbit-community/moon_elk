///|
test "GraphvizLayouterPreferenceInitializer sets timeout and reuse defaults" {
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()
  graphviz_tool_reset_process_default_timeout_for_test()
  graphviz_tool_set_process_default_timeout_for_test(23456)

  graphviz_layouter_preference_initializer_initialize_default_preferences()

  let store = graphviz_layouter_preference_store_get_instance().get_preference_store()
  inspect(store.get_int(graphviz_tool_pref_timeout), content="23456")
  inspect(
    store.get_boolean(graphviz_layout_provider_pref_graphviz_reuse_process),
    content="true",
  )
}
