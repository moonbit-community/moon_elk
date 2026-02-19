///|
fn spore_overlap_test_graph() -> @graph.ElkNode {
  let graph = @graph.create_graph()
  let n0 = @graph.create_node(Some(graph))
  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(n0, 160.0, 20.0)
  @graph.node_set_dimensions(n1, 160.0, 20.0)
  @graph.node_set_dimensions(n2, 20.0, 20.0)
  @graph.node_set_dimensions(n3, 20.0, 20.0)
  @graph.node_set_location(n0, 0.0, 30.0)
  @graph.node_set_location(n1, 150.0, 40.0)
  @graph.node_set_location(n2, 150.0, 0.0)
  @graph.node_set_location(n3, 150.0, 70.0)
  graph
}

///|
fn spore_overlap_exists(graph : @graph.ElkNode) -> Bool {
  let children = @graph.node_children(graph)
  for i in 0..<children.length() {
    for j in (i + 1)..<children.length() {
      let na = children[i]
      let nb = children[j]
      let r1 = @core.new_elk_rectangle_xywh(
        @graph.node_x(na),
        @graph.node_y(na),
        @graph.node_width(na),
        @graph.node_height(na),
      )
      let r2 = @core.new_elk_rectangle_xywh(
        @graph.node_x(nb),
        @graph.node_y(nb),
        @graph.node_width(nb),
        @graph.node_height(nb),
      )
      if @common.compare_fuzzy_lt(@core.shortest_distance(r1, r2), 0.0) {
        return true
      }
    }
  }
  false
}

///|
fn spore_run_overlap_removal(graph : @graph.ElkNode, run_scanline : Bool) -> Unit {
  @graph.node_set_bool_property(
    graph, spore_overlap_removal_run_scanline, run_scanline,
  )
  let provider = new_spore_overlap_removal_layout_provider()
  provider.layout(graph, @core.new_basic_progress_monitor())
}

///|
test "spore @common.overlap removal scanline toggle matches upstream behavior" {
  @graph.reset_graph_model_for_test()
  let graph_with_scanline = spore_overlap_test_graph()
  let graph_without_scanline = spore_overlap_test_graph()

  spore_run_overlap_removal(graph_with_scanline, true)
  spore_run_overlap_removal(graph_without_scanline, false)

  assert_false(spore_overlap_exists(graph_with_scanline))
  assert_true(spore_overlap_exists(graph_without_scanline))
}
