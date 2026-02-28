///|
fn model_order_component_group_test_generate_graph(
  connections : Array[@core.PortSide],
) -> LGraph {
  let graph = new_l_graph()
  graph.set_property_port_side_array(
    internal_properties_ext_port_connections, connections,
  )
  graph
}

///|
test "ModelOrderComponentGroup keeps insertion order of accepted components" {
  let group = new_model_order_component_group()
  let north = model_order_component_group_test_generate_graph(@core.sides_north)
  let east = model_order_component_group_test_generate_graph(@core.sides_east)
  north.set_id(1)
  east.set_id(2)

  assert_eq(group.add(north), true)
  assert_eq(group.add(east), true)

  let ordered = group.get_component_order()
  assert_eq(ordered.length(), 2)
  assert_eq(ordered[0].get_id(), 1)
  assert_eq(ordered[1].get_id(), 2)
}

///|
test "ModelOrderComponentGroup applies additional model-order constraints" {
  let group = new_model_order_component_group()
  assert_eq(
    group.add(model_order_component_group_test_generate_graph(@core.sides_none)),
    true,
  )
  assert_eq(
    group.add(
      model_order_component_group_test_generate_graph(@core.sides_north),
    ),
    false,
  )

  let reverse_group = new_model_order_component_group()
  assert_eq(
    reverse_group.add(
      model_order_component_group_test_generate_graph(@core.sides_north),
    ),
    true,
  )
  assert_eq(
    reverse_group.add(
      model_order_component_group_test_generate_graph(@core.sides_none),
    ),
    true,
  )
}
