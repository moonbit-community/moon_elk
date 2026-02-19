///|
priv struct RandomLayoutProviderSnapshot {
  source_x : Double
  source_y : Double
  target_x : Double
  target_y : Double
  section_count : Int
  section_start_x : Double
  section_start_y : Double
  section_end_x : Double
  section_end_y : Double
  graph_width : Double
  graph_height : Double
}

///|
fn random_layout_provider_test_snapshot(
  seed_value : Int,
) -> RandomLayoutProviderSnapshot {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_double_property(graph, aspect_ratio, 1.6)
  @graph.node_set_double_property(graph, spacing_node_node, 20.0)
  @graph.node_set_string_property(
    graph, padding, "[left=12, top=12, right=12, bottom=12]",
  )
  @graph.node_set_int_property(graph, random_seed, seed_value)

  let source = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(source, 30.0, 20.0)
  let target = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(target, 40.0, 30.0)

  let edge = @graph.create_edge(Some(graph))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))

  let provider = new_random_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  let sections = @graph.edge_sections(edge)
  let section = sections[0]
  {
    source_x: @graph.node_x(source),
    source_y: @graph.node_y(source),
    target_x: @graph.node_x(target),
    target_y: @graph.node_y(target),
    section_count: sections.length(),
    section_start_x: @graph.edge_section_start_x(section),
    section_start_y: @graph.edge_section_start_y(section),
    section_end_x: @graph.edge_section_end_x(section),
    section_end_y: @graph.edge_section_end_y(section),
    graph_width: @graph.node_width(graph),
    graph_height: @graph.node_height(graph),
  }
}

///|
test "random layout provider returns early for graph without children" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_dimensions(graph, 77.0, 66.0)

  let provider = new_random_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(@graph.node_width(graph), content="77")
  inspect(@graph.node_height(graph), content="66")
}

///|
test "random layout provider randomizes nodes and writes one edge section" {
  let snapshot = random_layout_provider_test_snapshot(13)

  inspect(snapshot.source_x > 0.0, content="true")
  inspect(snapshot.source_y > 0.0, content="true")
  inspect(snapshot.target_x > 0.0, content="true")
  inspect(snapshot.target_y > 0.0, content="true")
  inspect(snapshot.section_count, content="1")
  inspect(
    snapshot.section_start_x != 0.0 || snapshot.section_start_y != 0.0,
    content="true",
  )
  inspect(
    snapshot.section_end_x != 0.0 || snapshot.section_end_y != 0.0,
    content="true",
  )
  inspect(snapshot.graph_width > 0.0, content="true")
  inspect(snapshot.graph_height > 0.0, content="true")
}

///|
test "random layout provider uses random seed deterministically" {
  let first = random_layout_provider_test_snapshot(42)
  let second = random_layout_provider_test_snapshot(42)
  let third = random_layout_provider_test_snapshot(43)

  inspect(first.source_x == second.source_x, content="true")
  inspect(first.source_y == second.source_y, content="true")
  inspect(first.target_x == second.target_x, content="true")
  inspect(first.target_y == second.target_y, content="true")
  inspect(first.section_start_x == second.section_start_x, content="true")
  inspect(first.section_start_y == second.section_start_y, content="true")
  inspect(first.section_end_x == second.section_end_x, content="true")
  inspect(first.section_end_y == second.section_end_y, content="true")
  inspect(first.graph_width == second.graph_width, content="true")
  inspect(first.graph_height == second.graph_height, content="true")

  inspect(
    first.source_x != third.source_x || first.source_y != third.source_y,
    content="true",
  )
}
