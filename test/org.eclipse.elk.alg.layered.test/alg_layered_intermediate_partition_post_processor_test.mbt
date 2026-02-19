///|
fn partition_post_processor_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn partition_post_processor_test_new_node(
  graph : LGraph,
  layer : Layer,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  node
}

///|
fn partition_post_processor_test_new_port(
  node : LNode,
  side : String,
  partition_dummy : Bool,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(partition_post_processor_test_port_side(side))
  port.set_property_bool(internal_properties_partition_dummy, partition_dummy)
  port
}

///|
fn[T] partition_post_processor_test_is_none(value : T?) -> Bool {
  match value {
    None => true
    Some(_) => false
  }
}

///|
test "partition postprocessor reports expected task name" {
  let processor = new_partition_postprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Partition postprocessing")
}

///|
test "partition postprocessor removes only partition dummy ports" {
  let graph = new_l_graph()
  let layer0 = new_layer(graph)
  graph.get_layers().push(layer0)

  let node1 = partition_post_processor_test_new_node(graph, layer0)
  let node2 = partition_post_processor_test_new_node(graph, layer0)

  let node1_keep = partition_post_processor_test_new_port(node1, "EAST", false)
  let node1_drop = partition_post_processor_test_new_port(node1, "WEST", true)
  let node2_keep = partition_post_processor_test_new_port(node2, "EAST", false)
  let node2_drop = partition_post_processor_test_new_port(node2, "WEST", true)

  let processor = new_partition_postprocessor_layout_processor()
  processor.process(graph, None)

  assert_eq(node1.get_ports().length(), 1)
  assert_eq(node2.get_ports().length(), 1)

  assert_eq(node1.get_ports()[0].get_handle(), node1_keep.get_handle())
  assert_eq(node2.get_ports()[0].get_handle(), node2_keep.get_handle())
  assert_false(
    node1.get_ports()[0].get_property_bool(internal_properties_partition_dummy),
  )
  assert_false(
    node2.get_ports()[0].get_property_bool(internal_properties_partition_dummy),
  )

  assert_true(partition_post_processor_test_is_none(node1_drop.get_node()))
  assert_true(partition_post_processor_test_is_none(node2_drop.get_node()))
}
