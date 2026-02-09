///|
fn contains_string(values : Array[String], target : String) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
test "DeprecatedLayoutOptionReplacer testReplacesNextToPortIfPossible" {
  reset_graph_model_for_test()
  let replacer = new_deprecated_layout_option_replacer()
  let node = create_graph()
  node_set_bool_property(node, port_labels_next_to_port_if_possible, true)
  replacer.visit(node)
  assert_false(
    node_has_bool_property(node, port_labels_next_to_port_if_possible),
  )
  assert_true(node_has_string_set_property(node, port_labels_placement))
  assert_true(
    contains_string(
      node_get_string_set_property(node, port_labels_placement),
      "NEXT_TO_PORT_IF_POSSIBLE",
    ),
  )
}

///|
test "DeprecatedLayoutOptionReplacer testMovesSpaceEfficientPortLabels" {
  reset_graph_model_for_test()
  let replacer = new_deprecated_layout_option_replacer()
  let node = create_graph()
  node_set_string_set_property(node, node_size_options, [
    "SPACE_EFFICIENT_PORT_LABELS",
  ])
  replacer.visit(node)
  assert_false(
    contains_string(
      node_get_string_set_property(node, node_size_options),
      "SPACE_EFFICIENT_PORT_LABELS",
    ),
  )
  assert_true(node_has_string_set_property(node, port_labels_placement))
  assert_true(
    contains_string(
      node_get_string_set_property(node, port_labels_placement),
      "SPACE_EFFICIENT",
    ),
  )
}
