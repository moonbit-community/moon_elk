///|
pub type ElkGraphFactoryImpl = ElkGraphFactory

///|
pub fn new_elk_graph_factory_impl() -> ElkGraphFactoryImpl {
  {
    create_elk_label_fn: () => create_label(None),
    create_elk_node_fn: () => create_node(None),
    create_elk_port_fn: () => create_port(None),
    create_elk_edge_fn: () => create_edge(None),
    create_elk_bend_point_fn: () => new_elk_bend_point(),
    create_elk_edge_section_fn: edge => create_edge_section(edge),
    get_elk_graph_package_fn: () => elk_graph_package_instance,
  }
}
