///|
fn end_label_postprocessor_node_type_supports_end_labels(
  node_type : @runtime.NodeType,
) -> Bool {
  match node_type {
    Normal => true
    ExternalPort => true
    _ => false
  }
}

///|
fn end_label_postprocessor_process_node(
  state : @runtime.LayeredRunState,
  node : @runtime.LNode,
) -> Unit {
  let end_label_cells = state.get_end_label_cells(node)
  let node_pos = node.get_position()

  for label_cell in end_label_cells {
    label_cell.get_cell_rectangle().move_by(node_pos)
    label_cell.apply_label_layout()
  }

  state.clear_end_label_cells(node)
}

///|
fn end_label_postprocessor_process(
  layered_graph : @runtime.LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
  state : @runtime.LayeredRunState,
) -> Unit raise {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("End label post-processing", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if end_label_postprocessor_node_type_supports_end_labels(node.get_type()) &&
        state.has_end_label_cells(node) {
        end_label_postprocessor_process_node(state, node)
      }
    }
  }

  monitor.done()
}

///|
pub fn new_end_label_postprocessor_layout_processor(
  state? : @runtime.LayeredRunState = @runtime.new_layered_run_state(),
) -> @core.TypedLayoutProcessor[@runtime.LGraph] {
  @core.new_layout_processor((graph, monitor) => {
    end_label_postprocessor_process(graph, monitor, state)
  })
}
