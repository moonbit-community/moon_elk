///|
fn cm_group_model_order_test_graph(
  strategy : String,
  enforced_orders : String,
) -> LGraph {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    strategy,
  )
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_enforced_group_orders,
    enforced_orders,
  )
  graph
}

///|
fn cm_group_model_order_test_node(model_order : Int?, group_id : Int) -> LNode {
  let node = new_l_node()
  node.set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    group_id,
  )
  match model_order {
    Some(value) => node.set_property_int(internal_properties_model_order, value)
    None => ()
  }
  node
}

///|
fn cm_group_model_order_test_port(model_order : Int?, group_id : Int) -> LPort {
  let port = new_l_port()
  port.set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    group_id,
  )
  match model_order {
    Some(value) => port.set_property_int(internal_properties_model_order, value)
    None => ()
  }
  port
}

///|
fn cm_group_model_order_test_edge(model_order : Int?, group_id : Int) -> LEdge {
  let edge = new_l_edge()
  edge.set_property_int(
    layered_options_consider_model_order_group_model_order_crossing_minimization_id,
    group_id,
  )
  match model_order {
    Some(value) => edge.set_property_int(internal_properties_model_order, value)
    None => ()
  }
  edge
}

///|
test "CMGroupModelOrderCalculator computes node order for model and enforced strategies" {
  let element = cm_group_model_order_test_node(Some(7), 3)
  let other = cm_group_model_order_test_node(Some(2), 1)
  let offset = 100

  let model_graph = cm_group_model_order_test_graph("MODEL_ORDER", "")
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order(
      element, other, model_graph, offset,
    ),
    7,
  )

  let only_within_graph = cm_group_model_order_test_graph(
    "ONLY_WITHIN_GROUP", "",
  )
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order(
      element, other, only_within_graph, offset,
    ),
    7,
  )

  let enforced_graph = cm_group_model_order_test_graph("ENFORCED", "[1, 3]")
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order(
      element, other, enforced_graph, offset,
    ),
    307,
  )

  let other_not_enforced = cm_group_model_order_test_node(Some(2), 4)
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order(
      element, other_not_enforced, enforced_graph, offset,
    ),
    7,
  )

  let missing_model_order = cm_group_model_order_test_node(None, 3)
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order(
      missing_model_order, other, enforced_graph, offset,
    ),
    -1,
  )
}

///|
test "CMGroupModelOrderCalculator computes port group order when enforced ids match" {
  let element = cm_group_model_order_test_port(Some(6), 2)
  let other = cm_group_model_order_test_port(Some(9), 5)
  let graph = cm_group_model_order_test_graph("ENFORCED", "2,5")

  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_port(
      element, other, graph, 50,
    ),
    106,
  )
}

///|
test "CMGroupModelOrderCalculator falls back to plain port model order when not enforced" {
  let element = cm_group_model_order_test_port(Some(6), 2)
  let other = cm_group_model_order_test_port(Some(9), 4)
  let graph = cm_group_model_order_test_graph("ENFORCED", "2,5")
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_port(
      element, other, graph, 50,
    ),
    6,
  )

  let missing_model_order = cm_group_model_order_test_port(None, 2)
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_port(
      missing_model_order, other, graph, 50,
    ),
    -1,
  )
}

///|
test "CMGroupModelOrderCalculator computes edge order for model and enforced strategies" {
  let element = cm_group_model_order_test_edge(Some(8), 4)
  let other = cm_group_model_order_test_edge(Some(3), 7)

  let model_graph = cm_group_model_order_test_graph("MODEL_ORDER", "")
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_edge(
      element, other, model_graph, 40,
    ),
    8,
  )

  let enforced_graph = cm_group_model_order_test_graph("ENFORCED", "[4, 7]")
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_edge(
      element, other, enforced_graph, 40,
    ),
    168,
  )

  let missing_model_order = cm_group_model_order_test_edge(None, 4)
  assert_eq(
    cm_group_model_order_calculate_model_order_or_group_model_order_edge(
      missing_model_order, other, enforced_graph, 40,
    ),
    -1,
  )
}
