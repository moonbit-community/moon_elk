///|
let spline_segment_test_tolerance : Double = 0.0001

///|
fn spline_segment_test_assert_close(actual : Double, expected : Double) -> Unit {
  let diff = (actual - expected).abs()
  if diff > spline_segment_test_tolerance {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn spline_segment_test_port_side_by_name(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn spline_segment_test_side_to_process_by_name(
  name : String,
) -> SplineSideToProcess {
  for side in spline_side_to_process_values() {
    if spline_side_to_process_to_string(side) == name {
      return side
    }
  }
  abort("unknown side to process")
}

///|
fn spline_segment_test_new_port(
  node_y : Double,
  side : @core.PortSide,
) -> LPort {
  let node = new_l_node()
  ignore(node.get_position().set_xy(node.get_position().x, node_y))
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn spline_segment_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "spline segment single edge identifies straight segments" {
  let west = spline_segment_test_port_side_by_name("WEST")
  let east = spline_segment_test_port_side_by_name("EAST")
  let left = spline_segment_test_side_to_process_by_name("LEFT")
  let right = spline_segment_test_side_to_process_by_name("RIGHT")

  let source = spline_segment_test_new_port(10.0, west)
  let target = spline_segment_test_new_port(10.1, east)
  let edge = spline_segment_test_new_edge(source, target)

  let segment = new_spline_segment_single_edge(edge, left, right)

  assert_true(segment.is_straight)
  assert_false(segment.is_hyper_edge())
  assert_eq(segment.left_ports.length(), 1)
  assert_eq(segment.right_ports.length(), 1)
  assert_eq(segment.edges.length(), 1)
}

///|
test "spline segment hyperedge constructor groups ports and edges" {
  let west = spline_segment_test_port_side_by_name("WEST")
  let east = spline_segment_test_port_side_by_name("EAST")
  let left = spline_segment_test_side_to_process_by_name("LEFT")
  let right = spline_segment_test_side_to_process_by_name("RIGHT")

  let single_port = spline_segment_test_new_port(5.0, west)
  let target_1 = spline_segment_test_new_port(1.0, east)
  let target_2 = spline_segment_test_new_port(9.0, east)
  let edge_1 = spline_segment_test_new_edge(single_port, target_1)
  let edge_2 = spline_segment_test_new_edge(single_port, target_2)

  let edges = [@core.pair_of(left, edge_1), @core.pair_of(right, edge_2)]
  let segment = new_spline_segment_hyper_edge(single_port, edges, left)

  assert_false(segment.is_straight)
  assert_true(segment.is_hyper_edge())
  assert_eq(segment.left_ports.length(), 2)
  assert_eq(segment.right_ports.length(), 1)
  assert_eq(segment.edges.length(), 2)
  spline_segment_test_assert_close(segment.bounding_box.y, 1.0)
  spline_segment_test_assert_close(segment.bounding_box.height, 8.0)
  spline_segment_test_assert_close(segment.center_control_point_y, 7.0)
}

///|
test "spline segment uses dedicated north/south y coordinate property" {
  let north = spline_segment_test_port_side_by_name("NORTH")
  let west = spline_segment_test_port_side_by_name("WEST")
  let left = spline_segment_test_side_to_process_by_name("LEFT")
  let right = spline_segment_test_side_to_process_by_name("RIGHT")

  let source = spline_segment_test_new_port(0.0, north)
  source.set_property_double(internal_properties_spline_ns_port_y_coord, 40.0)
  let target = spline_segment_test_new_port(10.0, west)
  let edge = spline_segment_test_new_edge(source, target)

  let segment = new_spline_segment_single_edge(edge, left, right)
  let info = segment.get_edge_information(edge).unwrap()

  assert_false(segment.is_straight)
  spline_segment_test_assert_close(info.start_y, 40.0)
  spline_segment_test_assert_close(segment.center_control_point_y, 25.0)
}
