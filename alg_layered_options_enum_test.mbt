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
