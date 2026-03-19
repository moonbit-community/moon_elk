///|
fn graph_json_issue9_input_json() -> String {
  "{\"id\":\"\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50},\"children\":[{\"id\":\"grid.cell 3\",\"x\":0,\"y\":0,\"width\":95,\"height\":76,\"labels\":[{\"text\":\"cell 3\",\"x\":0,\"y\":0,\"width\":50,\"height\":31}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(76, 95)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"grid.cell 3.c\",\"x\":0,\"y\":0,\"width\":54,\"height\":71,\"labels\":[{\"text\":\"c\",\"x\":0,\"y\":0,\"width\":9,\"height\":26}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(71, 54)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"grid.cell 3.c.d\",\"x\":0,\"y\":0,\"width\":54,\"height\":66,\"labels\":[{\"text\":\"d\",\"x\":0,\"y\":0,\"width\":9,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"grid.cell 3.e\",\"x\":0,\"y\":0,\"width\":53,\"height\":66,\"labels\":[{\"text\":\"e\",\"x\":0,\"y\":0,\"width\":8,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"grid.cell 3.f\",\"x\":0,\"y\":0,\"width\":52,\"height\":71,\"labels\":[{\"text\":\"f\",\"x\":0,\"y\":0,\"width\":7,\"height\":26}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(71, 52)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"grid.cell 3.f.g\",\"x\":0,\"y\":0,\"width\":54,\"height\":66,\"labels\":[{\"text\":\"g\",\"x\":0,\"y\":0,\"width\":9,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]}]}],\"edges\":[{\"id\":\"grid.cell 3.(c -> e)[0]\",\"sources\":[\"grid.cell 3.c\"],\"targets\":[\"grid.cell 3.e\"],\"container\":\"\"},{\"id\":\"grid.cell 3.(c.d -> f.g)[0]\",\"sources\":[\"grid.cell 3.c.d\"],\"targets\":[\"grid.cell 3.f.g\"],\"container\":\"\"}]}"
}

///|
fn graph_json_issue9_assert_close(
  context : String,
  actual : Double,
  expected : Double,
  epsilon : Double,
) -> Unit {
  if (actual - expected).abs() > epsilon {
    abort(
      context +
      ": expected=" +
      expected.to_string() +
      ", actual=" +
      actual.to_string(),
    )
  }
}

///|
fn graph_json_issue9_find_node(
  node : @graph.ElkNode,
  node_id : String,
) -> @graph.ElkNode? {
  if @graph.node_identifier(node) == node_id {
    return Some(node)
  }
  for child in @graph.node_children(node) {
    let found = graph_json_issue9_find_node(child, node_id)
    if found is Some(found_node) {
      return Some(found_node)
    }
  }
  None
}

///|
fn graph_json_issue9_required_node(
  root : @graph.ElkNode,
  node_id : String,
) -> @graph.ElkNode {
  match graph_json_issue9_find_node(root, node_id) {
    Some(node) => node
    None => abort("missing node: " + node_id)
  }
}

///|
fn graph_json_issue9_find_edge(
  node : @graph.ElkNode,
  edge_id : String,
) -> @graph.ElkEdge? {
  for edge in @graph.node_contained_edges(node) {
    if @graph.edge_identifier(edge) == edge_id {
      return Some(edge)
    }
  }
  for child in @graph.node_children(node) {
    let found = graph_json_issue9_find_edge(child, edge_id)
    if found is Some(edge) {
      return Some(edge)
    }
  }
  None
}

///|
fn graph_json_issue9_required_edge(
  root : @graph.ElkNode,
  edge_id : String,
) -> @graph.ElkEdge {
  match graph_json_issue9_find_edge(root, edge_id) {
    Some(edge) => edge
    None => abort("missing edge: " + edge_id)
  }
}

///|
fn graph_json_issue9_required_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    abort("missing edge section: " + @graph.edge_identifier(edge))
  }
  sections[0]
}

