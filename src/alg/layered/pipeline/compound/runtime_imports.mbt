///|
/// Import only the shared runtime vocabulary used by the pipeline layer.
///
/// Keeping this list explicit documents the dependency seam: pipeline owns
/// orchestration and graph transformation, while runtime owns the layered
/// graph model and the processor implementations it coordinates.
using @runtime {
  type LEdge,
  type LGraph,
  type LNode,
  type LPort,
  type LayeredPhases,
  change_coord_system,
  create_external_port_dummy,
  get_direction,
  internal_properties_ext_port_side,
  internal_properties_graph_properties,
  internal_properties_inside_connections,
  internal_properties_origin_l_port,
  internal_properties_port_dummy,
  is_descendant_l_node,
  l_graph_util_exception_message,
  new_l_edge,
  new_l_label,
  new_l_node,
  new_l_port,
  orthogonal_routing_generator_tolerance,
  to_edge_array,
}
