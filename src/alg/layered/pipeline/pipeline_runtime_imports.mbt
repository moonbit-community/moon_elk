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
  type LayeredPhases,
  dispose_layered_graph,
  edge_router_factory_factory_for,
  internal_properties_ext_port_side,
  internal_properties_graph_properties,
  layered_cycle_breaking_phase_factory,
  layered_intermediate_processor_factory,
  layered_layering_phase_factory,
  layered_node_placement_phase_factory,
  layered_phase_descriptor,
  new_barycenter_layer_sweep_crossing_minimizer_layout_phase,
  new_interactive_crossing_minimizer_layout_phase,
  new_median_layer_sweep_crossing_minimizer_layout_phase,
  new_layered_layout_plan,
  new_no_crossing_minimizer_layout_phase,
}
