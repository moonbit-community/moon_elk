///|
fn p4_basic_node_placement_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn p4_basic_node_placement_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn p4_basic_node_placement_test_build_diamond_graph() -> Array[@graph.ElkNode] {
  let graph = create_graph()
  let source = @graph.create_node(Some(graph))
  let mid_a = @graph.create_node(Some(graph))
  let mid_b = @graph.create_node(Some(graph))
  let target = @graph.create_node(Some(graph))

  @graph.node_set_dimensions(source, 16.0, 10.0)
  @graph.node_set_dimensions(mid_a, 16.0, 14.0)
  @graph.node_set_dimensions(mid_b, 16.0, 12.0)
  @graph.node_set_dimensions(target, 16.0, 10.0)

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(source))
  edge_add_target(e1, make_node_shape(mid_a))
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(source))
  edge_add_target(e2, make_node_shape(mid_b))
  update_containment(Some(e2))

  let e3 = create_edge(None)
  edge_add_source(e3, make_node_shape(mid_a))
  edge_add_target(e3, make_node_shape(target))
  update_containment(Some(e3))

  let e4 = create_edge(None)
  edge_add_source(e4, make_node_shape(mid_b))
  edge_add_target(e4, make_node_shape(target))
  update_containment(Some(e4))

  [graph, source, mid_a, mid_b, target]
}

///|
fn p4_basic_node_placement_test_nodes_do_not_overlap_vertically(
  first : @graph.ElkNode,
  second : @graph.ElkNode,
) -> Bool {
  let first_top = @graph.node_y(first)
  let first_bottom = first_top + @graph.node_height(first)
  let second_top = @graph.node_y(second)
  let second_bottom = second_top + @graph.node_height(second)
  first_bottom < second_top || second_bottom < first_top
}

///|
fn p4_basic_node_placement_test_layout_ok_for_config(
  strategy : String,
  bk_edge_straightening : String?,
  bk_fixed_alignment : String?,
) -> Bool {
  reset_graph_model_for_test()
  p4_basic_node_placement_test_setup_plain_java_layout()

  let nodes = p4_basic_node_placement_test_build_diamond_graph()
  let graph = nodes[0]
  let mid_a = nodes[2]
  let mid_b = nodes[3]

  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.layered.nodePlacement.strategy", strategy,
  )
  match bk_edge_straightening {
    Some(value) =>
      @graph.node_set_layout_option_string_by_id(
        graph, "org.eclipse.elk.layered.nodePlacement.bk.edgeStraightening", value,
      )
    None => ()
  }
  match bk_fixed_alignment {
    Some(value) =>
      @graph.node_set_layout_option_string_by_id(
        graph, "org.eclipse.elk.layered.nodePlacement.bk.fixedAlignment", value,
      )
    None => ()
  }

  p4_basic_node_placement_test_layout(graph)

  let algorithm_resolved = @graph.node_get_string_property(
      graph, resolved_algorithm,
    ) ==
    "org.eclipse.elk.layered"
  let middle_nodes_non_overlapping = p4_basic_node_placement_test_nodes_do_not_overlap_vertically(
    mid_a, mid_b,
  )
  algorithm_resolved && middle_nodes_non_overlapping
}

///|
test "BasicNodePlacement LINEAR_SEGMENTS places middle-layer nodes without @common.overlap" {
  assert_true(
    p4_basic_node_placement_test_layout_ok_for_config(
      "LINEAR_SEGMENTS",
      None,
      None,
    ),
  )
}

///|
test "BasicNodePlacement NETWORK_SIMPLEX places middle-layer nodes without @common.overlap" {
  assert_true(
    p4_basic_node_placement_test_layout_ok_for_config(
      "NETWORK_SIMPLEX",
      None,
      None,
    ),
  )
}

///|
test "BasicNodePlacement SIMPLE places middle-layer nodes without @common.overlap" {
  assert_true(
    p4_basic_node_placement_test_layout_ok_for_config("SIMPLE", None, None),
  )
}

///|
test "BasicNodePlacement BRANDES_KOEPF matrix places middle-layer nodes without @common.overlap" {
  let none_alignments = [
    "NONE", "LEFTUP", "LEFTDOWN", "RIGHTUP", "RIGHTDOWN", "BALANCED",
  ]
  for alignment in none_alignments {
    assert_true(
      p4_basic_node_placement_test_layout_ok_for_config(
        "BRANDES_KOEPF",
        Some("NONE"),
        Some(alignment),
      ),
    )
  }

  let improve_alignments = [
    "LEFTUP", "LEFTDOWN", "RIGHTUP", "RIGHTDOWN", "BALANCED",
  ]
  for alignment in improve_alignments {
    assert_true(
      p4_basic_node_placement_test_layout_ok_for_config(
        "BRANDES_KOEPF",
        Some("IMPROVE_STRAIGHTNESS"),
        Some(alignment),
      ),
    )
  }
}
