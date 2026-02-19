///|
fn orthogonal_routing_generator_test_new_segment(
  incoming : Array[Double],
  outgoing : Array[Double],
) -> HyperEdgeSegment {
  let segment = new_hyper_edge_segment(new_west_to_east_routing_strategy())
  for coordinate in incoming {
    segment.get_incoming_connection_coordinates().push(coordinate)
  }
  for coordinate in outgoing {
    segment.get_outgoing_connection_coordinates().push(coordinate)
  }
  segment.recompute_extent()
  segment
}

///|
fn orthogonal_routing_generator_test_is_type(
  dependency : HyperEdgeSegmentDependency,
  critical : Bool,
) -> Bool {
  match dependency.get_type() {
    DependencyType::Critical => critical
    DependencyType::Regular => !critical
    _ => false
  }
}

///|
fn orthogonal_routing_generator_test_contains_dependency(
  source : HyperEdgeSegment,
  target : HyperEdgeSegment,
  critical : Bool,
) -> Bool {
  let target_handle = target.get_handle()
  for dependency in source.get_outgoing_segment_dependencies() {
    if orthogonal_routing_generator_test_is_type(dependency, critical) {
      match dependency.get_target() {
        Some(candidate_target) =>
          if candidate_target.get_handle() == target_handle {
            return true
          }
        None => ()
      }
    }
  }
  false
}

///|
fn orthogonal_routing_generator_test_seeded_random() -> @random.Rand {
  let seed = @buffer.new()
  seed.write_int64_le(1)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  seed.write_int64_le(0)
  @random.Rand::chacha8(seed=seed.to_bytes())
}

///|
fn orthogonal_routing_generator_test_west_to_east() -> RoutingDirection {
  routing_direction_values()[0]
}

///|
fn orthogonal_routing_generator_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn orthogonal_routing_generator_test_build_graph_with_edge() -> (
  LGraph,
  LNode,
  LNode,
  LEdge,
) {
  let graph = new_l_graph()
  let left_layer = new_layer(graph)
  let right_layer = new_layer(graph)
  graph.get_layers().push(left_layer)
  graph.get_layers().push(right_layer)

  let left_node = new_l_node()
  left_node.set_layer(Some(left_layer))
  ignore(left_node.get_position().set_xy(0.0, 0.0))

  let right_node = new_l_node()
  right_node.set_layer(Some(right_layer))
  ignore(right_node.get_position().set_xy(0.0, 30.0))

  let left_port = new_l_port()
  left_port.set_side(orthogonal_routing_generator_test_port_side("EAST"))
  left_port.set_node(Some(left_node))

  let right_port = new_l_port()
  right_port.set_side(orthogonal_routing_generator_test_port_side("WEST"))
  right_port.set_node(Some(right_node))

  let edge = new_l_edge()
  edge.set_source(Some(left_port))
  edge.set_target(Some(right_port))

  (graph, left_node, right_node, edge)
}

///|
test "OrthogonalRoutingGenerator creates zero-weight two-cycle for symmetric penalties" {
  let generator = new_orthogonal_routing_generator(
    orthogonal_routing_generator_test_west_to_east(),
    10.0,
    None,
  )

  let first = orthogonal_routing_generator_test_new_segment([0.0], [5.0])
  let second = orthogonal_routing_generator_test_new_segment([5.0], [0.0])

  let critical_dependency_count = generator.create_dependency_if_necessary(
    first, second,
  )
  assert_eq(critical_dependency_count, 0)

  assert_eq(first.get_outgoing_segment_dependencies().length(), 1)
  assert_eq(second.get_outgoing_segment_dependencies().length(), 1)
  assert_eq(first.get_outgoing_segment_dependencies()[0].get_weight(), 0)
  assert_eq(second.get_outgoing_segment_dependencies()[0].get_weight(), 0)
  assert_true(
    orthogonal_routing_generator_test_contains_dependency(first, second, false),
  )
  assert_true(
    orthogonal_routing_generator_test_contains_dependency(second, first, false),
  )
}

///|
test "OrthogonalRoutingGenerator reverses positive-weight cycle dependencies" {
  let first = orthogonal_routing_generator_test_new_segment([0.0], [1.0])
  let second = orthogonal_routing_generator_test_new_segment([1.0], [0.0])
  let dependency_to_reverse = hyper_edge_segment_dependency_create_and_add_regular(
    first, second, 1,
  )
  ignore(hyper_edge_segment_dependency_create_and_add_regular(second, first, 2))

  orthogonal_routing_generator_break_non_critical_cycles(
    [first, second],
    orthogonal_routing_generator_test_seeded_random(),
  )

  let first_handle = first.get_handle()
  match dependency_to_reverse.get_source() {
    Some(source) => assert_eq(source.get_handle(), second.get_handle())
    None => fail("expected reversed dependency to keep a source")
  }
  match dependency_to_reverse.get_target() {
    Some(target) => assert_eq(target.get_handle(), first_handle)
    None => fail("expected reversed dependency to keep a target")
  }
}

///|
test "OrthogonalRoutingGenerator topological numbering assigns increasing routing slots" {
  let first = orthogonal_routing_generator_test_new_segment([0.0], [4.0])
  let second = orthogonal_routing_generator_test_new_segment([5.0], [9.0])
  ignore(hyper_edge_segment_dependency_create_and_add_regular(first, second, 1))

  orthogonal_routing_generator_topological_numbering([first, second])

  assert_eq(first.get_routing_slot(), 0)
  assert_eq(second.get_routing_slot(), 1)
}

///|
test "OrthogonalRoutingGenerator routes edges between layers and creates bend points" {
  let generator = new_orthogonal_routing_generator(
    orthogonal_routing_generator_test_west_to_east(),
    10.0,
    None,
  )
  let (graph, left_node, right_node, edge) = orthogonal_routing_generator_test_build_graph_with_edge()

  let slots = generator.route_edges(
    new_elk_progress_monitor(),
    graph,
    Some([left_node]),
    0,
    Some([right_node]),
    20.0,
  )

  assert_eq(slots, 1)
  let bends = edge.get_bend_points()
  assert_eq(bends.size(), 2)
  assert_eq(bends.get(0).x, 20.0)
  assert_eq(bends.get(0).y, 0.0)
  assert_eq(bends.get(1).x, 20.0)
  assert_eq(bends.get(1).y, 30.0)
}
