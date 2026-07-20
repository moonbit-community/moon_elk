///|
test "layered option package keeps established identifiers" {
  inspect(layered_algorithm_id, content="org.eclipse.elk.layered")
  debug_inspect(
    [
      layered_options_layering_strategy.get_id(),
      layered_options_crossing_minimization_strategy.get_id(),
      layered_options_node_placement_strategy.get_id(),
      layered_options_hierarchy_handling.get_id(),
    ],
    content=(
      #|[
      #|  "org.eclipse.elk.layered.layering.strategy",
      #|  "org.eclipse.elk.layered.crossingMinimization.strategy",
      #|  "org.eclipse.elk.layered.nodePlacement.strategy",
      #|  "org.eclipse.elk.hierarchyHandling",
      #|]
    ),
  )
}
