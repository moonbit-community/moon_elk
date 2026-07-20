///|
/// Import only the shared runtime vocabulary used by the pipeline layer.
///
/// Keeping this list explicit documents the dependency seam: pipeline owns
/// orchestration and graph transformation, while runtime owns the layered
/// graph model and the processor implementations it coordinates.
using @runtime {
  type LGraph,
  type LNode,
  type LPort,
  get_minimal_model_order,
  internal_properties_ext_port_connections,
  internal_properties_ext_port_side,
  internal_properties_graph_properties,
  layered_components_direction,
  new_l_graph,
}
