///|
fn cross_min_port_ids(ports : Array[LPort]) -> Array[Int] {
  let ids = []
  for port in ports {
    ids.push(port.get_id())
  }
  ids
}

///|
fn cross_min_node_with_sided_ports() -> (
  LNode,
  LPort,
  LPort,
  LPort,
  LPort,
  LPort,
) {
  let node = new_l_node()

  let north = new_l_port()
  north.set_id(1)
  north.set_side(@core.PortSide::North)
  north.set_node(Some(node))

  let east = new_l_port()
  east.set_id(2)
  east.set_side(@core.PortSide::East)
  east.set_node(Some(node))

  let south_a = new_l_port()
  south_a.set_id(3)
  south_a.set_side(@core.PortSide::South)
  south_a.set_node(Some(node))

  let south_b = new_l_port()
  south_b.set_id(4)
  south_b.set_side(@core.PortSide::South)
  south_b.set_node(Some(node))

  let west = new_l_port()
  west.set_id(5)
  west.set_side(@core.PortSide::West)
  west.set_node(Some(node))

  (node, north, east, south_a, south_b, west)
}

///|
test "CrossMinUtil iterates south/west in reverse side order" {
  let (node, _north, _east, _south_a, _south_b, _west) = cross_min_node_with_sided_ports()

  debug_inspect(
    cross_min_port_ids(
      in_north_south_east_west_order(node, @core.PortSide::North),
    ),
    content="[1]",
  )
  debug_inspect(
    cross_min_port_ids(
      in_north_south_east_west_order(node, @core.PortSide::East),
    ),
    content="[2]",
  )
  debug_inspect(
    cross_min_port_ids(
      in_north_south_east_west_order(node, @core.PortSide::South),
    ),
    content="[4, 3]",
  )
  debug_inspect(
    cross_min_port_ids(
      in_north_south_east_west_order(node, @core.PortSide::West),
    ),
    content="[5]",
  )
  debug_inspect(
    cross_min_port_ids(
      in_north_south_east_west_order(node, @core.PortSide::SideUndefined),
    ),
    content="[]",
  )
}

///|
test "LNode exposes side and type filtered ports and edge views" {
  let (node, _north, east, south_a, _south_b, _west) = cross_min_node_with_sided_ports()

  let source_helper = new_l_node()
  let source_port = new_l_port()
  source_port.set_node(Some(source_helper))
  source_port.set_side(@core.PortSide::West)

  let target_helper = new_l_node()
  let target_port = new_l_port()
  target_port.set_node(Some(target_helper))
  target_port.set_side(@core.PortSide::East)

  let incoming = new_l_edge()
  incoming.set_source(Some(source_port))
  incoming.set_target(Some(south_a))

  let outgoing = new_l_edge()
  outgoing.set_source(Some(east))
  outgoing.set_target(Some(target_port))

  debug_inspect(
    cross_min_port_ids(node.get_ports_by_side(@core.PortSide::South)),
    content="[3, 4]",
  )
  debug_inspect(
    cross_min_port_ids(node.get_port_side_view(@core.PortSide::East)),
    content="[2]",
  )
  debug_inspect(
    cross_min_port_ids(node.get_ports_by_type(PortType::Input)),
    content="[3]",
  )
  debug_inspect(
    cross_min_port_ids(node.get_ports_by_type(PortType::Output)),
    content="[2]",
  )
  debug_inspect(
    cross_min_port_ids(
      node.get_ports_by_type_and_side(PortType::Input, @core.PortSide::South),
    ),
    content="[3]",
  )
  debug_inspect(
    cross_min_port_ids(
      node.get_ports_by_type_and_side(PortType::Output, @core.PortSide::East),
    ),
    content="[2]",
  )
  debug_inspect(
    cross_min_port_ids(node.get_ports_by_type(PortType::Undefined)),
    content="[]",
  )
  assert_eq(node.get_incoming_edges().length(), 1)
  assert_eq(node.get_outgoing_edges().length(), 1)
}
