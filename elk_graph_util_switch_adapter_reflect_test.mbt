///|
test "elk reflect register/new-instance/clone" {
  elk_reflect_reset_for_test()

  elk_reflect_register_new_instance("sample", () => Json::number(1))
  elk_reflect_register_clone("sample", value => value)

  inspect(
    elk_reflect_new_instance("sample") == Some(Json::number(1)),
    content="true",
  )
  inspect(
    elk_reflect_clone("sample", Json::string("x")) == Some(Json::string("x")),
    content="true",
  )
  inspect(elk_reflect_new_instance("missing") is None, content="true")
}

///|
test "elk graph switch dispatches case handler and default" {
  let direct_switcher = new_elk_graph_switch(case_elk_node=_ => Some("node"), default_case=() => {
    Some("default")
  })

  inspect(
    direct_switcher.do_switch(elk_switch_target_elk_node(1)) == Some("node"),
    content="true",
  )
  inspect(
    direct_switcher.do_switch(elk_switch_target_elk_edge(2)) == Some("default"),
    content="true",
  )

  let inherited_switcher = new_elk_graph_switch(
    case_elk_shape=_ => Some("shape"),
    case_i_property_holder=_ => Some("holder"),
    default_case=() => Some("default"),
  )

  inspect(
    inherited_switcher.do_switch(elk_switch_target_elk_node(7)) == Some("shape"),
    content="true",
  )
  inspect(
    inherited_switcher.do_switch(
      elk_switch_target_e_map_property_holder(new_map_property_holder()),
    ) ==
    Some("holder"),
    content="true",
  )
}

///|
test "elk graph adapter factory package check and default adapters" {
  let factory = new_elk_graph_adapter_factory()

  inspect(
    factory.is_factory_for_type(elk_graph_package_instance),
    content="true",
  )
  inspect(factory.is_factory_for_type("other.package"), content="false")
  inspect(
    factory.create_adapter(elk_switch_target_elk_node(0)) is None,
    content="true",
  )
}
