///|
fn component_group_test_generate_graph(connections : Array[PortSide]) -> LGraph {
  let graph = new_l_graph()
  graph.set_property_port_side_array(
    internal_properties_ext_port_connections, connections,
  )
  graph
}

///|
test "ComponentGroup valid constraints" {
  let mut group = new_component_group()
  assert_eq(group.add(component_group_test_generate_graph(sides_north)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_north)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_south)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_south)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_west)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_west)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_east)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_east)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_west)),
    true,
  )
  assert_eq(group.add(component_group_test_generate_graph(sides_west)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_west)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_east)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_east)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south)),
    true,
  )
  assert_eq(group.add(component_group_test_generate_graph(sides_north)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_north)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_south)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_south)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), true)

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_south_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_south)),
    true,
  )
}

///|
test "ComponentGroup invalid constraints" {
  let mut group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south)),
    false,
  )

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_south_west)),
    false,
  )

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_south_west)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_south)),
    true,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_south_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south_west)),
    false,
  )

  group = new_component_group()
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south_west)),
    true,
  )
  assert_eq(group.add(component_group_test_generate_graph(sides_none)), false)
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_east_south_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_south_west)),
    false,
  )
  assert_eq(
    group.add(component_group_test_generate_graph(sides_north_east_south_west)),
    false,
  )
}
