///|
fn create_content_alignment_test_graph(
  content_alignment_values : Array[ContentAlignment]?,
) -> ElkNode {
  let parent = create_graph()
  let node = create_node(Some(parent))
  if content_alignment_values is Some(alignments) {
    node_set_string_set_property(
      node,
      content_alignment,
      content_alignment_values_to_strings(alignments),
    )
  }
  let inner_behavior = create_node(Some(node))
  node_set_dimensions(node, 100.0, 100.0)
  node_set_dimensions(inner_behavior, 80.0, 80.0)
  parent
}

///|
fn assert_inner_behavior_translation(
  alignments : Array[ContentAlignment]?,
  expected_x : Double,
  expected_y : Double,
) -> Unit raise {
  reset_graph_model_for_test()
  let parent = create_content_alignment_test_graph(alignments)
  let node = node_children(parent)[0]
  let inner_behavior = node_children(node)[0]
  translate(node, new_kvector_xy(120.0, 120.0), new_kvector_xy(100.0, 100.0))
  assert_double_eq(node_x(inner_behavior), expected_x, 1.0)
  assert_double_eq(node_y(inner_behavior), expected_y, 1.0)
}

///|
test "ElkUtil translateWithContentAlignmentTest" {
  assert_inner_behavior_translation(None, 0.0, 0.0)
  assert_inner_behavior_translation(
    Some(content_alignment_top_left()),
    0.0,
    0.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_top_center()),
    10.0,
    0.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_top_right()),
    20.0,
    0.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_center_left()),
    0.0,
    10.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_center_center()),
    10.0,
    10.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_center_right()),
    20.0,
    10.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_bottom_left()),
    0.0,
    20.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_bottom_center()),
    10.0,
    20.0,
  )
  assert_inner_behavior_translation(
    Some(content_alignment_bottom_right()),
    20.0,
    20.0,
  )
}
