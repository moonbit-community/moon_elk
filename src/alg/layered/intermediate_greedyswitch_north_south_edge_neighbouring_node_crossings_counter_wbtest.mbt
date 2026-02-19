///|
fn north_south_counter_test_new_node(
  layer : Layer,
  id : Int,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn north_south_counter_test_new_port(
  node : LNode,
  side : @core.PortSide,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(side)
  port.set_id(id)
  port
}

///|
fn north_south_counter_test_connect(source : LPort, target : LPort) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter counts two north/south dummies from one origin" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = north_south_counter_test_new_node(layer, 0, NodeType::Normal)
  let origin_first = north_south_counter_test_new_port(
    normal,
    @core.PortSide::North,
    0,
  )
  let origin_second = north_south_counter_test_new_port(
    normal,
    @core.PortSide::North,
    1,
  )

  let upper_dummy = north_south_counter_test_new_node(
    layer,
    1,
    NodeType::NorthSouthPort,
  )
  let upper_origin_ref = north_south_counter_test_new_port(
    upper_dummy,
    @core.PortSide::North,
    2,
  )
  upper_origin_ref.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_second),
  )
  upper_dummy.set_property_l_node(
    internal_properties_origin_l_node,
    Some(normal),
  )
  ignore(
    north_south_counter_test_new_port(upper_dummy, @core.PortSide::West, 3),
  )

  let lower_dummy = north_south_counter_test_new_node(
    layer,
    2,
    NodeType::NorthSouthPort,
  )
  let lower_origin_ref = north_south_counter_test_new_port(
    lower_dummy,
    @core.PortSide::North,
    4,
  )
  lower_origin_ref.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_first),
  )
  lower_dummy.set_property_l_node(
    internal_properties_origin_l_node,
    Some(normal),
  )
  let lower_east = north_south_counter_test_new_port(
    lower_dummy,
    @core.PortSide::East,
    5,
  )

  let target = north_south_counter_test_new_node(layer, 3, NodeType::Normal)
  let target_west = north_south_counter_test_new_port(
    target,
    @core.PortSide::West,
    6,
  )
  north_south_counter_test_connect(lower_east, target_west)

  let counter = new_north_south_edge_neighbouring_node_crossings_counter([
    normal, upper_dummy, lower_dummy, target,
  ])
  counter.count_crossings(upper_dummy, lower_dummy)

  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter counts north/south dummy against long edge dummy" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = north_south_counter_test_new_node(layer, 0, NodeType::Normal)
  let normal_north = north_south_counter_test_new_port(
    normal,
    @core.PortSide::North,
    0,
  )

  let ns_dummy = north_south_counter_test_new_node(
    layer,
    1,
    NodeType::NorthSouthPort,
  )
  let ns_origin_ref = north_south_counter_test_new_port(
    ns_dummy,
    @core.PortSide::North,
    1,
  )
  ns_origin_ref.set_property_l_port(
    internal_properties_origin_l_port,
    Some(normal_north),
  )
  ns_dummy.set_property_l_node(internal_properties_origin_l_node, Some(normal))

  let long_dummy = north_south_counter_test_new_node(
    layer,
    2,
    NodeType::LongEdge,
  )

  let counter = new_north_south_edge_neighbouring_node_crossings_counter([
    normal, ns_dummy, long_dummy,
  ])

  counter.count_crossings(ns_dummy, long_dummy)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 0)

  counter.count_crossings(long_dummy, ns_dummy)
  assert_eq(counter.get_upper_lower_crossings(), 0)
  assert_eq(counter.get_lower_upper_crossings(), 1)
}

///|
test "NorthSouthEdgeNeighbouringNodeCrossingsCounter counts normal node north/south edges against long edge dummy" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let normal = north_south_counter_test_new_node(layer, 0, NodeType::Normal)
  let marker_dummy = north_south_counter_test_new_node(
    layer,
    1,
    NodeType::NorthSouthPort,
  )
  let long_dummy = north_south_counter_test_new_node(
    layer,
    2,
    NodeType::LongEdge,
  )

  let north_port = north_south_counter_test_new_port(
    normal,
    @core.PortSide::North,
    0,
  )
  north_port.set_property_l_node(
    internal_properties_port_dummy,
    Some(marker_dummy),
  )

  let south_port_a = north_south_counter_test_new_port(
    normal,
    @core.PortSide::South,
    1,
  )
  south_port_a.set_property_l_node(
    internal_properties_port_dummy,
    Some(marker_dummy),
  )
  let south_port_b = north_south_counter_test_new_port(
    normal,
    @core.PortSide::South,
    2,
  )
  south_port_b.set_property_l_node(
    internal_properties_port_dummy,
    Some(marker_dummy),
  )

  let counter = new_north_south_edge_neighbouring_node_crossings_counter([
    normal, marker_dummy, long_dummy,
  ])

  counter.count_crossings(normal, long_dummy)
  assert_eq(counter.get_upper_lower_crossings(), 2)
  assert_eq(counter.get_lower_upper_crossings(), 1)

  counter.count_crossings(long_dummy, normal)
  assert_eq(counter.get_upper_lower_crossings(), 1)
  assert_eq(counter.get_lower_upper_crossings(), 2)
}
