///|
test "elk_graph_resource defaults to utf-8 encoding" {
  let resource = new_elk_graph_resource("memory:/graph.elkg")
  inspect(resource.get_uri(), content="memory:/graph.elkg")
  inspect(resource.get_encoding(), content="utf-8")
}

///|
test "elk_graph_resource creates helper and save" {
  let resource = new_elk_graph_resource("memory:/graph.elkg")
  let helper = resource.create_xml_helper()
  inspect(helper.get_resource_uri(), content="memory:/graph.elkg")
  let plain_save = resource.create_xml_save()
  let with_options_save = resource.create_xml_save_with_options({})
  inspect(
    plain_save.get_helper().get_resource_uri(),
    content="memory:/graph.elkg",
  )
  inspect(
    with_options_save.get_helper().get_resource_uri(),
    content="memory:/graph.elkg",
  )
}

///|
test "elk_graph_resource_factory creates resource" {
  let factory = new_elk_graph_resource_factory()
  let resource = factory.create_resource("file:/tmp/a.elkg")
  inspect(resource.get_uri(), content="file:/tmp/a.elkg")
  inspect(resource.get_encoding(), content="utf-8")
}

///|
test "elk_graph_xmi_helper create_from_string handles property and value" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  let resource = new_elk_graph_resource("memory:/graph.elkg")
  let helper = new_elk_graph_xmi_helper(resource)
  match
    helper.create_from_string(
      elk_graph_xmi_data_type_iproperty,
      no_layout.get_id(),
    ) {
    PropertyId(property) =>
      inspect(property.get_id(), content="org.eclipse.elk.noLayout")
    _ => abort("expected PropertyId")
  }
  match helper.create_from_string(elk_graph_xmi_data_type_property_value, "1") {
    PropertyValue(proxy) => inspect(proxy.to_string(), content="1")
    _ => abort("expected PropertyValue")
  }
  match
    helper.create_from_string(new_elk_graph_xmi_data_type_other("raw"), "abc") {
    RawValue(value) => inspect(value, content="abc")
    _ => abort("expected RawValue")
  }
}

///|
test "elk_graph_xmi_save only saves known options" {
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_options()
  layout_meta_data_service_register_option(
    new_layout_option_data("org.eclipse.elk.objectOnly"),
  )
  let resource = new_elk_graph_resource("memory:/graph.elkg")
  let save = new_elk_graph_xmi_save(new_elk_graph_xmi_helper(resource))
  let sink : Map[String, String] = {}
  inspect(
    save.save_property_entry(sink, Some(no_layout.get_id()), "true"),
    content="true",
  )
  inspect(
    save.save_property_entry(sink, Some("org.eclipse.elk.unknown"), "x"),
    content="false",
  )
  inspect(
    save.save_property_entry(sink, Some("org.eclipse.elk.objectOnly"), "x"),
    content="false",
  )
  inspect(save.save_property_entry(sink, None, "x"), content="false")
  inspect(sink.contains(no_layout.get_id()), content="true")
  inspect(sink.contains("org.eclipse.elk.unknown"), content="false")
  inspect(sink.contains("org.eclipse.elk.objectOnly"), content="false")
}
