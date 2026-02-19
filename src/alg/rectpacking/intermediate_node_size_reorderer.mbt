///|
fn rectpacking_sort_nodes_by_height_desc(nodes : Array[@graph.ElkNode]) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let value = nodes[i]
    let mut j = i
    while j > 0 && rectpacking_node_size_compare(nodes[j - 1], value) > 0 {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = value
    i += 1
  }
}

///|
fn rectpacking_node_size_reorderer_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  ignore(progress_monitor)
  let children = @graph.node_children(graph)
  rectpacking_sort_nodes_by_height_desc(children)
}

///|
pub fn new_rectpacking_node_size_reorderer_layout_processor() -> @core.ILayoutProcessor[
  RectPackingLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_processor(rectpacking_node_size_reorderer_process)
}
