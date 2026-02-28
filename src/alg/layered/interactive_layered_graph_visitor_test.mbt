///|
fn interactive_layered_graph_visitor_test_expect_layout_option(
  node : @graph.ElkNode,
  option_id : String,
  expected : String,
) -> Unit {
  match @graph.node_layout_option_string_value(node, option_id) {
    Some(value) =>
      if value != expected {
        abort(
          "unexpected layout option value, expected: " +
          expected +
          ", actual: " +
          value +
          ", option: " +
          option_id,
        )
      }
    None => abort("missing layout option: " + option_id)
  }
}

///|
fn interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
  node : @graph.ElkNode,
  option_id : String,
) -> Unit {
  match @graph.node_layout_option_string_value(node, option_id) {
    Some(value) =>
      if value.is_empty() {
        abort("unexpected empty layout option value")
      }
    None => abort("missing layout option")
  }
}

///|
fn interactive_layered_graph_visitor_test_require_position(
  node : @graph.ElkNode,
) -> @core.KVector {
  match
    @graph.node_layout_option_string_value(
      node,
      layered_options_position.get_id(),
    ) {
    Some(value) => {
      let parsed = @core.new_kvector()
      parsed.parse(value)
      parsed
    }
    None => abort("missing position layout option")
  }
}

///|
fn interactive_layered_graph_visitor_test_expect_typed_position(
  node : @graph.ElkNode,
) -> Bool {
  ignore(interactive_layered_graph_visitor_test_require_position(node))
  true
}

///|
test "@core.interactive layered graph visitor sets @core.interactive strategies" {
  reset_graph_model_for_test()
  let root = create_graph()
  ignore(@graph.create_node(Some(root)))

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_layering_strategy.get_id(),
    "LONGEST_PATH",
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_cycle_breaking_strategy.get_id(),
    "GREEDY",
  )
  @graph.node_set_string_property(
    root, layered_options_consider_model_order_strategy, "NODES_AND_EDGES",
  )
  @graph.node_set_bool_property(
    root, layered_options_crossing_minimization_force_node_model_order, true,
  )
  @graph.node_set_string_property(
    root, layered_options_crossing_minimization_strategy, "INTERACTIVE",
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  assert_true(
    @graph.node_get_bool_property(
      root, layered_options_crossing_minimization_semi_interactive,
    ),
  )
  assert_eq(
    @graph.node_get_string_property(root, layered_options_layering_strategy),
    "INTERACTIVE",
  )
  assert_eq(
    @graph.node_get_string_property(
      root, layered_options_cycle_breaking_strategy,
    ),
    "INTERACTIVE",
  )
  assert_eq(
    @graph.node_get_string_property(
      root, layered_options_consider_model_order_strategy,
    ),
    "NONE",
  )
  assert_false(
    @graph.node_get_bool_property(
      root, layered_options_crossing_minimization_force_node_model_order,
    ),
  )
  assert_eq(
    @graph.node_get_string_property(
      root, layered_options_crossing_minimization_strategy,
    ),
    "LAYER_SWEEP",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    root,
    layered_options_layering_strategy.get_id(),
    "INTERACTIVE",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    root,
    layered_options_cycle_breaking_strategy.get_id(),
    "INTERACTIVE",
  )
}

///|
test "@core.interactive layered graph visitor ignores non-layered roots" {
  reset_graph_model_for_test()
  let root = create_graph()
  ignore(@graph.create_node(Some(root)))

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    "org.eclipse.elk.force",
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_layering_strategy.get_id(),
    "LONGEST_PATH",
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    layered_options_cycle_breaking_strategy.get_id(),
    "MODEL_ORDER",
  )
  @graph.node_set_string_property(
    root, layered_options_consider_model_order_strategy, "NODES_AND_EDGES",
  )
  @graph.node_set_bool_property(
    root, layered_options_crossing_minimization_force_node_model_order, true,
  )
  @graph.node_set_string_property(
    root, layered_options_crossing_minimization_strategy, "INTERACTIVE",
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  assert_false(
    @graph.node_get_bool_property(
      root, layered_options_crossing_minimization_semi_interactive,
    ),
  )
  assert_eq(
    @graph.node_get_string_property(
      root, layered_options_consider_model_order_strategy,
    ),
    "NODES_AND_EDGES",
  )
  assert_true(
    @graph.node_get_bool_property(
      root, layered_options_crossing_minimization_force_node_model_order,
    ),
  )
  assert_eq(
    @graph.node_get_string_property(
      root, layered_options_crossing_minimization_strategy,
    ),
    "INTERACTIVE",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    root,
    layered_options_layering_strategy.get_id(),
    "LONGEST_PATH",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    root,
    layered_options_cycle_breaking_strategy.get_id(),
    "MODEL_ORDER",
  )
}

