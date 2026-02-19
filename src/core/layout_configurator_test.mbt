///|
struct LayoutConfiguratorGraphFixture {
  root : @graph.ElkNode
  n1 : @graph.ElkNode
  n2 : @graph.ElkNode
}

///|
fn new_layout_configurator_graph_fixture() -> LayoutConfiguratorGraphFixture {
  let root = @graph.create_graph()
  let n1 = @graph.create_node(Some(root))
  let n2 = @graph.create_node(Some(root))
  { root, n1, n2 }
}

///|
test "LayoutConfigurator element overrides class" {
  @graph.reset_graph_model_for_test()
  let graph = new_layout_configurator_graph_fixture()
  let configurator = new_layout_configurator()
  configurator.configure_class_property(
    class_node_element, spacing_node_node, 22.0,
  )
  configurator.configure_node_property(graph.n1, spacing_node_node, 12.0)
  configurator.configure_node_property(graph.n2, spacing_node_node, 32.0)
  apply_visitors(graph.root, [configurator.to_visitor()])
  assert_eq(@graph.node_get_double_property(graph.root, spacing_node_node), 22.0)
  assert_eq(@graph.node_get_double_property(graph.n1, spacing_node_node), 12.0)
  assert_eq(@graph.node_get_double_property(graph.n2, spacing_node_node), 32.0)
}

///|
test "LayoutConfigurator combines element and class options" {
  @graph.reset_graph_model_for_test()
  let graph = new_layout_configurator_graph_fixture()
  let configurator = new_layout_configurator()
  configurator.configure_class_property(
    class_node_element, spacing_node_node, 42.0,
  )
  configurator.configure_node_property(graph.n1, spacing_edge_node, 42.0)
  apply_visitors(graph.root, [configurator.to_visitor()])
  assert_eq(@graph.node_get_double_property(graph.n1, spacing_node_node), 42.0)
  assert_eq(@graph.node_get_double_property(graph.n1, spacing_edge_node), 42.0)
}

///|
test "LayoutConfigurator combines multiple classes" {
  @graph.reset_graph_model_for_test()
  let graph = new_layout_configurator_graph_fixture()
  let configurator = new_layout_configurator()
  configurator.configure_class_property(
    class_node_element, spacing_node_node, 42.0,
  )
  configurator.configure_class_property(
    class_graph_element, spacing_edge_node, 42.0,
  )
  apply_visitors(graph.root, [configurator.to_visitor()])
  assert_eq(@graph.node_get_double_property(graph.n1, spacing_node_node), 42.0)
  assert_eq(@graph.node_get_double_property(graph.n1, spacing_edge_node), 42.0)
}

///|
test "LayoutConfigurator overrides existing options" {
  @graph.reset_graph_model_for_test()
  let graph = new_layout_configurator_graph_fixture()
  @graph.node_set_double_property(graph.root, spacing_node_node, 13.0)
  let configurator = new_layout_configurator()
  configurator.configure_class_property(
    class_node_element, spacing_node_node, 42.0,
  )
  apply_visitors(graph.root, [configurator.to_visitor()])
  assert_eq(@graph.node_get_double_property(graph.root, spacing_node_node), 42.0)
}

///|
test "LayoutConfigurator no-overwrite filter" {
  @graph.reset_graph_model_for_test()
  let graph = new_layout_configurator_graph_fixture()
  @graph.node_set_double_property(graph.root, spacing_node_node, 13.0)
  let configurator = new_layout_configurator()
  configurator.configure_class_property(
    class_node_element, spacing_node_node, 42.0,
  )
  configurator.add_filter(layout_configurator_no_overwrite_filter())
  apply_visitors(graph.root, [configurator.to_visitor()])
  assert_eq(@graph.node_get_double_property(graph.root, spacing_node_node), 13.0)
}
