///|
fn partition_postprocessor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Partition postprocessing", 1.0))

  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      let ports = node.get_ports()
      let mut index = 0
      while index < ports.length() {
        let port = ports[index]
        if port.get_property_bool(internal_properties_partition_dummy) {
          port.set_node(None)
        } else {
          index += 1
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_partition_postprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(partition_postprocessor_process)
}
