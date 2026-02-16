///|
pub fn debug_util_log_debug_graph(
  monitor : IElkProgressMonitor,
  lgraph : LGraph,
  slot_index : Int,
  name : String,
) -> Unit {
  let tag = slot_index.to_string() + "-" + name
  ignore(dot_debug_util_create_debug_graph(lgraph))
  ignore(json_debug_util_create_debug_graph(lgraph))
  monitor.log_graph(tag + " [dot]")
  monitor.log_graph(tag + " [json]")
}

///|
pub fn debug_util_log_debug_graph_linear_segments(
  monitor : IElkProgressMonitor,
  layered_graph : LGraph,
  segment_list : Array[LinearSegment],
  outgoing_list : Array[Array[LinearSegment]],
) -> Unit {
  let tag = "segment graph"
  ignore(
    dot_debug_util_create_debug_graph_linear_segments(
      layered_graph, segment_list, outgoing_list,
    ),
  )
  ignore(
    json_debug_util_create_debug_graph_linear_segments(
      layered_graph, segment_list, outgoing_list,
    ),
  )
  monitor.log_graph(tag + " [dot]")
  monitor.log_graph(tag + " [json]")
}

///|
pub fn debug_util_log_debug_graph_hypernodes(
  monitor : IElkProgressMonitor,
  layered_graph : LGraph,
  layer_index : Int,
  hypernodes : Array[HyperEdgeSegment],
  debug_prefix : String,
  label : String,
) -> Unit {
  ignore(layer_index)
  let tag = debug_prefix + " - " + label
  ignore(
    dot_debug_util_create_debug_graph_hypernodes(layered_graph, hypernodes),
  )
  ignore(
    json_debug_util_create_debug_graph_hypernodes(layered_graph, hypernodes),
  )
  monitor.log_graph(tag + " [dot]")
  monitor.log_graph(tag + " [json]")
}