///|
test "@core.interactive layered graph visitor translates layer constraints to layer choice constraints" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first_node = @graph.create_node(Some(root))
  let last_node = @graph.create_node(Some(root))

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_string_property(
    first_node, layered_options_layering_layer_constraint, "FIRST",
  )
  @graph.node_set_layout_option_string_by_id(
    last_node,
    layered_options_layering_layer_constraint.get_id(),
    "LAST",
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  assert_eq(
    @graph.node_get_string_property(
      first_node, layered_options_layering_layer_constraint,
    ),
    "NONE",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    first_node,
    layered_options_layering_layer_choice_constraint.get_id(),
    "0",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    last_node,
    layered_options_layering_layer_constraint.get_id(),
    "NONE",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    last_node,
    layered_options_layering_layer_choice_constraint.get_id(),
    interactive_layered_graph_visitor_last_layer_index.to_string(),
  )
}

///|
test "@core.interactive layered graph visitor shifts same-layer neighbors for constrained nodes" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  @graph.node_set_identifier(source, "source")
  @graph.node_set_identifier(target, "target")
  @graph.node_set_dimensions(source, 0.0, 0.0)
  @graph.node_set_dimensions(target, 0.0, 0.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )
  @graph.node_set_layout_option_string_by_id(
    source,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    target,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    source,
    layered_options_layering_layer_choice_constraint.get_id(),
    "0",
  )

  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  interactive_layered_graph_visitor_test_expect_layout_option(
    source,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    target,
    layered_options_layering_layer_id.get_id(),
    "1",
  )
}

///|
test "@core.interactive layered graph visitor reads typed layer choice constraints like Java properties" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  @graph.node_set_identifier(source, "source")
  @graph.node_set_identifier(target, "target")
  @graph.node_set_dimensions(source, 0.0, 0.0)
  @graph.node_set_dimensions(target, 0.0, 0.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )
  @graph.node_set_layout_option_string_by_id(
    source,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    target,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_int_property(
    source, layered_options_layering_layer_choice_constraint, 0,
  )

  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  interactive_layered_graph_visitor_test_expect_layout_option(
    target,
    layered_options_layering_layer_id.get_id(),
    "1",
  )
  assert_true(
    @graph.node_has_int_property(target, layered_options_layering_layer_id),
  )
  assert_eq(
    @graph.node_get_int_property(target, layered_options_layering_layer_id),
    1,
  )
}

///|
test "@core.interactive layered graph visitor propagates position constraints through relative constraints" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first = @graph.create_node(Some(root))
  let second = @graph.create_node(Some(root))
  let plain = @graph.create_node(Some(root))
  @graph.node_set_identifier(first, "first")
  @graph.node_set_identifier(second, "second")
  @graph.node_set_identifier(plain, "plain")
  @graph.node_set_dimensions(first, 0.0, 0.0)
  @graph.node_set_dimensions(second, 0.0, 0.0)
  @graph.node_set_dimensions(plain, 0.0, 0.0)
  @graph.node_set_location(first, 0.0, 0.0)
  @graph.node_set_location(second, 0.0, 10.0)
  @graph.node_set_location(plain, 0.0, 20.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )

  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    second,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    plain,
    layered_options_layering_layer_id.get_id(),
    "0",
  )

  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_crossing_minimization_position_choice_constraint.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    @graph.node_identifier(second),
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  interactive_layered_graph_visitor_test_expect_layout_option(
    second,
    layered_options_crossing_minimization_position_choice_constraint.get_id(),
    "1",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    first,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    "",
  )

  interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
    first,
    layered_options_position.get_id(),
  )
  assert_true(
    interactive_layered_graph_visitor_test_expect_typed_position(first),
  )
  interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
    second,
    layered_options_position.get_id(),
  )
  assert_true(
    interactive_layered_graph_visitor_test_expect_typed_position(second),
  )
  interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
    plain,
    layered_options_position.get_id(),
  )
  assert_true(
    interactive_layered_graph_visitor_test_expect_typed_position(plain),
  )
}

///|
test "@core.interactive layered graph visitor breaks relative-constraint cycles like Java sortRCNodes" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first = @graph.create_node(Some(root))
  let second = @graph.create_node(Some(root))
  @graph.node_set_identifier(first, "first")
  @graph.node_set_identifier(second, "second")
  @graph.node_set_dimensions(first, 0.0, 0.0)
  @graph.node_set_dimensions(second, 0.0, 0.0)
  @graph.node_set_location(first, 0.0, 0.0)
  @graph.node_set_location(second, 0.0, 10.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )
  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    second,
    layered_options_layering_layer_id.get_id(),
    "0",
  )

  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    @graph.node_identifier(second),
  )
  @graph.node_set_layout_option_string_by_id(
    second,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    @graph.node_identifier(first),
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  interactive_layered_graph_visitor_test_expect_layout_option(
    first,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    "",
  )
  interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
    first,
    layered_options_position.get_id(),
  )
  interactive_layered_graph_visitor_test_expect_non_empty_layout_option(
    second,
    layered_options_position.get_id(),
  )
}

