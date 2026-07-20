///|
using @runtime {
  type LEdge,
  type LGraph,
  type LNode,
  type LPort,
  type NodeType,
  internal_properties_graph_properties,
  internal_properties_origin_l_port,
  internal_properties_port_dummy,
  new_l_edge,
  new_l_graph,
  new_l_label_text,
  new_l_node,
  new_l_port,
  node_type_values,
}

///|
using @options {
  type GraphProperties,
  type PortType,
  graph_properties_to_string,
  graph_properties_values,
  port_type_values,
}

///|
fn new_elk_progress_monitor(
  task_name? : String = "",
) -> @core.IElkProgressMonitor {
  @core.new_elk_progress_monitor(task_name~)
}
