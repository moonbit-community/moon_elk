///|
fn end_label_sorter_node_type_equals(left : NodeType, right : NodeType) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn end_label_sorter_label_precedes(left : LLabel, right : LLabel) -> Bool {
  left.get_text() <= right.get_text()
}

///|
fn end_label_sorter_sort_label_array(labels : Array[LLabel]) -> Unit {
  let mut i = 1
  while i < labels.length() {
    let key = labels[i]
    let mut j = i - 1
    while j >= 0 && !end_label_sorter_label_precedes(labels[j], key) {
      labels[j + 1] = labels[j]
      j -= 1
    }
    labels[j + 1] = key
    i += 1
  }
}

///|
fn end_label_sorter_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Sort end labels", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if end_label_sorter_node_type_equals(node.get_type(), NodeType::LabelNode) {
        if node.has_property_l_label_array(
            internal_properties_represented_labels,
          ) {
          let represented_labels = node.get_property_l_label_array(
            internal_properties_represented_labels,
          )
          end_label_sorter_sort_label_array(represented_labels)
          node.set_property_l_label_array(
            internal_properties_represented_labels, represented_labels,
          )
        }
      }
    }
  }

  monitor.done()
}

///|
pub fn new_end_label_sorter_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(end_label_sorter_process)
}
