///|
fn graphviz_preference_page_field_kind_text(
  kind : GraphvizPreferenceFieldKind,
) -> String {
  match kind {
    GraphvizPreferenceFileField => "file"
    GraphvizPreferenceIntegerField => "int"
    GraphvizPreferenceBooleanField => "bool"
  }
}

///|
fn graphviz_preference_page_field_summary(
  field : GraphvizPreferenceField,
) -> String {
  field.get_name() +
  "|" +
  field.get_label() +
  "|" +
  graphviz_preference_page_field_kind_text(field.get_kind()) +
  "|" +
  field.get_validate_on_key_stroke().to_string() +
  "|" +
  field.get_min_value().to_string() +
  "|" +
  field.get_max_value().to_string()
}

///|
test "GraphvizPreferencePage exposes id description and fields" {
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()

  let page = new_graphviz_preference_page()
  inspect(
    graphviz_preference_page_id,
    content="org.eclipse.elk.alg.graphviz.preferences",
  )
  inspect(
    page.get_description(),
    content="Controls how the Eclipse Layout Kernel interacts with the Graphviz layout tools. The Graphviz layout tools are available at http://www.graphviz.org/. If the 'dot' executable cannot be found in default locations, its path must be entered here.",
  )

  page.create_field_editors()
  let fields = page.get_fields()
  inspect(fields.length(), content="3")
  inspect(
    graphviz_preference_page_field_summary(fields[0]),
    content="graphviz.executable|Path to 'dot' executable:|file|true|0|0",
  )
  inspect(
    graphviz_preference_page_field_summary(fields[1]),
    content="graphviz.timeout|Timeout (ms):|int|false|200|2147483647",
  )
  inspect(
    graphviz_preference_page_field_summary(fields[2]),
    content="graphviz.reuseProcess|Reuse single graphviz process for better performance|bool|false|0|0",
  )
}

///|
test "GraphvizPreferencePage init binds preference store" {
  graphviz_layouter_preference_store_reset_for_test()
  graphviz_layouter_plugin_reset_for_test()

  let plugin = new_graphviz_layouter_plugin()
  plugin.start()

  let page = new_graphviz_preference_page()
  page.init()
  inspect(
    match page.get_preference_store() {
      Some(store) => store.get_symbolic_name()
      None => ""
    },
    content="org.eclipse.elk.alg.graphviz.layouter",
  )

  plugin.stop()
}

///|
test "GraphvizPreferencePage perform_ok clears Graphviz instance pools" {
  @core.layout_meta_data_service_reset_for_test()
  let clear_count_ref : Ref[Int] = Ref::new(0)
  @core.layout_meta_data_service_register_algorithm(
    @core.new_layout_algorithm_data(
      "org.eclipse.elk.graphviz.dot",
      name="Graphviz Dot",
      bundle_name="Graphviz",
      instance_pool_clear_fn=() => clear_count_ref.val = clear_count_ref.val + 1,
    ),
  )
  @core.layout_meta_data_service_register_algorithm(
    @core.new_layout_algorithm_data(
      "org.eclipse.elk.layered",
      name="Layered",
      bundle_name="Layered",
      instance_pool_clear_fn=() => {
        clear_count_ref.val = clear_count_ref.val + 100
      },
    ),
  )

  let page = new_graphviz_preference_page()
  inspect(page.perform_ok(), content="true")
  inspect(clear_count_ref.val, content="1")
}
