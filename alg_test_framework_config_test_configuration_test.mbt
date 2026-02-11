///|
test "TestConfiguration adds edge labels and computes label sizes" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let source = create_node(Some(graph))
  let target = create_node(Some(graph))
  let edge = create_simple_edge(source, target)
  edge_set_identifier(edge, "e1")
  let config : TestConfiguration[Unit] = new_test_configuration(
    default_configuration=Some(
      new_default_configuration(
        edges=false,
        nodes=false,
        ports=false,
        edge_labels=true,
      ),
    ),
  )
  config.apply((), graph)
  assert_eq(edge_labels(edge).length(), 1)
  let label = edge_labels(edge)[0]
  inspect(label_text(label), content="e1")
  inspect(label_width(label) > 0.0, content="true")
  inspect(label_height(label) > 0.0, content="true")
}

///|
test "MethodTestConfiguration applies configurator callback" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let config : MethodTestConfiguration[Unit] = new_method_test_configuration(
    "configure",
    (_test_instance : Unit, current : ElkNode) => {
      node_set_bool_property(current, no_layout, true)
    },
  )
  config.apply((), graph)
  inspect(node_get_bool_property(graph, no_layout), content="true")
}

///|
test "ConfiguratorTestConfiguration applies layout configurator" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let child = create_node(Some(graph))
  let config : ConfiguratorTestConfiguration[Unit] = new_configurator_test_configuration(
    "provider",
    (_test_instance : Unit) => {
      let configurator = new_layout_configurator()
      configurator.configure_class_property(
        class_node_element, spacing_node_node, 17.0,
      )
      configurator
    },
  )
  config.apply((), graph)
  inspect(node_get_double_property(child, spacing_node_node), content="17")
}
