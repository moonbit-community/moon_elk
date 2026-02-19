///|
pub struct ElkGraphFactory {
  create_elk_label_fn : () -> ElkLabel
  create_elk_node_fn : () -> ElkNode
  create_elk_port_fn : () -> ElkPort
  create_elk_edge_fn : () -> ElkEdge
  create_elk_bend_point_fn : () -> ElkBendPoint
  create_elk_edge_section_fn : (ElkEdge) -> ElkEdgeSection
  get_elk_graph_package_fn : () -> ElkGraphPackage
}

///|
pub let elk_graph_factory_instance : ElkGraphFactory = new_elk_graph_factory_impl()

///|
pub fn ElkGraphFactory::create_elk_label(self : ElkGraphFactory) -> ElkLabel {
  (self.create_elk_label_fn)()
}

///|
pub fn ElkGraphFactory::create_elk_node(self : ElkGraphFactory) -> ElkNode {
  (self.create_elk_node_fn)()
}

///|
pub fn ElkGraphFactory::create_elk_port(self : ElkGraphFactory) -> ElkPort {
  (self.create_elk_port_fn)()
}

///|
pub fn ElkGraphFactory::create_elk_edge(self : ElkGraphFactory) -> ElkEdge {
  (self.create_elk_edge_fn)()
}

///|
pub fn ElkGraphFactory::create_elk_bend_point(
  self : ElkGraphFactory,
) -> ElkBendPoint {
  (self.create_elk_bend_point_fn)()
}

///|
pub fn ElkGraphFactory::create_elk_edge_section(
  self : ElkGraphFactory,
  edge : ElkEdge,
) -> ElkEdgeSection {
  (self.create_elk_edge_section_fn)(edge)
}

///|
pub fn ElkGraphFactory::get_elk_graph_package(
  self : ElkGraphFactory,
) -> ElkGraphPackage {
  (self.get_elk_graph_package_fn)()
}
