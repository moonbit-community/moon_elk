///|
fn end_label_postprocessor_node_type_supports_end_labels(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::Normal => true
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn end_label_postprocessor_process_node(node : LNode) -> Unit {
  let end_label_cells = node.get_property_end_label_cell_array(
    internal_properties_end_labels,
  )
  let node_pos = node.get_position()

  for label_cell in end_label_cells {
    label_cell.get_cell_rectangle().move(node_pos)
    label_cell.apply_label_layout()
  }

  node.clear_property_end_label_cell_array(internal_properties_end_labels)
}

///|
fn end_label_postprocessor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("End label post-processing", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if end_label_postprocessor_node_type_supports_end_labels(node.get_type()) &&
        node.has_property_end_label_cell_array(internal_properties_end_labels) {
        end_label_postprocessor_process_node(node)
      }
    }
  }

  monitor.done()
}

///|
pub fn new_end_label_postprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(end_label_postprocessor_process)
}
