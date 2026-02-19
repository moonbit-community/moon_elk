///|
fn inverted_port_processor_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn inverted_port_processor_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn inverted_port_processor_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner")
  }
}

///|
fn inverted_port_processor_test_new_port(
  node : LNode,
  side : PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn inverted_port_processor_test_new_edge(
  source : LPort,
  target : LPort,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn inverted_port_processor_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn inverted_port_processor_test_is_long_edge(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
test "inverted port processor reports expected task name" {
  let processor = new_inverted_port_processor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Inverted port preprocessing")
}

///|
test "inverted port processor inserts same-layer long-edge dummies for odd-side edges" {
  let processor = new_inverted_port_processor_layout_processor()
  let graph = new_l_graph()

  let left_layer = new_layer(graph)
  let middle_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(middle_layer)
  graph.get_layers().push(right_layer)

  let left = new_l_node(graph=Some(graph))
  left.set_layer(Some(left_layer))
  let middle = new_l_node(graph=Some(graph))
  middle.set_layer(Some(middle_layer))
  let right = new_l_node(graph=Some(graph))
  right.set_layer(Some(right_layer))

  middle.set_property_string(port_constraints, "FIXED_SIDE")

  let left_out_east = inverted_port_processor_test_new_port(
    left,
    inverted_port_processor_test_port_side("EAST"),
  )
  let middle_in_east = inverted_port_processor_test_new_port(
    middle,
    inverted_port_processor_test_port_side("EAST"),
  )
  let middle_out_west = inverted_port_processor_test_new_port(
    middle,
    inverted_port_processor_test_port_side("WEST"),
  )
  let right_in_west = inverted_port_processor_test_new_port(
    right,
    inverted_port_processor_test_port_side("WEST"),
  )

  ignore(inverted_port_processor_test_new_edge(left_out_east, middle_in_east))
  ignore(inverted_port_processor_test_new_edge(middle_out_west, right_in_west))

  processor.process(graph, None)

  let mut checked_west_sources = 0
  let mut checked_east_targets = 0

  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        let source = inverted_port_processor_test_require_source(edge)
        if port_side_to_string(source.get_side()) == "WEST" {
          checked_west_sources = checked_west_sources + 1
          let target_node = inverted_port_processor_test_require_node(
            inverted_port_processor_test_require_target(edge),
          )
          assert_true(inverted_port_processor_test_is_long_edge(target_node))
          match target_node.get_layer() {
            Some(target_layer) =>
              assert_eq(target_layer.get_index(), layer.get_index())
            None => abort("dummy node must have a layer")
          }
        }
      }

      for edge in node.get_incoming_edges() {
        let target = inverted_port_processor_test_require_target(edge)
        if port_side_to_string(target.get_side()) == "EAST" {
          checked_east_targets = checked_east_targets + 1
          let source_node = inverted_port_processor_test_require_node(
            inverted_port_processor_test_require_source(edge),
          )
          assert_true(inverted_port_processor_test_is_long_edge(source_node))
          match source_node.get_layer() {
            Some(source_layer) =>
              assert_eq(source_layer.get_index(), layer.get_index())
            None => abort("dummy node must have a layer")
          }
        }
      }
    }
  }

  assert_true(checked_west_sources > 0)
  assert_true(checked_east_targets > 0)
}

///|
test "inverted port processor moves head labels and sets long-edge source/target" {
  let processor = new_inverted_port_processor_layout_processor()
  let graph = new_l_graph()

  let left_layer = new_layer(graph)
  let middle_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(middle_layer)

  let left = new_l_node(graph=Some(graph))
  left.set_layer(Some(left_layer))
  let middle = new_l_node(graph=Some(graph))
  middle.set_layer(Some(middle_layer))
  middle.set_property_string(port_constraints, "FIXED_SIDE")

  let left_out_east = inverted_port_processor_test_new_port(
    left,
    inverted_port_processor_test_port_side("EAST"),
  )
  let middle_in_east = inverted_port_processor_test_new_port(
    middle,
    inverted_port_processor_test_port_side("EAST"),
  )
  let odd_edge = inverted_port_processor_test_new_edge(
    left_out_east, middle_in_east,
  )

  let head_label = new_l_label_text("head")
  head_label.set_property_string(edge_labels_placement, "HEAD")
  odd_edge.get_labels().push(head_label)

  processor.process(graph, None)

  assert_eq(odd_edge.get_labels().length(), 0)
  let dummy_edge = middle_in_east.get_incoming_edges()[0]
  assert_eq(dummy_edge.get_labels().length(), 1)
  let moved_label = dummy_edge.get_labels()[0]

  match moved_label.get_property_l_edge(internal_properties_end_label_edge) {
    Some(origin_edge) =>
      assert_eq(origin_edge.get_handle(), odd_edge.get_handle())
    None => abort("head label must remember the original edge")
  }

  let dummy_node = inverted_port_processor_test_require_node(
    inverted_port_processor_test_require_source(dummy_edge),
  )
  assert_true(inverted_port_processor_test_is_long_edge(dummy_node))

  match dummy_node.get_property_l_port(internal_properties_long_edge_source) {
    Some(source_port) =>
      assert_eq(source_port.get_handle(), left_out_east.get_handle())
    None => abort("LONG_EDGE_SOURCE must be set")
  }
  match dummy_node.get_property_l_port(internal_properties_long_edge_target) {
    Some(target_port) =>
      assert_eq(target_port.get_handle(), middle_in_east.get_handle())
    None => abort("LONG_EDGE_TARGET must be set")
  }
}

///|
test "inverted port processor ignores odd-port self loops" {
  let processor = new_inverted_port_processor_layout_processor()
  let graph = new_l_graph()

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_string(port_constraints, "FIXED_SIDE")

  let west = inverted_port_processor_test_new_port(
    node,
    inverted_port_processor_test_port_side("WEST"),
  )
  let east = inverted_port_processor_test_new_port(
    node,
    inverted_port_processor_test_port_side("EAST"),
  )
  let self_loop = inverted_port_processor_test_new_edge(west, east)

  processor.process(graph, None)

  assert_eq(
    inverted_port_processor_test_require_source(self_loop).get_handle(),
    west.get_handle(),
  )
  assert_eq(
    inverted_port_processor_test_require_target(self_loop).get_handle(),
    east.get_handle(),
  )

  let mut long_edge_count = 0
  for current_layer in graph.get_layers() {
    for current_node in current_layer.get_nodes() {
      if inverted_port_processor_test_is_long_edge(current_node) {
        long_edge_count = long_edge_count + 1
      }
    }
  }
  assert_eq(long_edge_count, 0)
}
