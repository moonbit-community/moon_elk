///|
fn elk_graph_bounds_provider_bounds(node : @graph.ElkNode) -> ElkRectangle {
  new_elk_rectangle_xywh(
    @graph.node_x(node),
    @graph.node_y(node),
    @graph.node_width(node),
    @graph.node_height(node),
  )
}

///|
pub type ElkGraphBoundsProvider = IBoundsProvider[@graph.ElkNode, @graph.ElkNode]

///|
pub fn new_elk_graph_bounds_provider() -> ElkGraphBoundsProvider {
  new_bounds_provider_with_default_lifecycle(
    node => Some(elk_graph_bounds_provider_bounds(node)),
    node => Some(elk_graph_bounds_provider_bounds(node)),
  )
}
