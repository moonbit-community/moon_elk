///|
fn horizontal_compactor_test_graph() -> @compaction.CGraph {
  @compaction.new_cgraph(@core.direction_values())
}

///|
test "horizontal compactor origin lookup resolves lnode and vertical segment" {
  let origin_lookup = new_horizontal_graph_compactor_origin_lookup()
  let c_graph = horizontal_compactor_test_graph()

  let l_node = new_l_node()
  l_node.set_id(7)
  let l_node_origin = horizontal_graph_compactor_lnode_origin_key(l_node)
  let c_lnode = @compaction.cnode_of()
    .origin(l_node_origin)
    .hitbox(@core.new_elk_rectangle_xywh(0.0, 0.0, 10.0, 10.0))
    .create(c_graph)
  origin_lookup.register_lnode(l_node_origin, l_node)

  let edge = new_l_edge()
  edge.set_id(33)
  let segment = new_vertical_segment(
    @core.new_kvector_xy(5.0, 0.0),
    @core.new_kvector_xy(5.0, 8.0),
    None,
    edge,
  )
  let segment_origin = horizontal_graph_compactor_vertical_segment_origin_key(
    segment,
  )
  let c_segment = @compaction.cnode_of()
    .origin(segment_origin)
    .hitbox(@core.new_elk_rectangle_copy(segment.hitbox))
    .create(c_graph)
  origin_lookup.register_vertical_segment(segment_origin, segment)

  match origin_lookup.get_lnode_or_null(c_lnode) {
    Some(value) => assert_eq(value.get_handle(), l_node.get_handle())
    None => abort("Expected lnode origin.")
  }
  match origin_lookup.get_vertical_segment_or_null(c_segment) {
    Some(value) => assert_eq(value.get_id(), segment.get_id())
    None => abort("Expected vertical segment origin.")
  }
}

///|
test "horizontal compactor detects vertical segments of same edge" {
  let origin_lookup = new_horizontal_graph_compactor_origin_lookup()
  let c_graph = horizontal_compactor_test_graph()

  let edge = new_l_edge()
  edge.set_id(90)

  let segment1 = new_vertical_segment(
    @core.new_kvector_xy(4.0, 0.0),
    @core.new_kvector_xy(4.0, 7.0),
    None,
    edge,
  )
  let segment2 = new_vertical_segment(
    @core.new_kvector_xy(4.0, 2.0),
    @core.new_kvector_xy(4.0, 9.0),
    None,
    edge,
  )

  let c_segment1 = @compaction.cnode_of()
    .origin(horizontal_graph_compactor_vertical_segment_origin_key(segment1))
    .hitbox(@core.new_elk_rectangle_copy(segment1.hitbox))
    .create(c_graph)
  let c_segment2 = @compaction.cnode_of()
    .origin(horizontal_graph_compactor_vertical_segment_origin_key(segment2))
    .hitbox(@core.new_elk_rectangle_copy(segment2.hitbox))
    .create(c_graph)

  origin_lookup.register_vertical_segment(
    horizontal_graph_compactor_vertical_segment_origin_key(segment1),
    segment1,
  )
  origin_lookup.register_vertical_segment(
    horizontal_graph_compactor_vertical_segment_origin_key(segment2),
    segment2,
  )

  assert_true(
    origin_lookup.is_vertical_segments_of_same_edge(c_segment1, c_segment2),
  )
}

///|
test "horizontal compactor origin lookups are isolated per transformer" {
  let c_graph = horizontal_compactor_test_graph()
  let node = new_l_node()
  let origin = horizontal_graph_compactor_lnode_origin_key(node)
  let c_node = @compaction.cnode_of()
    .origin(origin)
    .hitbox(@core.new_elk_rectangle_xywh(0.0, 0.0, 1.0, 1.0))
    .create(c_graph)

  let first = new_horizontal_graph_compactor_origin_lookup()
  let second = new_horizontal_graph_compactor_origin_lookup()
  first.register_lnode(origin, node)

  assert_true(first.get_lnode_or_null(c_node) is Some(_))
  assert_true(second.get_lnode_or_null(c_node) is None)

  first.clear()
  assert_true(first.get_lnode_or_null(c_node) is None)
}