///|
test "issue9 single-container include-self layout matches elkjs 0.8.2" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_algorithms()

  let root = elk_graph_json_for_graph(graph_json_issue9_input_json()).to_elk()
  let engine = @core.new_recursive_graph_layout_engine()
  engine.layout(root, @core.new_null_elk_progress_monitor())

  graph_json_issue9_assert_close(
    "root.width",
    @graph.node_width(root),
    351.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "root.height",
    @graph.node_height(root),
    546.0,
    0.0001,
  )

  let cell3 = graph_json_issue9_required_node(root, "grid.cell 3")
  graph_json_issue9_assert_close("cell3.x", @graph.node_x(cell3), 12.0, 0.0001)
  graph_json_issue9_assert_close("cell3.y", @graph.node_y(cell3), 12.0, 0.0001)
  graph_json_issue9_assert_close(
    "cell3.width",
    @graph.node_width(cell3),
    327.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.height",
    @graph.node_height(cell3),
    522.0,
    0.0001,
  )

  let cell3_c = graph_json_issue9_required_node(root, "grid.cell 3.c")
  graph_json_issue9_assert_close(
    "cell3.c.x",
    @graph.node_x(cell3_c),
    66.25,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.c.y",
    @graph.node_y(cell3_c),
    50.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.c.width",
    @graph.node_width(cell3_c),
    154.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.c.height",
    @graph.node_height(cell3_c),
    166.0,
    0.0001,
  )

  let cell3_e = graph_json_issue9_required_node(root, "grid.cell 3.e")
  graph_json_issue9_assert_close(
    "cell3.e.x",
    @graph.node_x(cell3_e),
    50.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.e.y",
    @graph.node_y(cell3_e),
    306.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.e.width",
    @graph.node_width(cell3_e),
    53.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.e.height",
    @graph.node_height(cell3_e),
    66.0,
    0.0001,
  )

  let cell3_f = graph_json_issue9_required_node(root, "grid.cell 3.f")
  graph_json_issue9_assert_close(
    "cell3.f.x",
    @graph.node_x(cell3_f),
    123.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.f.y",
    @graph.node_y(cell3_f),
    306.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.f.width",
    @graph.node_width(cell3_f),
    154.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "cell3.f.height",
    @graph.node_height(cell3_f),
    166.0,
    0.0001,
  )

  let edge_ce = graph_json_issue9_required_edge(root, "grid.cell 3.(c -> e)[0]")
  let edge_ce_section = graph_json_issue9_required_section(edge_ce)
  graph_json_issue9_assert_close(
    "edge c->e start.x",
    @graph.edge_section_start_x(edge_ce_section),
    133.25,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e start.y",
    @graph.edge_section_start_y(edge_ce_section),
    216.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e end.x",
    @graph.edge_section_end_x(edge_ce_section),
    76.5,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e end.y",
    @graph.edge_section_end_y(edge_ce_section),
    306.0,
    0.0001,
  )
  let edge_ce_bends = @graph.edge_section_bend_points(edge_ce_section)
  assert_eq(edge_ce_bends.length(), 2)
  graph_json_issue9_assert_close(
    "edge c->e bend0.x",
    edge_ce_bends[0].get_x(),
    133.25,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e bend0.y",
    edge_ce_bends[0].get_y(),
    261.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e bend1.x",
    edge_ce_bends[1].get_x(),
    76.5,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge c->e bend1.y",
    edge_ce_bends[1].get_y(),
    261.0,
    0.0001,
  )

  let edge_dg = graph_json_issue9_required_edge(
    root, "grid.cell 3.(c.d -> f.g)[0]",
  )
  let edge_dg_section = graph_json_issue9_required_section(edge_dg)
  graph_json_issue9_assert_close(
    "edge d->g start.x",
    @graph.edge_section_start_x(edge_dg_section),
    143.25,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g start.y",
    @graph.edge_section_start_y(edge_dg_section),
    166.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g end.x",
    @graph.edge_section_end_x(edge_dg_section),
    200.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g end.y",
    @graph.edge_section_end_y(edge_dg_section),
    356.0,
    0.0001,
  )
  let edge_dg_bends = @graph.edge_section_bend_points(edge_dg_section)
  assert_eq(edge_dg_bends.length(), 2)
  graph_json_issue9_assert_close(
    "edge d->g bend0.x",
    edge_dg_bends[0].get_x(),
    143.25,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g bend0.y",
    edge_dg_bends[0].get_y(),
    261.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g bend1.x",
    edge_dg_bends[1].get_x(),
    200.0,
    0.0001,
  )
  graph_json_issue9_assert_close(
    "edge d->g bend1.y",
    edge_dg_bends[1].get_y(),
    261.0,
    0.0001,
  )
}
