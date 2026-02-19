///|
fn port_list_sorter_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown side")
}

///|
fn port_list_sorter_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn port_list_sorter_test_new_node(graph : LGraph, layer : Layer) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node
}

///|
fn port_list_sorter_test_new_port(
  node : LNode,
  side : String,
  id : Int,
) -> LPort {
  let port = new_l_port()
  port.set_side(port_list_sorter_test_port_side(side))
  port.set_id(id)
  port.set_node(Some(node))
  port
}

///|
fn port_list_sorter_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "port list sorter reports expected task name" {
  let processor = new_port_list_sorter_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Port order processing")
}

///|
test "port list sorter sorts fixed-order ports by side and index" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = port_list_sorter_test_new_node(graph, layer)
  node.set_property_string(port_constraints, "FIXED_ORDER")

  let east_2 = port_list_sorter_test_new_port(node, "EAST", 102)
  east_2.set_property_int(layered_options_port_index, 2)
  let north_0 = port_list_sorter_test_new_port(node, "NORTH", 100)
  north_0.set_property_int(layered_options_port_index, 0)
  let south_0 = port_list_sorter_test_new_port(node, "SOUTH", 103)
  south_0.set_property_int(layered_options_port_index, 0)
  let east_1 = port_list_sorter_test_new_port(node, "EAST", 101)
  east_1.set_property_int(layered_options_port_index, 1)
  let west_0 = port_list_sorter_test_new_port(node, "WEST", 104)
  west_0.set_property_int(layered_options_port_index, 0)

  let processor = new_port_list_sorter_layout_processor()
  processor.process(graph, None)

  let ports = node.get_ports()
  assert_eq(ports.length(), 5)
  assert_eq(port_side_to_string(ports[0].get_side()), "NORTH")
  assert_eq(port_side_to_string(ports[1].get_side()), "EAST")
  assert_eq(port_side_to_string(ports[2].get_side()), "EAST")
  assert_eq(port_side_to_string(ports[3].get_side()), "SOUTH")
  assert_eq(port_side_to_string(ports[4].get_side()), "WEST")

  assert_eq(ports[1].get_property_int(layered_options_port_index), 1)
  assert_eq(ports[2].get_property_int(layered_options_port_index), 2)
}

///|
test "port list sorter reverses south/west order for fixed-side constraints" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = port_list_sorter_test_new_node(graph, layer)
  node.set_property_string(port_constraints, "FIXED_SIDE")

  ignore(port_list_sorter_test_new_port(node, "SOUTH", 301))
  ignore(port_list_sorter_test_new_port(node, "SOUTH", 302))
  ignore(port_list_sorter_test_new_port(node, "WEST", 401))
  ignore(port_list_sorter_test_new_port(node, "WEST", 402))

  let processor = new_port_list_sorter_layout_processor()
  processor.process(graph, None)

  let ports = node.get_ports()
  assert_eq(ports.length(), 4)
  assert_eq(ports[0].get_id(), 302)
  assert_eq(ports[1].get_id(), 301)
  assert_eq(ports[2].get_id(), 402)
  assert_eq(ports[3].get_id(), 401)
}

///|
test "port list sorter uses port-degree strategy on east and west sides" {
  let graph = new_l_graph()
  graph.set_property_string(
    layered_options_port_sorting_strategy, "PORT_DEGREE",
  )
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = port_list_sorter_test_new_node(graph, layer)
  node.set_property_string(port_constraints, "FIXED_SIDE")
  let sink = port_list_sorter_test_new_node(graph, layer)
  let source = port_list_sorter_test_new_node(graph, layer)

  let east_a = port_list_sorter_test_new_port(node, "EAST", 501)
  let east_b = port_list_sorter_test_new_port(node, "EAST", 502)
  let west_a = port_list_sorter_test_new_port(node, "WEST", 601)
  let west_b = port_list_sorter_test_new_port(node, "WEST", 602)

  let sink_in = port_list_sorter_test_new_port(sink, "WEST", 700)
  let source_out = port_list_sorter_test_new_port(source, "EAST", 800)

  ignore(port_list_sorter_test_new_edge(east_a, sink_in))
  let reversed_out = port_list_sorter_test_new_edge(east_a, sink_in)
  reversed_out.set_property_bool(internal_properties_reversed, true)
  ignore(port_list_sorter_test_new_edge(east_b, sink_in))
  ignore(port_list_sorter_test_new_edge(east_b, sink_in))

  ignore(port_list_sorter_test_new_edge(source_out, west_a))
  ignore(port_list_sorter_test_new_edge(source_out, west_b))
  ignore(port_list_sorter_test_new_edge(source_out, west_b))
  let reversed_in = port_list_sorter_test_new_edge(source_out, west_b)
  reversed_in.set_property_bool(internal_properties_reversed, true)

  let processor = new_port_list_sorter_layout_processor()
  processor.process(graph, None)

  let ports = node.get_ports()
  assert_eq(ports.length(), 4)
  assert_eq(ports[0].get_id(), 502)
  assert_eq(ports[1].get_id(), 501)
  assert_eq(ports[2].get_id(), 601)
  assert_eq(ports[3].get_id(), 602)
}

///|
test "port list sorter strategy creates port list sorter processor" {
  let factory = layered_intermediate_processor_factory(
    port_list_sorter_test_strategy("PORT_LIST_SORTER"),
  )
  let processor = factory.create()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Port order processing")
}
