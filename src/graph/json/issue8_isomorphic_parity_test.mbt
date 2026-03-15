///|
fn graph_json_issue8_input_json() -> String {
  "{\"id\":\"\",\"layoutOptions\":{\"elk.algorithm\":\"layered\",\"elk.direction\":\"DOWN\",\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50},\"children\":[{\"id\":\"moonbit_source\",\"x\":0,\"y\":0,\"width\":229,\"height\":81,\"labels\":[{\"text\":\"MoonBit Source\",\"x\":0,\"y\":0,\"width\":184,\"height\":36}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(81, 229)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"moonbit_source.shared\",\"x\":0,\"y\":0,\"width\":120,\"height\":66,\"labels\":[{\"text\":\"shared\",\"x\":0,\"y\":0,\"width\":49,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"moonbit_source.frontend\",\"x\":0,\"y\":0,\"width\":108,\"height\":66,\"labels\":[{\"text\":\"frontend\",\"x\":0,\"y\":0,\"width\":63,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"moonbit_source.backend\",\"x\":0,\"y\":0,\"width\":163,\"height\":66,\"labels\":[{\"text\":\"backend (native)\",\"x\":0,\"y\":0,\"width\":118,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"moonbit_source.cli\",\"x\":0,\"y\":0,\"width\":120,\"height\":66,\"labels\":[{\"text\":\"cli (native)\",\"x\":0,\"y\":0,\"width\":75,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"compiled_output\",\"x\":0,\"y\":0,\"width\":248,\"height\":81,\"labels\":[{\"text\":\"Compiled Output\",\"x\":0,\"y\":0,\"width\":203,\"height\":36}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(81, 248)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"compiled_output.js_bundle\",\"x\":0,\"y\":0,\"width\":124,\"height\":66,\"labels\":[{\"text\":\"frontend.js\",\"x\":0,\"y\":0,\"width\":79,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"compiled_output.server_bin\",\"x\":0,\"y\":0,\"width\":205,\"height\":66,\"labels\":[{\"text\":\"taskflow server binary\",\"x\":0,\"y\":0,\"width\":160,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"compiled_output.cli_bin\",\"x\":0,\"y\":0,\"width\":166,\"height\":66,\"labels\":[{\"text\":\"test client binary\",\"x\":0,\"y\":0,\"width\":121,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"runtime\",\"x\":0,\"y\":0,\"width\":143,\"height\":81,\"labels\":[{\"text\":\"Runtime\",\"x\":0,\"y\":0,\"width\":98,\"height\":36}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.crossingMinimization.forceNodeModelOrder\":true,\"elk.hierarchyHandling\":\"INCLUDE_CHILDREN\",\"elk.layered.nodePlacement.bk.fixedAlignment\":\"BALANCED\",\"elk.layered.considerModelOrder.strategy\":\"NODES_AND_EDGES\",\"elk.layered.cycleBreaking.strategy\":\"GREEDY_MODEL_ORDER\",\"elk.layered.thoroughness\":8,\"elk.layered.spacing.edgeEdgeBetweenLayers\":50,\"elk.spacing.edgeNode\":40,\"spacing.nodeNodeBetweenLayers\":70,\"spacing.edgeNodeBetweenLayers\":40,\"elk.spacing.nodeSelfLoop\":50,\"elk.nodeSize.constraints\":\"MINIMUM_SIZE\",\"elk.nodeSize.minimum\":\"(81, 143)\",\"elk.contentAlignment\":\"H_CENTER V_CENTER\",\"elk.padding\":\"[top=50,left=50,bottom=50,right=50]\"},\"children\":[{\"id\":\"runtime.browser\",\"x\":0,\"y\":0,\"width\":104,\"height\":66,\"labels\":[{\"text\":\"Browser\",\"x\":0,\"y\":0,\"width\":59,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"runtime.server\",\"x\":0,\"y\":0,\"width\":174,\"height\":66,\"labels\":[{\"text\":\"HTTP Server :4006\",\"x\":0,\"y\":0,\"width\":129,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}},{\"id\":\"runtime.db\",\"x\":0,\"y\":0,\"width\":180,\"height\":66,\"labels\":[{\"text\":\"SQLite taskflow.db\",\"x\":0,\"y\":0,\"width\":135,\"height\":21}],\"layoutOptions\":{\"elk.direction\":\"\",\"elk.layered.edgeRouting.selfLoopDistribution\":\"EQUALLY\",\"elk.spacing.nodeSelfLoop\":0}}]}],\"edges\":[{\"id\":\"moonbit_source.(shared -> frontend)[0]\",\"sources\":[\"moonbit_source.shared\"],\"targets\":[\"moonbit_source.frontend\"],\"container\":\"\"},{\"id\":\"moonbit_source.(shared -> backend)[0]\",\"sources\":[\"moonbit_source.shared\"],\"targets\":[\"moonbit_source.backend\"],\"container\":\"\"},{\"id\":\"moonbit_source.(shared -> cli)[0]\",\"sources\":[\"moonbit_source.shared\"],\"targets\":[\"moonbit_source.cli\"],\"container\":\"\"},{\"id\":\"(moonbit_source.frontend -> compiled_output.js_bundle)[0]\",\"sources\":[\"moonbit_source.frontend\"],\"targets\":[\"compiled_output.js_bundle\"],\"container\":\"\",\"labels\":[{\"text\":\"moon build --target js\",\"x\":0,\"y\":0,\"width\":142,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(moonbit_source.backend -> compiled_output.server_bin)[0]\",\"sources\":[\"moonbit_source.backend\"],\"targets\":[\"compiled_output.server_bin\"],\"container\":\"\",\"labels\":[{\"text\":\"moon build --target native\",\"x\":0,\"y\":0,\"width\":173,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(moonbit_source.cli -> compiled_output.cli_bin)[0]\",\"sources\":[\"moonbit_source.cli\"],\"targets\":[\"compiled_output.cli_bin\"],\"container\":\"\",\"labels\":[{\"text\":\"moon build --target native\",\"x\":0,\"y\":0,\"width\":173,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(compiled_output.server_bin -> runtime.server)[0]\",\"sources\":[\"compiled_output.server_bin\"],\"targets\":[\"runtime.server\"],\"container\":\"\"},{\"id\":\"(runtime.server -> compiled_output.js_bundle)[0]\",\"sources\":[\"runtime.server\"],\"targets\":[\"compiled_output.js_bundle\"],\"container\":\"\",\"labels\":[{\"text\":\"serves\",\"x\":0,\"y\":0,\"width\":43,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"(compiled_output.js_bundle -> runtime.browser)[0]\",\"sources\":[\"compiled_output.js_bundle\"],\"targets\":[\"runtime.browser\"],\"container\":\"\"},{\"id\":\"runtime.(browser <-> server)[0]\",\"sources\":[\"runtime.browser\"],\"targets\":[\"runtime.server\"],\"container\":\"\",\"labels\":[{\"text\":\"JSON REST API\",\"x\":0,\"y\":0,\"width\":97,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]},{\"id\":\"runtime.(server <-> db)[0]\",\"sources\":[\"runtime.server\"],\"targets\":[\"runtime.db\"],\"container\":\"\"},{\"id\":\"(compiled_output.cli_bin -> runtime.server)[0]\",\"sources\":[\"compiled_output.cli_bin\"],\"targets\":[\"runtime.server\"],\"container\":\"\",\"labels\":[{\"text\":\"HTTP requests\",\"x\":0,\"y\":0,\"width\":95,\"height\":21,\"layoutOptions\":{\"elk.direction\":\"\",\"elk.edgeLabels.inline\":true,\"elk.spacing.nodeSelfLoop\":0}}]}]}\n"
}

