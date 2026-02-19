///|
test "basic impl constructors map to graph model creators" {
  reset_graph_model_for_test()

  let root = new_elk_node_impl()
  inspect(node_parent(root) is None, content="true")

  let child = new_elk_node_impl(parent=Some(root))
  inspect(node_parent(child) == Some(root), content="true")

  let port = new_elk_port_impl(parent=Some(root))
  inspect(port_parent(port) == Some(root), content="true")

  let edge = new_elk_edge_impl(containing_node=Some(root))
  inspect(edge_containing_node(edge) == Some(root), content="true")

  let label = new_elk_label_impl(parent=Some(make_node_label_parent(root)))
  if label_parent(label) is Some(NodeLabelParent(label_parent_node)) {
    inspect(label_parent_node == root, content="true")
  } else {
    inspect(false, content="true")
  }
}