///|
test "@core.interactive layered graph visitor converts both-RC nodes to PC path when predecessor has PC" {
  reset_graph_model_for_test()
  let root = create_graph()
  let constrained = @graph.create_node(Some(root))
  let predecessor = @graph.create_node(Some(root))
  let successor = @graph.create_node(Some(root))
  @graph.node_set_identifier(constrained, "constrained")
  @graph.node_set_identifier(predecessor, "predecessor")
  @graph.node_set_identifier(successor, "successor")
  @graph.node_set_dimensions(constrained, 0.0, 0.0)
  @graph.node_set_dimensions(predecessor, 0.0, 0.0)
  @graph.node_set_dimensions(successor, 0.0, 0.0)
  @graph.node_set_location(constrained, 0.0, 20.0)
  @graph.node_set_location(predecessor, 0.0, 0.0)
  @graph.node_set_location(successor, 0.0, 40.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )

  @graph.node_set_layout_option_string_by_id(
    constrained,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    predecessor,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    successor,
    layered_options_layering_layer_id.get_id(),
    "0",
  )

  @graph.node_set_layout_option_string_by_id(
    predecessor,
    layered_options_crossing_minimization_position_choice_constraint.get_id(),
    "2",
  )
  @graph.node_set_layout_option_string_by_id(
    constrained,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    @graph.node_identifier(predecessor),
  )
  @graph.node_set_layout_option_string_by_id(
    constrained,
    layered_options_crossing_minimization_in_layer_succ_of.get_id(),
    @graph.node_identifier(successor),
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  interactive_layered_graph_visitor_test_expect_layout_option(
    constrained,
    layered_options_crossing_minimization_position_choice_constraint.get_id(),
    "1",
  )
  interactive_layered_graph_visitor_test_expect_layout_option(
    constrained,
    layered_options_crossing_minimization_in_layer_pred_of.get_id(),
    "",
  )
}

///|
test "@core.interactive layered graph visitor places layer-choice -1 nodes before unconstrained layers" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first_layer_node = @graph.create_node(Some(root))
  let unconstrained_node = @graph.create_node(Some(root))
  @graph.node_set_identifier(first_layer_node, "first")
  @graph.node_set_identifier(unconstrained_node, "plain")
  @graph.node_set_dimensions(first_layer_node, 0.0, 0.0)
  @graph.node_set_dimensions(unconstrained_node, 0.0, 0.0)
  @graph.node_set_location(first_layer_node, 0.0, 0.0)
  @graph.node_set_location(unconstrained_node, 0.0, 10.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "RIGHT",
  )
  @graph.node_set_layout_option_string_by_id(
    first_layer_node,
    layered_options_layering_layer_choice_constraint.get_id(),
    "-1",
  )
  @graph.node_set_layout_option_string_by_id(
    unconstrained_node,
    layered_options_layering_layer_id.get_id(),
    "0",
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  let first_position = interactive_layered_graph_visitor_test_require_position(
    first_layer_node,
  )
  let unconstrained_position = interactive_layered_graph_visitor_test_require_position(
    unconstrained_node,
  )
  assert_true(first_position.x <= unconstrained_position.x)
}

///|
test "@core.interactive layered graph visitor assigns orthogonal pseudo positions in DOWN @core.direction" {
  reset_graph_model_for_test()
  let root = create_graph()
  let first = @graph.create_node(Some(root))
  let second = @graph.create_node(Some(root))
  @graph.node_set_identifier(first, "first")
  @graph.node_set_identifier(second, "second")
  @graph.node_set_dimensions(first, 0.0, 0.0)
  @graph.node_set_dimensions(second, 0.0, 0.0)
  @graph.node_set_location(first, 1.0, 0.0)
  @graph.node_set_location(second, 3.0, 0.0)

  @graph.node_set_layout_option_string_by_id(
    root,
    @core.algorithm.get_id(),
    layered_algorithm_id,
  )
  @graph.node_set_layout_option_string_by_id(
    root,
    @core.direction.get_id(),
    "DOWN",
  )
  @graph.node_set_layout_option_string_by_id(
    first,
    layered_options_layering_layer_id.get_id(),
    "0",
  )
  @graph.node_set_layout_option_string_by_id(
    second,
    layered_options_layering_layer_id.get_id(),
    "0",
  )

  let visitor = new_interactive_layered_graph_visitor()
  visitor.visit(root)

  let first_position = interactive_layered_graph_visitor_test_require_position(
    first,
  )
  let second_position = interactive_layered_graph_visitor_test_require_position(
    second,
  )
  assert_true(second_position.x > first_position.x)
  assert_true(
    interactive_layered_graph_visitor_test_expect_typed_position(first),
  )
  assert_true(
    interactive_layered_graph_visitor_test_expect_typed_position(second),
  )
}
