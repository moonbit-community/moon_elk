///|
pub struct IRadialEdgeRouter {
  route_edges_fn : (ElkNode) -> Unit
}

///|
pub fn new_i_radial_edge_router(
  route_edges : (ElkNode) -> Unit,
) -> IRadialEdgeRouter {
  { route_edges_fn: route_edges }
}

///|
pub fn IRadialEdgeRouter::route_edges(
  self : IRadialEdgeRouter,
  root : ElkNode,
) -> Unit {
  (self.route_edges_fn)(root)
}
