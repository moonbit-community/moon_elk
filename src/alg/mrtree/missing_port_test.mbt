///|
test "Mrtree CompactionMode parsing follows upstream names" {
  match mrtree_compaction_mode_from_string("NONE") {
    MrtreeCompactionMode::NONE => ()
    _ => fail("Expected NONE")
  }
  match mrtree_compaction_mode_from_string("LEVEL_PRESERVING") {
    MrtreeCompactionMode::LEVEL_PRESERVING => ()
    _ => fail("Expected LEVEL_PRESERVING")
  }
  match mrtree_compaction_mode_from_string("AGGRESSIVE") {
    MrtreeCompactionMode::AGGRESSIVE => ()
    _ => fail("Expected AGGRESSIVE")
  }
}

///|
test "InteractiveMrtreeGraphVisitor sets @core.interactive options on root" {
  reset_graph_model_for_test()

  let root = create_graph()
  ignore(@graph.create_node(Some(root)))
  @graph.node_set_string_property(
    root, @core.algorithm, "org.eclipse.elk.mrtree",
  )
  @graph.node_set_string_property(root, mrtree_weighting, "MODEL_ORDER")

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_eq(@graph.node_get_bool_property(root, @core.interactive), true)
  assert_eq(
    @graph.node_get_string_property(root, mrtree_weighting),
    "CONSTRAINT",
  )
}

///|
test "Mrtree IGraphImporter adapter wraps ElkGraphImporter" {
  reset_graph_model_for_test()
  reset_mrtree_graph_model_for_test()

  let elk_graph = create_graph()
  ignore(@graph.create_node(Some(elk_graph)))
  let importer = new_mrtree_elk_graph_as_igraph_importer()
  let graph = importer.import_graph(elk_graph)

  assert_eq(mrtree_graph_nodes(graph).length(), 1)
  importer.apply_layout(graph)
}

///|
test "OrderBalance reorders heavier inner nodes toward center phase order" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  mrtree_graph_set_weighting(graph, "FAN")

  let root = new_mrtree_node(0, graph)
  mrtree_node_set_root(root, true)

  let thin = new_mrtree_node(1, graph)
  let heavy = new_mrtree_node(2, graph)
  ignore(new_mrtree_edge(root, thin))
  ignore(new_mrtree_edge(root, heavy))

  let thin_child = new_mrtree_node(3, graph)
  let heavy_child = new_mrtree_node(4, graph)
  ignore(new_mrtree_edge(thin, thin_child))
  ignore(new_mrtree_edge(heavy, heavy_child))

  mrtree_node_set_fan(thin, 1)
  mrtree_node_set_fan(heavy, 5)

  new_mrtree_order_balance_layout_phase().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )

  let root_outgoing = mrtree_node_outgoing_edges(root)
  assert_eq(mrtree_node_id(mrtree_edge_target(root_outgoing[0])), 2)
  assert_eq(mrtree_node_id(mrtree_edge_target(root_outgoing[1])), 1)
}