///|
fn graph_json_issue8_assert_close(
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
fn graph_json_issue8_find_edge(
  node : @graph.ElkNode,
  edge_id : String,
) -> @graph.ElkEdge? {
  for edge in @graph.node_contained_edges(node) {
    if @graph.edge_identifier(edge) == edge_id {
      return Some(edge)
    }
  }
  for child in @graph.node_children(node) {
    let found = graph_json_issue8_find_edge(child, edge_id)
    if found is Some(edge) {
      return Some(edge)
    }
  }
  None
}

///|
fn graph_json_issue8_required_edge(
  root : @graph.ElkNode,
  edge_id : String,
) -> @graph.ElkEdge {
  match graph_json_issue8_find_edge(root, edge_id) {
    Some(edge) => edge
    None => abort("missing edge: " + edge_id)
  }
}

///|
fn graph_json_issue8_required_section(
  edge : @graph.ElkEdge,
) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    abort("missing edge section: " + @graph.edge_identifier(edge))
  }
  sections[0]
}

///|
test "issue8 isomorphic layout matches elkjs 0.8.2 routing" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_algorithms()

  let root = elk_graph_json_for_graph(graph_json_issue8_input_json()).to_elk()
  let engine = @core.new_recursive_graph_layout_engine()
  engine.layout(root, @core.new_null_elk_progress_monitor())

  graph_json_issue8_assert_close(
    "root.width",
    @graph.node_width(root),
    710.5,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "root.height",
    @graph.node_height(root),
    1478.0,
    0.0001,
  )

  let serves = graph_json_issue8_required_edge(
    root, "(runtime.server -> compiled_output.js_bundle)[0]",
  )
  let serves_section = graph_json_issue8_required_section(serves)
  graph_json_issue8_assert_close(
    "serves.start.x",
    @graph.edge_section_start_x(serves_section),
    331.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.start.y",
    @graph.edge_section_start_y(serves_section),
    1225.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.end.x",
    @graph.edge_section_end_x(serves_section),
    154.83333333333331,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.end.y",
    @graph.edge_section_end_y(serves_section),
    565.0,
    0.0001,
  )

  let serves_bends = @graph.edge_section_bend_points(serves_section)
  assert_eq(serves_bends.length(), 6)
  graph_json_issue8_assert_close(
    "serves.bend0.x",
    serves_bends[0].get_x(),
    331.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend0.y",
    serves_bends[0].get_y(),
    1265.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend1.x",
    serves_bends[1].get_x(),
    270.25,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend1.y",
    serves_bends[1].get_y(),
    1265.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend2.x",
    serves_bends[2].get_x(),
    270.25,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend2.y",
    serves_bends[2].get_y(),
    1466.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend3.x",
    serves_bends[3].get_x(),
    33.5,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend3.y",
    serves_bends[3].get_y(),
    1466.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend4.x",
    serves_bends[4].get_x(),
    33.5,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend4.y",
    serves_bends[4].get_y(),
    470.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend5.x",
    serves_bends[5].get_x(),
    154.83333333333331,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.bend5.y",
    serves_bends[5].get_y(),
    470.0,
    0.0001,
  )

  let serves_labels = @graph.edge_labels(serves)
  assert_eq(serves_labels.length(), 1)
  graph_json_issue8_assert_close(
    "serves.label.x",
    @graph.label_x(serves_labels[0]),
    11.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "serves.label.y",
    @graph.label_y(serves_labels[0]),
    766.0,
    0.0001,
  )

  let server_return = graph_json_issue8_required_edge(
    root, "(compiled_output.server_bin -> runtime.server)[0]",
  )
  let server_return_section = graph_json_issue8_required_section(server_return)
  graph_json_issue8_assert_close(
    "server-return.start.x",
    @graph.edge_section_start_x(server_return_section),
    360.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "server-return.start.y",
    @graph.edge_section_start_y(server_return_section),
    631.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "server-return.end.x",
    @graph.edge_section_end_x(server_return_section),
    360.0,
    0.0001,
  )
  graph_json_issue8_assert_close(
    "server-return.end.y",
    @graph.edge_section_end_y(server_return_section),
    1159.0,
    0.0001,
  )
  assert_eq(@graph.edge_section_bend_points(server_return_section).length(), 0)
}
