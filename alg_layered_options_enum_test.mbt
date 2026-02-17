///|
test "edge label side transpose is bidirectional" {
  inspect(
    edge_label_side_selection_transpose_values(),
    content="[\"ALWAYS_DOWN\", \"ALWAYS_UP\", \"DIRECTION_DOWN\", \"DIRECTION_UP\", \"SMART_DOWN\", \"SMART_UP\"]",
  )
}

///|
test "long edge ordering return values match upstream" {
  inspect(
    long_edge_ordering_strategy_return_values(),
    content="[2147483647, -2147483648, 0]",
  )
}

///|
test "center edge label strategy size-information flag matches upstream" {
  inspect(
    center_edge_label_placement_strategy_uses_label_size_information_values(),
    content="[false, false, false, true, true, true]",
  )
}

///|
test "additional layered strategy enums keep upstream constant names" {
  inspect(
    crossing_minimization_strategy_values(),
    content="[\"LAYER_SWEEP\", \"MEDIAN_LAYER_SWEEP\", \"INTERACTIVE\", \"NONE\"]",
  )
  inspect(
    cycle_breaking_strategy_values(),
    content="[\"GREEDY\", \"DEPTH_FIRST\", \"INTERACTIVE\", \"MODEL_ORDER\", \"GREEDY_MODEL_ORDER\", \"SCC_CONNECTIVITY\", \"SCC_NODE_TYPE\", \"DFS_NODE_ORDER\", \"BFS_NODE_ORDER\"]",
  )
  inspect(
    layering_strategy_values(),
    content="[\"NETWORK_SIMPLEX\", \"LONGEST_PATH\", \"LONGEST_PATH_SOURCE\", \"COFFMAN_GRAHAM\", \"INTERACTIVE\", \"STRETCH_WIDTH\", \"MIN_WIDTH\", \"BF_MODEL_ORDER\", \"DF_MODEL_ORDER\"]",
  )
  inspect(
    node_placement_strategy_values(),
    content="[\"SIMPLE\", \"INTERACTIVE\", \"LINEAR_SEGMENTS\", \"BRANDES_KOEPF\", \"NETWORK_SIMPLEX\"]",
  )
  inspect(
    interactive_reference_point_values(),
    content="[\"CENTER\", \"TOP_LEFT\"]",
  )
}

///|
test "node flexibility behavior matches upstream branch logic" {
  inspect(
    node_flexibility_flags(),
    content="[false, false, false, true, false, false, true, true, false, true, true, true]",
  )
  inspect(
    node_flexibility_is_at_least_values(),
    content="[false, false, false, true, false, true, true, true, false, true, true, true, true, true, true, true]",
  )
}
