///|
fn self_loop_post_processor_is_normal(l_node : LNode) -> Bool {
  match l_node.get_type() {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn self_loop_post_processor_restore_edge(
  l_node : LNode,
  sl_edge : SelfLoopEdge,
) -> Unit {
  let l_edge = sl_edge.get_l_edge()
  l_edge.set_source(Some(sl_edge.get_sl_source().get_l_port()))
  l_edge.set_target(Some(sl_edge.get_sl_target().get_l_port()))
  ignore(l_edge.get_bend_points().offset(l_node.get_position()))
}

///|
fn self_loop_post_processor_process_node(l_node : LNode) -> Unit {
  let sl_holder = match
    l_node.get_property_self_loop_holder(internal_properties_self_loop_holder) {
    Some(holder) => holder
    None => abort("node missing SELF_LOOP_HOLDER property")
  }

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    for sl_edge in sl_loop.get_sl_edges() {
      self_loop_post_processor_restore_edge(l_node, sl_edge)
    }
  }

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match sl_loop.get_sl_labels() {
      Some(sl_labels) => sl_labels.apply_placement(l_node.get_position())
      None => ()
    }
  }
}

///|
fn self_loop_post_processor_process(
  graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Self-Loop post-processing", 1.0))

  for layer in graph.get_layers() {
    for l_node in layer.get_nodes() {
      if !self_loop_post_processor_is_normal(l_node) {
        continue
      }
      if !l_node.has_property_self_loop_holder(
          internal_properties_self_loop_holder,
        ) {
        continue
      }
      self_loop_post_processor_process_node(l_node)
    }
  }

  monitor.done()
}

///|
pub fn new_self_loop_post_processor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(self_loop_post_processor_process)
}
