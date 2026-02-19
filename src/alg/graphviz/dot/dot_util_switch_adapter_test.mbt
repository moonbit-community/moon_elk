///|
test "dot switch dispatches case handler and statement fallback" {
  let direct_switcher = new_dot_switch(case_node=_ => Some("node"), default_case=() => {
    Some("default")
  })

  inspect(
    direct_switcher.do_switch(dot_switch_target_node(dot_create_node())) ==
    Some("node"),
    content="true",
  )
  inspect(
    direct_switcher.do_switch(dot_switch_target_graph(dot_create_graph())) ==
    Some("default"),
    content="true",
  )

  let inherited_switcher = new_dot_switch(
    case_statement=_ => Some("statement"),
    default_case=() => Some("default"),
  )

  inspect(
    inherited_switcher.do_switch(
      dot_switch_target_attribute(dot_create_attribute()),
    ) ==
    Some("statement"),
    content="true",
  )
  inspect(
    inherited_switcher.do_switch(
      dot_switch_target_subgraph(dot_create_subgraph()),
    ) ==
    Some("statement"),
    content="true",
  )
  inspect(
    inherited_switcher.is_switch_for(dot_package_instance),
    content="true",
  )
  inspect(inherited_switcher.is_switch_for("other.package"), content="false")
}

///|
test "dot adapter factory package check and default adapters" {
  let factory = new_dot_adapter_factory()

  inspect(factory.is_factory_for_type(dot_package_instance), content="true")
  inspect(factory.is_factory_for_type("other.package"), content="false")
  inspect(
    factory.create_adapter(dot_switch_target_node(dot_create_node())) is None,
    content="true",
  )
}
