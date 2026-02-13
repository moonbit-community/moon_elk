///|
fn concrete_sort_by_input_model_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn concrete_sort_by_input_model_new_node(
  graph : LGraph,
  layer : Layer,
  model_order : Int,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node.set_property_string(port_constraints, "FIXED_SIDE")
  node.set_property_int(internal_properties_model_order, model_order)
  node
}

///|
fn concrete_sort_by_input_model_new_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_side(concrete_sort_by_input_model_port_side(side))
  port.set_node(Some(node))
  port
}

///|
fn concrete_sort_by_input_model_connect(
  source : LPort,
  target : LPort,
  model_order : Int,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge.set_property_int(internal_properties_model_order, model_order)
  edge
}

///|
fn concrete_sort_by_input_model_configure_graph(graph : LGraph) -> Unit {
  graph.set_property_string(
    layered_options_consider_model_order_strategy, "PREFER_EDGES",
  )
  graph.set_property_string(
    layered_options_consider_model_order_long_edge_strategy, "DUMMY_NODE_OVER",
  )
  graph.set_property_string(
    layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
    "ONLY_WITHIN_GROUP",
  )
}

///|
fn concrete_sort_by_input_model_run(
  graph : LGraph,
  port_model_order : Bool,
) -> Unit {
  graph.set_property_bool(
    layered_options_consider_model_order_port_model_order, port_model_order,
  )
  let processor = new_sort_by_input_model_processor_layout_processor()
  processor.process(graph, None)
}

///|
fn concrete_sort_by_input_model_port_index(node : LNode, port : LPort) -> Int {
  let ports = node.get_ports()
  for i in 0..<ports.length() {
    if ports[i].get_handle() == port.get_handle() {
      return i
    }
  }
  -1
}

///|
fn concrete_sort_by_input_model_node_index(layer : Layer, node : LNode) -> Int {
  let nodes = layer.get_nodes()
  for i in 0..<nodes.length() {
    if nodes[i].get_handle() == node.get_handle() {
      return i
    }
  }
  -1
}

///|
fn concrete_sort_by_input_model_new_single_case(
  source_side : String,
  target_side : String,
) -> (LGraph, LNode, LPort, LPort, LNode, LPort, LPort) {
  let graph = new_l_graph()
  concrete_sort_by_input_model_configure_graph(graph)

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let source = concrete_sort_by_input_model_new_node(graph, layer0, 0)
  let target = concrete_sort_by_input_model_new_node(graph, layer1, 0)

  let p1 = concrete_sort_by_input_model_new_port(source, source_side)
  let p2 = concrete_sort_by_input_model_new_port(source, source_side)
  let p3 = concrete_sort_by_input_model_new_port(target, target_side)
  let p4 = concrete_sort_by_input_model_new_port(target, target_side)

  ignore(concrete_sort_by_input_model_connect(p1, p4, 0))
  ignore(concrete_sort_by_input_model_connect(p2, p3, 1))

  (graph, source, p1, p2, target, p3, p4)
}

///|
fn concrete_sort_by_input_model_new_multiple_case(
  source_side : String,
  target_side : String,
) -> (LGraph, Layer, LNode, LNode, LNode, LPort, LPort) {
  let graph = new_l_graph()
  concrete_sort_by_input_model_configure_graph(graph)

  let layer0 = new_layer(graph)
  let layer1 = new_layer(graph)
  graph.get_layers().push(layer0)
  graph.get_layers().push(layer1)

  let ni = concrete_sort_by_input_model_new_node(graph, layer0, 1)
  let n1 = concrete_sort_by_input_model_new_node(graph, layer0, 0)
  let target = concrete_sort_by_input_model_new_node(graph, layer1, 0)

  let p1 = concrete_sort_by_input_model_new_port(n1, source_side)
  let p2 = concrete_sort_by_input_model_new_port(ni, source_side)
  let p3 = concrete_sort_by_input_model_new_port(target, target_side)
  let p4 = concrete_sort_by_input_model_new_port(target, target_side)

  ignore(concrete_sort_by_input_model_connect(p1, p4, 0))
  ignore(concrete_sort_by_input_model_connect(p2, p3, 1))

  (graph, layer0, n1, ni, target, p3, p4)
}

///|
test "concrete sort by input model keeps source-port order and target ordering mode-invariant" {
  let source_sides = ["EAST", "NORTH", "SOUTH", "WEST"]
  let target_sides = ["WEST", "NORTH", "SOUTH", "EAST"]

  for source_side in source_sides {
    for target_side in target_sides {
      let (graph, source, p1, p2, target, p3, p4) = concrete_sort_by_input_model_new_single_case(
        source_side, target_side,
      )

      concrete_sort_by_input_model_run(graph, false)
      let p1_index_first = concrete_sort_by_input_model_port_index(source, p1)
      let p2_index_first = concrete_sort_by_input_model_port_index(source, p2)
      assert_true(p1_index_first >= 0)
      assert_true(p2_index_first >= 0)
      let p1_before_p2_first = p1_index_first < p2_index_first

      let p3_before_p4_first = concrete_sort_by_input_model_port_index(
          target, p3,
        ) <
        concrete_sort_by_input_model_port_index(target, p4)

      concrete_sort_by_input_model_run(graph, true)
      let p1_index_second = concrete_sort_by_input_model_port_index(source, p1)
      let p2_index_second = concrete_sort_by_input_model_port_index(source, p2)
      assert_true(p1_index_second >= 0)
      assert_true(p2_index_second >= 0)
      let p1_before_p2_second = p1_index_second < p2_index_second

      let p3_before_p4_second = concrete_sort_by_input_model_port_index(
          target, p3,
        ) <
        concrete_sort_by_input_model_port_index(target, p4)
      assert_eq(p1_before_p2_second, p1_before_p2_first)
      assert_eq(p3_before_p4_second, p3_before_p4_first)
    }
  }
}

///|
test "concrete sort by input model keeps source-node order and target ordering mode-invariant for multiple nodes" {
  let source_sides = ["EAST", "NORTH", "SOUTH", "WEST"]
  let target_sides = ["WEST", "NORTH", "SOUTH", "EAST"]

  for source_side in source_sides {
    for target_side in target_sides {
      let (graph, layer0, n1, ni, target, p3, p4) = concrete_sort_by_input_model_new_multiple_case(
        source_side, target_side,
      )

      concrete_sort_by_input_model_run(graph, false)
      let n1_index_first = concrete_sort_by_input_model_node_index(layer0, n1)
      let ni_index_first = concrete_sort_by_input_model_node_index(layer0, ni)
      assert_true(n1_index_first < ni_index_first)

      let p3_before_p4_first = concrete_sort_by_input_model_port_index(
          target, p3,
        ) <
        concrete_sort_by_input_model_port_index(target, p4)

      concrete_sort_by_input_model_run(graph, true)
      let n1_index_second = concrete_sort_by_input_model_node_index(layer0, n1)
      let ni_index_second = concrete_sort_by_input_model_node_index(layer0, ni)
      assert_true(n1_index_second < ni_index_second)

      let p3_before_p4_second = concrete_sort_by_input_model_port_index(
          target, p3,
        ) <
        concrete_sort_by_input_model_port_index(target, p4)
      assert_eq(p3_before_p4_second, p3_before_p4_first)
    }
  }
}
