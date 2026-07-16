///|
pub type ElkGraphFactoryImpl = ElkGraphFactory

///|
pub fn new_elk_graph_factory_impl_in_arena(
  arena : GraphArena,
) -> ElkGraphFactoryImpl {
  checked_graph_arena(arena)
  {
    create_elk_label_fn: () => arena.create_label(),
    create_elk_node_fn: () => arena.create_node(),
    create_elk_port_fn: () => arena.create_port(),
    create_elk_edge_fn: () => arena.create_edge(),
    create_elk_bend_point_fn: () => new_elk_bend_point(),
    create_elk_edge_section_fn: edge => create_edge_section(edge),
    get_elk_graph_package_fn: () => elk_graph_package_instance,
  }
}

///|
pub fn new_elk_graph_factory_impl() -> ElkGraphFactoryImpl {
  // Compatibility factory objects retain hidden ownership arenas. New code
  // should keep an explicit arena and dispose it after using the factory.
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
