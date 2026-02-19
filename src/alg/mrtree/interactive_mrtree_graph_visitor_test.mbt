///|
fn interactive_mrtree_graph_visitor_test_root() -> @graph.ElkNode {
  let root = create_graph()
  ignore(@graph.create_node(Some(root)))
  root
}

///|
test "@core.interactive mrtree graph visitor sets options for mrtree @core.algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    mrtree_algorithm_id,
  )

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_true(@graph.node_get_bool_property(root, @core.interactive))
  assert_eq(
    @graph.node_get_string_property(root, mrtree_weighting),
    "CONSTRAINT",
  )
}

///|
test "@core.interactive mrtree graph visitor ignores non mrtree @core.algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_false(@graph.node_get_bool_property(root, @core.interactive))
  assert_eq(
    @graph.node_get_string_property(root, mrtree_weighting),
    "MODEL_ORDER",
  )
}

///|
test "@core.interactive mrtree graph visitor ignores missing @core.algorithm" {
  reset_graph_model_for_test()
  let root = interactive_mrtree_graph_visitor_test_root()

  let visitor = new_interactive_mrtree_graph_visitor()
  visitor.visit(root)

  assert_false(@graph.node_get_bool_property(root, @core.interactive))
  assert_eq(
    @graph.node_get_string_property(root, mrtree_weighting),
    "MODEL_ORDER",
  )
}
