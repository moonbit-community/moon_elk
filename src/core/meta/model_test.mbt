///|
fn core_meta_test_string_or_none(value : String?) -> String {
  match value {
    Some(text) => text
    None => "none"
  }
}

///|
test "core.meta enum mappings keep generated ids" {
  let target = match core_meta_md_option_target_type_from_string("labels") {
    Some(value) => core_meta_md_option_target_type_value(value).to_string()
    None => "none"
  }
  inspect(target, content="4")

  let feature = match core_meta_md_graph_feature_from_int(3) {
    Some(value) => core_meta_md_graph_feature_literal(value)
    None => "none"
  }
  inspect(feature, content="edge_labels")
}

///|
test "core.meta factory creates model objects with mutable fields" {
  let factory = core_meta_meta_data_factory_instance
  let model = factory.create_md_model()
  inspect(core_meta_test_string_or_none(model.get_name()), content="none")

  model.set_name(Some("org.example.melk"))
  inspect(
    core_meta_test_string_or_none(model.get_name()),
    content="org.example.melk",
  )

  let bundle = factory.create_md_bundle()
  bundle.set_label(Some("Example Bundle"))
  bundle.set_id_prefix(Some("org.example"))
  model.set_bundle(Some(bundle))

  inspect(
    core_meta_test_string_or_none(bundle.get_label()),
    content="Example Bundle",
  )
  inspect(
    core_meta_test_string_or_none(bundle.get_id_prefix()),
    content="org.example",
  )
}

///|
test "core.meta members preserve direct composition structure" {
  let option = core_meta_create_md_option()
  option.set_name(Some("spacing"))
  option.set_label(Some("Spacing"))
  option.get_targets().push(core_meta_md_option_target_type_nodes())

  let group = core_meta_create_md_group()
  group.set_name(Some("layout"))
  group.get_children().push(core_meta_md_group_or_option_option(option))

  let bundle = core_meta_create_md_bundle()
  bundle
  .get_members()
  .push(
    core_meta_md_bundle_member_group_or_option(
      core_meta_md_group_or_option_group(group),
    ),
  )

  inspect(bundle.get_members().length(), content="1")
  inspect(
    core_meta_md_bundle_member_tag(bundle.get_members()[0]),
    content="group_or_option",
  )
}
