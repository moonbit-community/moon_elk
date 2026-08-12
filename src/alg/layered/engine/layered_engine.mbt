///|
/// Builds an isolated registry for one layered runtime.
///
/// This package is the composition root for concrete phase packages. Explicit
/// registration keeps package initialization side-effect free and allows
/// multiple runtimes to coexist without sharing mutable factory maps.
pub fn new_layered_phase_registry() -> @runtime.LayeredPhaseRegistry {
  let registry = @runtime.new_layered_phase_registry()
  @cycle.register_cycle_breaking_phases(registry)
  @layering.register_layering_phases(registry)
  @placement.register_node_placement_phases(registry)
  @crossing.register_crossing_minimization_phases(registry)
  @routing.register_edge_routing_phases(registry)
  @intermediate.register_processors(registry)
  @node_spacing.register_node_spacing_processors(registry)
  @crossing.register_crossing_processors(registry)
  @routing.register_routing_processors(registry)
  @comments.register_comment_processors(registry)
  @partition.register_partition_processors(registry)
  registry
}
