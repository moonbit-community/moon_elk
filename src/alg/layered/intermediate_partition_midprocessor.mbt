///|
fn partition_midprocessor_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn partition_midprocessor_sort_partition_ids(ids : Array[Int]) -> Unit {
  let mut i = 1
  while i < ids.length() {
    let current = ids[i]
    let mut j = i
    while j > 0 && ids[j - 1] > current {
      ids[j] = ids[j - 1]
      j -= 1
    }
    ids[j] = current
    i += 1
  }
}

///|
fn partition_midprocessor_connect_nodes(
  first_partition : Array[LNode],
  second_partition : Array[LNode],
) -> Unit {
  for node in first_partition {
    let source_port = new_l_port()
    source_port.set_node(Some(node))
    source_port.set_side(partition_midprocessor_port_side("EAST"))
    source_port.set_property_bool(internal_properties_partition_dummy, true)

    for other_node in second_partition {
      let target_port = new_l_port()
      target_port.set_node(Some(other_node))
      target_port.set_side(partition_midprocessor_port_side("WEST"))
      target_port.set_property_bool(internal_properties_partition_dummy, true)

      let edge = new_l_edge()
      edge.set_property_bool(internal_properties_partition_dummy, true)
      edge.set_source(Some(source_port))
      edge.set_target(Some(target_port))
    }
  }
}

///|
fn partition_midprocessor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Partition midprocessing", 1.0))

  let partition_to_nodes : Map[Int, Array[LNode]] = {}
  for node in graph.get_layerless_nodes() {
    if !node.has_property_int(layered_options_partitioning_partition) {
      continue
    }

    let partition = node.get_property_int(
      layered_options_partitioning_partition,
    )
    match partition_to_nodes.get(partition) {
      Some(nodes) => nodes.push(node)
      None => partition_to_nodes[partition] = [node]
    }
  }

  if partition_to_nodes.is_empty() {
    return
  }

  let sorted_partition_ids = []
  for entry in partition_to_nodes.to_array() {
    sorted_partition_ids.push(entry.0)
  }
  partition_midprocessor_sort_partition_ids(sorted_partition_ids)

  let mut index = 0
  while index + 1 < sorted_partition_ids.length() {
    let first_id = sorted_partition_ids[index]
    let second_id = sorted_partition_ids[index + 1]
    let first_partition = match partition_to_nodes.get(first_id) {
      Some(nodes) => nodes
      None => abort("first partition missing")
    }
    let second_partition = match partition_to_nodes.get(second_id) {
      Some(nodes) => nodes
      None => abort("second partition missing")
    }
    partition_midprocessor_connect_nodes(first_partition, second_partition)
    index += 1
  }

  monitor.done()
}

///|
pub fn new_partition_midprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(partition_midprocessor_process)
}
