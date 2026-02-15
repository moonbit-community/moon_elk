///|
fn label_and_node_size_offset_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn label_and_node_size_offset_test_new_port(
  node : LNode,
  side : PortSide,
  x : Double,
  y : Double,
) -> LPort {
  let port = new_l_port()
  port.set_property_double(nodespacing_port_border_offset_property, 0.0)
  port.set_side(side)
  ignore(port.get_position().set_xy(x, y))
  port.set_node(Some(node))
  port
}

///|
fn label_and_node_size_offset_test_generate_node(
  graph : LGraph,
  constraints : String,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_property_string(port_constraints, constraints)
  ignore(node.get_size().set_xy(100.0, 100.0))
  graph.get_layerless_nodes().push(node)

  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("NORTH"),
      50.0,
      -300.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("SOUTH"),
      50.0,
      300.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("EAST"),
      300.0,
      50.0,
    ),
  )
  ignore(
    label_and_node_size_offset_test_new_port(
      node,
      label_and_node_size_offset_test_port_side("WEST"),
      -300.0,
      50.0,
    ),
  )

  node
}

///|
test "label and node size processor places ports on node border with zero offset" {
  let graph = new_l_graph()
  ignore(label_and_node_size_offset_test_generate_node(graph, "FREE"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_SIDE"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_ORDER"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_RATIO"))
  ignore(label_and_node_size_offset_test_generate_node(graph, "FIXED_POS"))

  let processor = new_label_and_node_size_processor_layout_processor()
  processor.process(graph, None)

  for node in graph.get_layerless_nodes() {
    for port in node.get_ports() {
      match port.get_side() {
        PortSide::North =>
          assert_double_eq(port.get_position().y, -port.get_size().y, 0.0)
        PortSide::South =>
          assert_double_eq(port.get_position().y, node.get_size().y, 0.0)
        PortSide::East =>
          assert_double_eq(port.get_position().x, node.get_size().x, 0.0)
        PortSide::West =>
          assert_double_eq(port.get_position().x, -port.get_size().x, 0.0)
        _ => abort("unexpected port side")
      }
    }
  }
}
