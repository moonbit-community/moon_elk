///|
fn basic_consider_model_order_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn basic_consider_model_order_new_node(
  graph : LGraph,
  layer : Layer,
  model_order : Int,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_int(internal_properties_model_order, model_order)
  node.set_property_string(port_constraints, "FIXED_SIDE")
  node
}

///|
fn basic_consider_model_order_new_port(node : LNode, side : PortSide) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn basic_consider_model_order_connect(
  source : LPort,
  target : LPort,
  model_order : Int,
) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge.set_property_int(internal_properties_model_order, model_order)
}

///|
fn basic_consider_model_order_new_graph() -> (LGraph, Layer, Layer) {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_crossing_minimization_strategy, "LAYER_SWEEP",
  )
  graph.set_property_string(
    layered_options_consider_model_order_long_edge_strategy, "DUMMY_NODE_OVER",
  )
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    "ONLY_WITHIN_GROUP",
  )

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)
  (graph, layer0, layer1)
}

///|
fn basic_consider_model_order_run_case(
  strategy : String,
  weighted : Bool,
  use_port_model_order : Bool,
) -> Array[Int] {
  let (graph, layer0, layer1) = basic_consider_model_order_new_graph()
  graph.set_property_string(
    layered_options_consider_model_order_strategy, strategy,
  )
  graph.set_property_bool(
    layered_options_consider_model_order_port_model_order, use_port_model_order,
  )
  if weighted {
    graph.set_property_double(
      layered_options_consider_model_order_crossing_counter_node_influence, 0.001,
    )
    graph.set_property_double(
      layered_options_consider_model_order_crossing_counter_port_influence, 0.001,
    )
  }

  let high = basic_consider_model_order_new_node(graph, layer0, 1)
  let low = basic_consider_model_order_new_node(graph, layer0, 0)
  let target = basic_consider_model_order_new_node(graph, layer1, 0)

  let high_out = basic_consider_model_order_new_port(
    high,
    basic_consider_model_order_port_side("EAST"),
  )
  let low_out = basic_consider_model_order_new_port(
    low,
    basic_consider_model_order_port_side("EAST"),
  )
  let target_in_a = basic_consider_model_order_new_port(
    target,
    basic_consider_model_order_port_side("WEST"),
  )
  let target_in_b = basic_consider_model_order_new_port(
    target,
    basic_consider_model_order_port_side("WEST"),
  )

  basic_consider_model_order_connect(low_out, target_in_a, 0)
  basic_consider_model_order_connect(high_out, target_in_b, 1)

  let processor = new_sort_by_input_model_processor_layout_processor()
  processor.process(graph, None)

  let sorted_nodes = layer0.get_nodes()
  if sorted_nodes.length() != 2 {
    abort("unexpected source-layer node count")
  }
  [
    sorted_nodes[0].get_property_int(internal_properties_model_order),
    sorted_nodes[1].get_property_int(internal_properties_model_order),
  ]
}

///|
test "BasicConsiderModelOrder nodesAndEdgesConfigurator" {
  assert_eq(
    basic_consider_model_order_run_case("NODES_AND_EDGES", false, false),
    [0, 1],
  )
}

///|
test "BasicConsiderModelOrder nodesAndEdgesWeightedConfigurator" {
  assert_eq(
    basic_consider_model_order_run_case("NODES_AND_EDGES", true, false),
    [0, 1],
  )
}

///|
test "BasicConsiderModelOrder preferEdgesConfigurator" {
  assert_eq(basic_consider_model_order_run_case("PREFER_EDGES", false, false), [
    0, 1,
  ])
}

///|
test "BasicConsiderModelOrder preferEdgesWeightedConfigurator" {
  assert_eq(basic_consider_model_order_run_case("PREFER_EDGES", true, false), [
    0, 1,
  ])
}

///|
test "BasicConsiderModelOrder preferNodesConfigurator" {
  assert_eq(basic_consider_model_order_run_case("PREFER_NODES", false, false), [
    0, 1,
  ])
}

///|
test "BasicConsiderModelOrder preferNodesWeightedConfigurator" {
  assert_eq(basic_consider_model_order_run_case("PREFER_NODES", true, false), [
    0, 1,
  ])
}

///|
test "BasicConsiderModelOrder portModelOrderPreferEdges" {
  assert_eq(basic_consider_model_order_run_case("PREFER_EDGES", false, true), [
    0, 1,
  ])
}

///|
test "BasicConsiderModelOrder portModelOrderNodesAndEdges" {
  assert_eq(
    basic_consider_model_order_run_case("NODES_AND_EDGES", false, true),
    [0, 1],
  )
}

///|
test "BasicConsiderModelOrder portModelOrderPreferNodes" {
  assert_eq(basic_consider_model_order_run_case("PREFER_NODES", false, true), [
    0, 1,
  ])
}
