///|
test "elk graph package core constants match reference values" {
  inspect(elk_graph_ename == "graph", content="true")
  inspect(
    elk_graph_ens_uri == "http://www.eclipse.org/elk/ElkGraph",
    content="true",
  )
  inspect(elk_graph_ens_prefix == "graph", content="true")
  inspect(elk_graph_elk_node_classifier_id == 6, content="true")
  inspect(elk_graph_elk_edge_section_classifier_id == 10, content="true")
  inspect(elk_graph_property_value_classifier_id == 13, content="true")
}

///|
test "elk graph factory impl constructors map to graph model creators" {
  reset_graph_model_for_test()

  let factory = new_elk_graph_factory_impl()
  let node = factory.create_elk_node()
  let port = factory.create_elk_port()
  let edge = factory.create_elk_edge()
  let label = factory.create_elk_label()
  let bend_point = factory.create_elk_bend_point()
  let section = factory.create_elk_edge_section(edge)

  inspect(node_parent(node) is None, content="true")
  inspect(port_parent(port) is None, content="true")
  inspect(edge_containing_node(edge) is None, content="true")
  inspect(label_parent(label) is None, content="true")
  inspect(bend_point.get_x() == 0.0, content="true")
  inspect(bend_point.get_y() == 0.0, content="true")
  inspect(edge_sections(edge).length() == 1, content="true")
  inspect(edge_sections(edge)[0] == section, content="true")
  inspect(
    factory.get_elk_graph_package() == elk_graph_package_instance,
    content="true",
  )
}
