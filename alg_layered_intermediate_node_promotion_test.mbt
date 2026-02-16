///|
fn node_promotion_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn node_promotion_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
fn node_promotion_test_new_chain_graph() -> ElkNode {
  let graph = create_graph()
  node_set_string_property(graph, direction, "RIGHT")

  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let n3 = create_node(Some(graph))

  let e1 = create_edge(None)
  edge_add_source(e1, make_node_shape(n1))
  edge_add_target(e1, make_node_shape(n2))
  update_containment(Some(e1))

  let e2 = create_edge(None)
  edge_add_source(e2, make_node_shape(n2))
  edge_add_target(e2, make_node_shape(n3))
  update_containment(Some(e2))

  graph
}

///|
fn node_promotion_test_run_with_options(
  strategy : String,
  cycle_breaking_strategy : String?,
  layering_strategy : String?,
  ordering_strategy : String?,
) -> Unit {
  reset_graph_model_for_test()
  node_promotion_test_setup_plain_java_layout()

  let graph = node_promotion_test_new_chain_graph()
  node_set_string_property(
    graph, layered_options_layering_node_promotion_strategy, strategy,
  )

  match cycle_breaking_strategy {
    Some(value) =>
      node_set_layout_option_string_by_id(
        graph, "org.eclipse.elk.layered.cycleBreaking.strategy", value,
      )
    None => ()
  }
  match layering_strategy {
    Some(value) =>
      node_set_layout_option_string_by_id(
        graph, "org.eclipse.elk.layered.layering.strategy", value,
      )
    None => ()
  }
  match ordering_strategy {
    Some(value) =>
      node_set_string_property(
        graph, layered_options_consider_model_order_strategy, value,
      )
    None => ()
  }

  node_promotion_test_layout(graph)

  let resolved = node_get_string_property(graph, resolved_algorithm)
  if resolved != "org.eclipse.elk.layered" {
    abort(
      "node promotion strategy failed strategy=" +
      strategy +
      " resolved=" +
      resolved,
    )
  }
}

///|
test "NodePromotion non-model-order strategies resolve layered algorithm" {
  let strategies = [
    "NIKOLOV", "NIKOLOV_IMPROVED", "NIKOLOV_PIXEL", "NIKOLOV_IMPROVED_PIXEL", "NO_BOUNDARY",
  ]
  for strategy in strategies {
    node_promotion_test_run_with_options(strategy, None, None, None)
  }
}

///|
test "NodePromotion MODEL_ORDER_LEFT_TO_RIGHT resolves layered algorithm with upstream config" {
  node_promotion_test_run_with_options(
    "MODEL_ORDER_LEFT_TO_RIGHT",
    Some("MODEL_ORDER"),
    Some("LONGEST_PATH_SOURCE"),
    Some("PREFER_EDGES"),
  )
}

///|
test "NodePromotion MODEL_ORDER_RIGHT_TO_LEFT resolves layered algorithm with upstream config" {
  node_promotion_test_run_with_options(
    "MODEL_ORDER_RIGHT_TO_LEFT",
    Some("MODEL_ORDER"),
    Some("LONGEST_PATH"),
    Some("PREFER_EDGES"),
  )
}
