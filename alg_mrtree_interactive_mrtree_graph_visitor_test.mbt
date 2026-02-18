///|
fn interactive_mrtree_graph_visitor_test_root() -> ElkNode {
  let root = create_graph()
  ignore(create_node(Some(root)))
  root
}

///|
test "interactive mrtree graph visitor sets options for mrtree algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()
  node_set_layout_option_string_by_id(
    root,
    algorithm.get_id(),
    mrtree_algorithm_id,
  )

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_true(node_get_bool_property(root, interactive))
  assert_eq(node_get_string_property(root, mrtree_weighting), "CONSTRAINT")
}

///|
test "interactive mrtree graph visitor ignores non mrtree algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()
  node_set_layout_option_string_by_id(
    root,
    algorithm.get_id(),
    layered_algorithm_id,
  )

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_false(node_get_bool_property(root, interactive))
  assert_eq(node_get_string_property(root, mrtree_weighting), "MODEL_ORDER")
}

///|
test "interactive mrtree graph visitor ignores missing algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_false(node_get_bool_property(root, interactive))
  assert_eq(node_get_string_property(root, mrtree_weighting), "MODEL_ORDER")
}
