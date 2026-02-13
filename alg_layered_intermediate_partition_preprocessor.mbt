///|
let partition_preprocessor_priority_direction : IProperty[Int] = new_property(
  "org.eclipse.elk.layered.priority.direction", 0,
)

///|
let partition_preprocessor_partition_constraint_edge_priority : Int = 1000

///|
fn partition_preprocessor_require_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source")
  }
}

///|
fn partition_preprocessor_require_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target")
  }
}

///|
fn partition_preprocessor_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn partition_preprocessor_node_array_contains(
  nodes : Array[LNode],
  node : LNode,
) -> Bool {
  for candidate in nodes {
    if candidate.get_handle() == node.get_handle() {
      return true
    }
  }
  false
}

///|
fn partition_preprocessor_reverse_edge(edge : LEdge) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
fn partition_preprocessor_reverse(edge : LEdge, graph : LGraph) -> Unit {
  ignore(graph)
  partition_preprocessor_reverse_edge(edge)
  let mut priority = partition_preprocessor_partition_constraint_edge_priority
  if edge.has_property_int(partition_preprocessor_priority_direction) {
    priority += edge.get_property_int(partition_preprocessor_priority_direction)
  }
  edge.set_property_int(partition_preprocessor_priority_direction, priority)
}

///|
fn partition_preprocessor_must_be_reversed(
  edge : LEdge,
  partitioned_nodes : Array[LNode],
) -> Bool {
  let source_node = partition_preprocessor_require_port_node(
    partition_preprocessor_require_edge_source(edge),
  )
  let target_node = partition_preprocessor_require_port_node(
    partition_preprocessor_require_edge_target(edge),
  )

  if target_node.has_property_int(layered_options_partitioning_partition) {
    let source_partition = source_node.get_property_int(
      layered_options_partitioning_partition,
    )
    let target_partition = target_node.get_property_int(
      layered_options_partitioning_partition,
    )
    return source_partition > target_partition
  }

  let source_partition = source_node.get_property_int(
    layered_options_partitioning_partition,
  )
  let partitioned_nodes_with_lower_partition = []
  for node in partitioned_nodes {
    if node.get_property_int(layered_options_partitioning_partition) <
      source_partition {
      partitioned_nodes_with_lower_partition.push(node)
    }
  }

  let queue = [source_node]
  let visited : Map[Int, Bool] = {}
  visited[source_node.get_handle()] = true
  let mut queue_index = 0

  while queue_index < queue.length() {
    let current_node = queue[queue_index]
    queue_index += 1

    if partition_preprocessor_node_array_contains(
        partitioned_nodes_with_lower_partition, current_node,
      ) {
      return true
    }

    for outgoing_edge in current_node.get_outgoing_edges() {
      let reached_node = partition_preprocessor_require_port_node(
        partition_preprocessor_require_edge_target(outgoing_edge),
      )
      let reached_handle = reached_node.get_handle()
      if !visited.contains(reached_handle) {
        visited[reached_handle] = true
        queue.push(reached_node)
      }
    }
  }

  false
}

///|
fn partition_preprocessor_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Partition preprocessing", 1.0))

  let partitioned_nodes = []
  for node in graph.get_layerless_nodes() {
    if node.has_property_int(layered_options_partitioning_partition) {
      partitioned_nodes.push(node)
    }
  }

  let edges_to_be_reversed = []
  for node in graph.get_layerless_nodes() {
    if !node.has_property_int(layered_options_partitioning_partition) {
      continue
    }
    for edge in node.get_outgoing_edges() {
      if partition_preprocessor_must_be_reversed(edge, partitioned_nodes) {
        edges_to_be_reversed.push(edge)
      }
    }
  }

  for edge in edges_to_be_reversed {
    partition_preprocessor_reverse(edge, graph)
  }

  monitor.done()
}

///|
pub fn new_partition_preprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(partition_preprocessor_process)
}
