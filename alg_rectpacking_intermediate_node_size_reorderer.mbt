///|
fn rectpacking_sort_nodes_by_height_desc(nodes : Array[ElkNode]) -> Unit {
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
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  ignore(progress_monitor)
  let children = node_children(graph)
  rectpacking_sort_nodes_by_height_desc(children)
}

///|
pub fn new_rectpacking_node_size_reorderer_layout_processor() -> ILayoutProcessor[
  RectPackingLayoutPhases,
  ElkNode,
] {
  new_layout_processor(rectpacking_node_size_reorderer_process)
}
