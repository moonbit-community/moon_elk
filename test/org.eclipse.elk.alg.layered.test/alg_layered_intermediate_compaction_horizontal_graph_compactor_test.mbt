///|
fn horizontal_compactor_test_graph() -> CGraph {
  new_cgraph(direction_values())
}

///|
test "horizontal compactor origin lookup resolves lnode and vertical segment" {
  horizontal_graph_compactor_clear_origin_lookup()

  let c_graph = horizontal_compactor_test_graph()

  let l_node = new_l_node()
  l_node.set_id(7)
  let l_node_origin = horizontal_graph_compactor_lnode_origin_key(l_node)
  let c_lnode = cnode_of()
    .origin(l_node_origin)
    .hitbox(new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0))
    .create(c_graph)
  horizontal_graph_compactor_register_origin_lnode(l_node_origin, l_node)

  let edge = new_l_edge()
  edge.set_id(33)
  let segment = new_vertical_segment(
    new_kvector_xy(5.0, 0.0),
    new_kvector_xy(5.0, 8.0),
    None,
    edge,
  )
  let segment_origin = horizontal_graph_compactor_vertical_segment_origin_key(
    segment,
  )
  let c_segment = cnode_of()
    .origin(segment_origin)
    .hitbox(new_elk_rectangle_copy(segment.hitbox))
    .create(c_graph)
  horizontal_graph_compactor_register_origin_vertical_segment(
    segment_origin, segment,
  )

  match horizontal_graph_compactor_get_lnode_or_null(c_lnode) {
    Some(value) => assert_eq(value.get_handle(), l_node.get_handle())
    None => abort("Expected lnode origin.")
  }
  match horizontal_graph_compactor_get_vertical_segment_or_null(c_segment) {
    Some(value) => assert_eq(value.get_id(), segment.get_id())
    None => abort("Expected vertical segment origin.")
  }
}

///|
test "horizontal compactor detects vertical segments of same edge" {
  horizontal_graph_compactor_clear_origin_lookup()

  let c_graph = horizontal_compactor_test_graph()

  let edge = new_l_edge()
  edge.set_id(90)

  let segment1 = new_vertical_segment(
    new_kvector_xy(4.0, 0.0),
    new_kvector_xy(4.0, 7.0),
    None,
    edge,
  )
  let segment2 = new_vertical_segment(
    new_kvector_xy(4.0, 2.0),
    new_kvector_xy(4.0, 9.0),
    None,
    edge,
  )

  let c_segment1 = cnode_of()
    .origin(horizontal_graph_compactor_vertical_segment_origin_key(segment1))
    .hitbox(new_elk_rectangle_copy(segment1.hitbox))
    .create(c_graph)
  let c_segment2 = cnode_of()
    .origin(horizontal_graph_compactor_vertical_segment_origin_key(segment2))
    .hitbox(new_elk_rectangle_copy(segment2.hitbox))
    .create(c_graph)

  horizontal_graph_compactor_register_origin_vertical_segment(
    horizontal_graph_compactor_vertical_segment_origin_key(segment1),
    segment1,
  )
  horizontal_graph_compactor_register_origin_vertical_segment(
    horizontal_graph_compactor_vertical_segment_origin_key(segment2),
    segment2,
  )

  assert_true(
    horizontal_graph_compactor_is_vertical_segments_of_same_edge(
      c_segment1, c_segment2,
    ),
  )
}
