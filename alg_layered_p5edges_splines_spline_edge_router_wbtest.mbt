///|
let spline_edge_router_wb_tolerance : Double = 0.0001

///|
fn spline_edge_router_wb_assert_close(actual : Double, expected : Double) -> Unit {
  let diff = (actual - expected).abs()
  if diff > spline_edge_router_wb_tolerance {
    abort("expected=\{expected} actual=\{actual} diff=\{diff}")
  }
}

///|
fn spline_edge_router_wb_new_port(node_y : Double, side : PortSide) -> LPort {
  let node = new_l_node()
  ignore(node.get_position().set_xy(node.get_position().x, node_y))
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn spline_edge_router_wb_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn spline_edge_router_wb_new_segment(
  source_y : Double,
  target_y : Double,
  source_side : SplineSideToProcess,
  target_side : SplineSideToProcess,
) -> SplineSegment {
  let source = spline_edge_router_wb_new_port(source_y, PortSide::West)
  let target = spline_edge_router_wb_new_port(target_y, PortSide::East)
  let edge = spline_edge_router_wb_new_edge(source, target)
  new_spline_segment_single_edge(edge, source_side, target_side)
}

///|
test "spline edge router create dependency uses crossing counter ordering" {
  let edge0 = spline_edge_router_wb_new_segment(100.0, 5.0, Left, Right)
  let edge1 = spline_edge_router_wb_new_segment(6.0, 100.0, Left, Right)
  edge0.hyper_edge_top_y_pos = 0.0
  edge0.hyper_edge_bottom_y_pos = 10.0
  edge1.hyper_edge_top_y_pos = 0.0
  edge1.hyper_edge_bottom_y_pos = 10.0

  spline_edge_router_create_dependency(edge0, edge1)

  assert_eq(edge1.outgoing.length(), 1)
  assert_eq(edge0.incoming.length(), 1)
  let dependency = edge1.outgoing[0]
  assert_eq(dependency.weight, 2)
  assert_eq(
    spline_edge_router_segment_identity(
      spline_edge_router_dependency_source(dependency),
    ),
    spline_edge_router_segment_identity(edge1),
  )
  assert_eq(
    spline_edge_router_segment_identity(
      spline_edge_router_dependency_target(dependency),
    ),
    spline_edge_router_segment_identity(edge0),
  )
}

///|
test "spline edge router break cycles ensures dependencies point rightward" {
  let edge_a = spline_edge_router_wb_new_segment(0.0, 10.0, Left, Right)
  let edge_b = spline_edge_router_wb_new_segment(1.0, 11.0, Left, Right)
  let edge_c = spline_edge_router_wb_new_segment(2.0, 12.0, Left, Right)
  ignore(new_spline_dependency(edge_a, edge_b, 1))
  ignore(new_spline_dependency(edge_b, edge_c, 1))
  ignore(new_spline_dependency(edge_c, edge_a, 1))

  let random = @random.Rand::new()
  let edges = [edge_a, edge_b, edge_c]
  spline_edge_router_break_cycles(edges, random)

  for edge in edges {
    for dependency in edge.outgoing {
      let source = spline_edge_router_dependency_source(dependency)
      let target = spline_edge_router_dependency_target(dependency)
      assert_true(source.mark <= target.mark)
    }
  }
}

///|
test "spline edge router topological numbering respects dependencies" {
  let edge_a = spline_edge_router_wb_new_segment(0.0, 10.0, Left, Right)
  let edge_b = spline_edge_router_wb_new_segment(1.0, 11.0, Left, Right)
  let edge_c = spline_edge_router_wb_new_segment(2.0, 12.0, Left, Right)
  let edge_d = spline_edge_router_wb_new_segment(3.0, 13.0, Right, Right)
  ignore(new_spline_dependency(edge_a, edge_b, 1))
  ignore(new_spline_dependency(edge_b, edge_c, 1))
  ignore(new_spline_dependency(edge_b, edge_d, 1))

  let edges = [edge_a, edge_b, edge_c, edge_d]
  spline_edge_router_topological_numbering(edges)

  for edge in edges {
    for dependency in edge.outgoing {
      let source = spline_edge_router_dependency_source(dependency)
      let target = spline_edge_router_dependency_target(dependency)
      assert_true(target.rank >= source.rank + 1)
    }
  }
  assert_true(edge_d.rank >= edge_b.rank + 1)
}

///|
test "spline edge router compute sloppy spacing uses max vertical span" {
  let graph = new_l_graph()
  let right_layer = new_layer(graph)
  graph.get_layers().push(right_layer)

  let source_node = new_l_node()
  ignore(source_node.get_position().set_xy(0.0, 0.0))
  let target_node = new_l_node()
  target_node.set_layer(Some(right_layer))
  ignore(target_node.get_position().set_xy(0.0, 10.0))

  let source_port = new_l_port()
  source_port.set_side(PortSide::East)
  source_port.set_node(Some(source_node))
  let target_port = new_l_port()
  target_port.set_side(PortSide::West)
  target_port.set_node(Some(target_node))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))

  let spacing = spline_edge_router_compute_sloppy_spacing(right_layer, 5.0, 20.0, 2.0)
  spline_edge_router_wb_assert_close(spacing, 5.0)
}

///|
test "spline edge router edge chain and spline path follow successor map" {
  let source_1 = spline_edge_router_wb_new_port(0.0, PortSide::West)
  let target_1 = spline_edge_router_wb_new_port(5.0, PortSide::East)
  let source_2 = spline_edge_router_wb_new_port(5.0, PortSide::West)
  let target_2 = spline_edge_router_wb_new_port(8.0, PortSide::East)
  let edge_1 = spline_edge_router_wb_new_edge(source_1, target_1)
  let edge_2 = spline_edge_router_wb_new_edge(source_2, target_2)

  let segment_1 = new_spline_segment_single_edge(edge_1, Left, Right)
  let segment_2 = new_spline_segment_single_edge(edge_2, Left, Right)

  let successing_edge : Map[Int, LEdge] = {}
  successing_edge[ledge_internal_handle(edge_1)] = edge_2
  let edge_to_segment_map : Map[Int, SplineSegment] = {}
  edge_to_segment_map[ledge_internal_handle(edge_1)] = segment_1
  edge_to_segment_map[ledge_internal_handle(edge_2)] = segment_2

  let edge_chain = spline_edge_router_get_edge_chain(edge_1, successing_edge)
  assert_eq(edge_chain.length(), 2)
  assert_eq(ledge_internal_handle(edge_chain[0]), ledge_internal_handle(edge_1))
  assert_eq(ledge_internal_handle(edge_chain[1]), ledge_internal_handle(edge_2))

  let segment_chain = spline_edge_router_get_spline_path(
    edge_1,
    successing_edge,
    edge_to_segment_map,
  )
  assert_eq(segment_chain.length(), 2)
  assert_true(segment_chain[0].initial_segment)
  assert_true(segment_chain[1].last_segment)
  assert_true(segment_chain[0].source_node is Some(_))
  assert_true(segment_chain[1].target_node is Some(_))
}
