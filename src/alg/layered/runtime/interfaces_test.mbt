///|
test "LayeredPhases keep upstream constant names and order" {
  debug_inspect(
    layered_phase_values(),
    content=(
      #|[
      #|  "P1_CYCLE_BREAKING",
      #|  "P2_LAYERING",
      #|  "P3_NODE_ORDERING",
      #|  "P4_NODE_PLACEMENT",
      #|  "P5_EDGE_ROUTING",
      #|]
    ),
  )
}

///|
test "Layered hierarchy-aware marker is constructible" {
  inspect(new_layered_hierarchy_aware_layout_processor(), content="()")
}
