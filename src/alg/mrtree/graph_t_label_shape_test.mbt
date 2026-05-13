///|
test "Mrtree TLabel attaches to edge and formats text" {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  let source = new_mrtree_node(1, graph, label="src")
  let target = new_mrtree_node(2, graph, label="tgt")
  let edge = new_mrtree_edge(source, target)

  let empty_label = new_mrtree_label(edge, "")
  let named_label = new_mrtree_label(edge, "name")

  @core_debug.assert_eq(mrtree_edge_labels(edge), [empty_label, named_label])
  @core_debug.assert_eq(mrtree_label_to_string(empty_label), "l[n_src->n_tgt]")
  @core_debug.assert_eq(mrtree_label_to_string(named_label), "l_name")
}

///|
test "Mrtree edge set source and target updates node edge lists" {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  let n1 = new_mrtree_node(1, graph, label="n1")
  let n2 = new_mrtree_node(2, graph, label="n2")
  let n3 = new_mrtree_node(3, graph, label="n3")
  let edge = new_mrtree_edge(n1, n2)

  mrtree_edge_set_source(edge, n3)
  @core_debug.assert_eq(mrtree_node_outgoing_edges(n1).contains(edge), false)
  @core_debug.assert_eq(mrtree_node_outgoing_edges(n3).contains(edge), true)

  mrtree_edge_set_target(edge, n1)
  @core_debug.assert_eq(mrtree_node_incoming_edges(n2).contains(edge), false)
  @core_debug.assert_eq(mrtree_node_incoming_edges(n1).contains(edge), true)
}

///|
test "Mrtree shape helpers read node and label geometry" {
  reset_mrtree_graph_model_for_test()
  let graph = new_mrtree_graph()
  let source = new_mrtree_node(1, graph, label="src")
  let target = new_mrtree_node(2, graph, label="tgt")
  let edge = new_mrtree_edge(source, target)
  let label = new_mrtree_label(edge, "shape")

  let node_pos = mrtree_node_position(source)
  ignore(node_pos.set_xy(10.0, 20.0))
  let node_size = mrtree_node_size(source)
  ignore(node_size.set_xy(30.0, 40.0))

  let label_pos = mrtree_label_position(label)
  ignore(label_pos.set_xy(50.0, 60.0))
  let label_size = mrtree_label_size(label)
  ignore(label_size.set_xy(70.0, 80.0))

  let node_shape = new_mrtree_node_shape(source)
  @core_debug.assert_eq(mrtree_shape_position(node_shape).x, 10.0)
  @core_debug.assert_eq(mrtree_shape_position(node_shape).y, 20.0)
  @core_debug.assert_eq(mrtree_shape_size(node_shape).x, 30.0)
  @core_debug.assert_eq(mrtree_shape_size(node_shape).y, 40.0)

  let label_shape = new_mrtree_label_shape(label)
  @core_debug.assert_eq(mrtree_shape_position(label_shape).x, 50.0)
  @core_debug.assert_eq(mrtree_shape_position(label_shape).y, 60.0)
  @core_debug.assert_eq(mrtree_shape_size(label_shape).x, 70.0)
  @core_debug.assert_eq(mrtree_shape_size(label_shape).y, 80.0)
}
