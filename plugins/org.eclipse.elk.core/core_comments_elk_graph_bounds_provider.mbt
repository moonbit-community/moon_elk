///|
fn elk_graph_bounds_provider_bounds(node : ElkNode) -> ElkRectangle {
  new_elk_rectangle_xywh(
    node_x(node),
    node_y(node),
    node_width(node),
    node_height(node),
  )
}

///|
pub type ElkGraphBoundsProvider = IBoundsProvider[ElkNode, ElkNode]

///|
pub fn new_elk_graph_bounds_provider() -> ElkGraphBoundsProvider {
  new_bounds_provider_with_default_lifecycle(
    node => Some(elk_graph_bounds_provider_bounds(node)),
    node => Some(elk_graph_bounds_provider_bounds(node)),
  )
}
