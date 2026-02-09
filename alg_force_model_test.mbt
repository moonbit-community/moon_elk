///|
fn build_two_node_graph() -> (FGraph, FNode, FNode) {
  let graph = new_fgraph()
  graph.set_property(force_interactive, true)
  graph.set_int_property(force_iterations, 1)
  graph.set_double_property(force_spacing_node_node, 5.0)
  graph.set_double_property(force_repulsion, 5.0)
  graph.set_double_property(force_temperature, 0.1)
  let left = new_fnode(label="left")
  fnode_set_id(left, 0)
  fnode_set_int_property(left, force_priority, 1)
  ignore(fnode_position(left).set_xy(0.0, 0.0))
  ignore(fnode_size(left).set_xy(2.0, 2.0))
  let right = new_fnode(label="right")
  fnode_set_id(right, 1)
  fnode_set_int_property(right, force_priority, 1)
  ignore(fnode_position(right).set_xy(10.0, 0.0))
  ignore(fnode_size(right).set_xy(2.0, 2.0))
  graph.add_node(left)
  graph.add_node(right)
  let edge = new_fedge()
  fedge_set_source(edge, left)
  fedge_set_target(edge, right)
  fedge_set_int_property(edge, force_priority, 1)
  graph.add_edge(edge)
  (graph, left, right)
}

///|
test "EadesModel constants" {
  assert_eq(eades_model_repulsive(2.0, 5.0), 1.25)
  assert_eq(eades_model_repulsive(0.0, 5.0), 500.0)
  assert_eq(eades_model_attractive(0.0, 3.0), -100.0)
}

///|
test "FruchtermanReingold constants" {
  assert_eq(fr_model_repulsive(2.0, 3.0), 4.5)
  assert_eq(fr_model_repulsive(0.0, 3.0), 900.0)
  assert_eq(fr_model_attractive(2.0, 4.0), 1.0)
}

///|
test "EadesModel layout changes positions" {
  reset_force_graph_model_for_test()
  let (graph, left, right) = build_two_node_graph()
  new_eades_model().layout(graph, new_null_elk_progress_monitor())
  let moved = fnode_position(left).x != 0.0 || fnode_position(right).x != 10.0
  assert_eq(moved, true)
}

///|
test "FRModel layout keeps finite positions" {
  reset_force_graph_model_for_test()
  let (graph, left, right) = build_two_node_graph()
  new_fruchterman_reingold_model().layout(
    graph,
    new_null_elk_progress_monitor(),
  )
  assert_eq(fnode_position(left).is_nan(), false)
  assert_eq(fnode_position(left).is_infinite(), false)
  assert_eq(fnode_position(right).is_nan(), false)
  assert_eq(fnode_position(right).is_infinite(), false)
}

///|
test "Components recombine sorts by priority" {
  reset_force_graph_model_for_test()
  let high = new_fgraph()
  high.set_double_property(force_aspect_ratio, 100.0)
  high.set_double_property(force_spacing_node_node, 10.0)
  let high_node = new_fnode(label="high")
  fnode_set_id(high_node, 0)
  fnode_set_int_property(high_node, force_priority, 5)
  ignore(fnode_position(high_node).set_xy(0.0, 0.0))
  ignore(fnode_size(high_node).set_xy(2.0, 2.0))
  high.add_node(high_node)
  let low = new_fgraph()
  low.set_double_property(force_aspect_ratio, 100.0)
  low.set_double_property(force_spacing_node_node, 10.0)
  let low_node = new_fnode(label="low")
  fnode_set_id(low_node, 0)
  fnode_set_int_property(low_node, force_priority, 1)
  ignore(fnode_position(low_node).set_xy(0.0, 0.0))
  ignore(fnode_size(low_node).set_xy(2.0, 2.0))
  low.add_node(low_node)
  let merged = new_components_processor().recombine([low, high])
  assert_eq(merged.get_nodes().length(), 2)
  assert_eq(fnode_position(high_node).x < fnode_position(low_node).x, true)
}
