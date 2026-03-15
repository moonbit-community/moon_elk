///|
test "fixed layout provider applies fixed positions and minimum size" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let child = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(child, 10.0, 10.0)
  @graph.node_set_layout_option_string_by_id(
    child, "org.eclipse.elk.position", "(20,30)",
  )
  @graph.node_set_string_set_property(child, node_size_constraints, [
    "MINIMUM_SIZE",
  ])
  @graph.node_set_string_property(child, node_size_minimum, "(40,25)")

  let node_label = @graph.create_label(
    Some(@graph.make_node_label_parent(child)),
  )
  @graph.label_set_dimensions(node_label, 5.0, 4.0)
  @graph.label_set_layout_option_string_by_id(
    node_label, "org.eclipse.elk.position", "(1,2)",
  )

  let port = @graph.create_port(Some(child))
  @graph.port_set_dimensions(port, 6.0, 6.0)
  @graph.port_set_layout_option_string_by_id(
    port, "org.eclipse.elk.position", "(3,4)",
  )

  let port_label = @graph.create_label(
    Some(@graph.make_port_label_parent(port)),
  )
  @graph.label_set_dimensions(port_label, 2.0, 2.0)
  @graph.label_set_layout_option_string_by_id(
    port_label, "org.eclipse.elk.position", "(5,6)",
  )

  let provider = new_fixed_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(@graph.node_x(child), content="20")
  inspect(@graph.node_y(child), content="30")
  inspect(@graph.node_width(child), content="40")
  inspect(@graph.node_height(child), content="25")
  inspect(@graph.label_x(node_label), content="1")
  inspect(@graph.label_y(node_label), content="2")
  inspect(@graph.port_x(port), content="3")
  inspect(@graph.port_y(port), content="4")
  inspect(@graph.label_x(port_label), content="5")
  inspect(@graph.label_y(port_label), content="6")
  inspect(@graph.node_width(graph), content="90")
  inspect(@graph.node_height(graph), content="85")
}

///|
test "fixed layout provider applies bend point endpoints to edge section" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  let source = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(source, 10.0, 10.0)
  @graph.node_set_layout_option_string_by_id(
    source, "org.eclipse.elk.position", "(0,0)",
  )
  let target = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(target, 10.0, 10.0)
  @graph.node_set_layout_option_string_by_id(
    target, "org.eclipse.elk.position", "(50,0)",
  )

  let edge = @graph.create_edge(Some(graph))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))
  @graph.edge_set_layout_option_string_by_id(
    edge, "org.eclipse.elk.bendPoints", "(1,2; 9,11; 20,30)",
  )

  let provider = new_fixed_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(@graph.edge_sections(edge).length(), content="1")
  let section = @graph.edge_sections(edge)[0]
  inspect(@graph.edge_section_start_x(section), content="1")
  inspect(@graph.edge_section_start_y(section), content="2")
  inspect(@graph.edge_section_end_x(section), content="20")
  inspect(@graph.edge_section_end_y(section), content="30")
}

///|
test "fixed layout provider does not resize fixed-size graph" {
  @graph.reset_graph_model_for_test()
  let graph = @graph.create_graph()
  @graph.node_set_dimensions(graph, 77.0, 66.0)
  @graph.node_set_bool_property(graph, node_size_fixed_graph_size, true)

  let child = @graph.create_node(Some(graph))
  @graph.node_set_dimensions(child, 10.0, 10.0)
  @graph.node_set_layout_option_string_by_id(
    child, "org.eclipse.elk.position", "(100,100)",
  )

  let provider = new_fixed_layout_provider()
  provider.layout(graph, new_basic_progress_monitor())

  inspect(@graph.node_width(graph), content="77")
  inspect(@graph.node_height(graph), content="66")
}
