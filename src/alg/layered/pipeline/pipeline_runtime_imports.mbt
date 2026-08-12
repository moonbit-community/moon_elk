///|
/// Import only the shared runtime vocabulary used by the pipeline layer.
///
/// Keeping this list explicit documents the dependency seam: pipeline owns
/// orchestration and graph transformation, while runtime owns the layered
/// graph model and the processor implementations it coordinates.
using @runtime {
  type IntermediateProcessorStrategy,
  type LGraph,
  type LNode,
  type LayeredLayoutPlan,
  type LayeredPhaseRegistry,
  dispose_layered_graph,
  internal_properties_ext_port_side,
  internal_properties_graph_properties,
  layered_phase_descriptor,
  new_layered_layout_plan,
}
