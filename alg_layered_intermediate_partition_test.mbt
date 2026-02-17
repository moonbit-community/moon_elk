///|
fn partition_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn partition_test_new_node(graph : LGraph, partition : Int?) -> LNode {
  let node = new_l_node(graph=Some(graph))
  match partition {
    Some(value) =>
      node.set_property_int(layered_options_partitioning_partition, value)
    None => ()
  }
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn partition_test_new_port(node : LNode, side : String) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_side(partition_test_port_side(side))
  port
}

///|
fn partition_test_new_edge(source : LPort, target : LPort) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
fn partition_test_require_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn partition_test_require_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn partition_test_require_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn partition_test_collect_unique_edges(nodes : Array[LNode]) -> Array[LEdge] {
  let edges = []
  let handles : Map[Int, Bool] = {}
  for node in nodes {
    for port in node.get_ports() {
      for edge in port.get_outgoing_edges() {
        let handle = edge.get_handle()
        if !handles.contains(handle) {
          handles[handle] = true
          edges.push(edge)
        }
      }
      for edge in port.get_incoming_edges() {
        let handle = edge.get_handle()
        if !handles.contains(handle) {
          handles[handle] = true
          edges.push(edge)
        }
      }
    }
  }
  edges
}

///|
test "partition processors report expected task names" {
  let preprocessor = new_partition_preprocessor_layout_processor()
  let midprocessor = new_partition_midprocessor_layout_processor()

  let pre_monitor = new_elk_progress_monitor()
  preprocessor.process(new_l_graph(), Some(pre_monitor))
  inspect(pre_monitor.get_task_name(), content="Partition preprocessing")

  let mid_monitor = new_elk_progress_monitor()
  midprocessor.process(new_l_graph(), Some(mid_monitor))
  inspect(mid_monitor.get_task_name(), content="Partition midprocessing")
}

///|
test "partition preprocessor reverses higher-to-lower direct partition edge and increases priority" {
  let graph = new_l_graph()
  let preprocessor = new_partition_preprocessor_layout_processor()

  let source = partition_test_new_node(graph, Some(2))
  let target = partition_test_new_node(graph, Some(1))
  let source_out = partition_test_new_port(source, "EAST")
  let target_in = partition_test_new_port(target, "WEST")

  let edge = partition_test_new_edge(source_out, target_in)
  edge.set_property_int(layered_options_priority_direction, 7)

  preprocessor.process(graph, None)

  assert_eq(
    partition_test_require_source(edge).get_handle(),
    target_in.get_handle(),
  )
  assert_eq(
    partition_test_require_target(edge).get_handle(),
    source_out.get_handle(),
  )
  assert_true(edge.get_property_bool(internal_properties_reversed))
  assert_eq(edge.get_property_int(layered_options_priority_direction), 1007)
}

///|
test "partition preprocessor reverses path to unpartitioned node when lower partition is reachable" {
  let graph = new_l_graph()
  let preprocessor = new_partition_preprocessor_layout_processor()

  let high = partition_test_new_node(graph, Some(2))
  let bridge = partition_test_new_node(graph, None)
  let low = partition_test_new_node(graph, Some(1))

  let high_out = partition_test_new_port(high, "EAST")
  let bridge_in = partition_test_new_port(bridge, "WEST")
  let bridge_out = partition_test_new_port(bridge, "EAST")
  let low_in = partition_test_new_port(low, "WEST")

  let edge0 = partition_test_new_edge(high_out, bridge_in)
  let edge1 = partition_test_new_edge(bridge_out, low_in)

  preprocessor.process(graph, None)

  assert_eq(
    partition_test_require_source(edge0).get_handle(),
    bridge_in.get_handle(),
  )
  assert_eq(
    partition_test_require_target(edge0).get_handle(),
    high_out.get_handle(),
  )
  assert_true(edge0.get_property_bool(internal_properties_reversed))

  assert_eq(
    partition_test_require_source(edge1).get_handle(),
    bridge_out.get_handle(),
  )
  assert_eq(
    partition_test_require_target(edge1).get_handle(),
    low_in.get_handle(),
  )
  assert_false(edge1.get_property_bool(internal_properties_reversed))
}

///|
test "partition midprocessor inserts partition dummy edges between consecutive partitions" {
  let graph = new_l_graph()
  let midprocessor = new_partition_midprocessor_layout_processor()

  let p0a = partition_test_new_node(graph, Some(0))
  let p0b = partition_test_new_node(graph, Some(0))
  let p2 = partition_test_new_node(graph, Some(2))
  let p5 = partition_test_new_node(graph, Some(5))

  midprocessor.process(graph, None)

  let nodes = [p0a, p0b, p2, p5]
  let edges = partition_test_collect_unique_edges(nodes)

  let mut partition_dummy_port_count = 0
  for node in nodes {
    for port in node.get_ports() {
      if port.get_property_bool(internal_properties_partition_dummy) {
        partition_dummy_port_count += 1
      }
    }
  }
  assert_eq(partition_dummy_port_count, 6)

  assert_eq(edges.length(), 3)
  for edge in edges {
    assert_true(edge.get_property_bool(internal_properties_partition_dummy))
    let source_port = partition_test_require_source(edge)
    let target_port = partition_test_require_target(edge)
    assert_true(
      source_port.get_property_bool(internal_properties_partition_dummy),
    )
    assert_true(
      target_port.get_property_bool(internal_properties_partition_dummy),
    )
    assert_eq(port_side_to_string(source_port.get_side()), "EAST")
    assert_eq(port_side_to_string(target_port.get_side()), "WEST")

    let source_node = partition_test_require_node(source_port)
    let target_node = partition_test_require_node(target_port)
    let source_partition = source_node.get_property_int(
      layered_options_partitioning_partition,
    )
    let target_partition = target_node.get_property_int(
      layered_options_partitioning_partition,
    )
    assert_true(
      (source_partition == 0 && target_partition == 2) ||
      (source_partition == 2 && target_partition == 5),
    )
  }
}
