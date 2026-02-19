///|
fn node_micro_layout_omit_micro_layout(graph : ElkNode) -> Bool {
  node_has_bool_property(graph, omit_node_micro_layout) &&
  node_get_bool_property(graph, omit_node_micro_layout)
}

///|
fn node_micro_layout_get_label(node : ElkNode, text : String) -> ElkLabel {
  for label in node_labels(node) {
    if label_text(label) == text {
      return label
    }
  }
  abort("missing label: \{text}")
}

///|
fn node_micro_layout_verify_node_labels_have_not_been_positioned(
  node : ElkNode,
) -> Unit raise {
  for label in node_labels(node) {
    if label_x(label) != 0.0 {
      fail("Expected unpositioned node labels to keep x = 0.0")
    }
  }
}

///|
fn node_micro_layout_verify_node_labels_have_been_positioned(
  node : ElkNode,
) -> Unit raise {
  let before_center_threshold = 40.0
  let after_center_threshold = 60.0

  let a = node_micro_layout_get_label(node, "A")
  assert_true(label_y(a) > 0.0)

  let b = node_micro_layout_get_label(node, "B")
  assert_true(label_x(b) > after_center_threshold)
  assert_true(label_x(b) < node_width(node))
  assert_true(label_y(b) > after_center_threshold)
  assert_true(label_y(b) < node_height(node))

  let c = node_micro_layout_get_label(node, "C")
  assert_true(label_x(c) > before_center_threshold)
  assert_true(label_x(c) < after_center_threshold)
  assert_true(label_y(c) > node_height(node))

  let d = node_micro_layout_get_label(node, "D")
  assert_true(label_x(d) < 0.0)
  assert_true(label_y(d) > before_center_threshold)
  assert_true(label_y(d) < after_center_threshold)
}

///|
fn node_micro_layout_fixture(positioned : Bool) -> ElkNode {
  reset_graph_model_for_test()
  let graph = create_graph()
  if !positioned {
    node_set_bool_property(graph, omit_node_micro_layout, true)
  }

  let node = create_node(Some(graph))
  if positioned {
    node_set_dimensions(node, 101.0, 102.0)
  } else {
    node_set_dimensions(node, 100.0, 100.0)
  }

  let a = create_label(Some(make_node_label_parent(node)))
  label_set_text(a, "A")
  if positioned {
    label_set_location(a, 50.0, 5.0)
  } else {
    label_set_location(a, 0.0, 0.0)
  }
  label_set_dimensions(a, 10.0, 10.0)

  let b = create_label(Some(make_node_label_parent(node)))
  label_set_text(b, "B")
  if positioned {
    label_set_location(b, 80.0, 80.0)
  } else {
    label_set_location(b, 0.0, 0.0)
  }
  label_set_dimensions(b, 10.0, 10.0)

  let c = create_label(Some(make_node_label_parent(node)))
  label_set_text(c, "C")
  if positioned {
    label_set_location(c, 50.0, 110.0)
  } else {
    label_set_location(c, 0.0, 0.0)
  }
  label_set_dimensions(c, 10.0, 10.0)

  let d = create_label(Some(make_node_label_parent(node)))
  label_set_text(d, "D")
  if positioned {
    label_set_location(d, -10.0, 50.0)
  } else {
    label_set_location(d, 0.0, 0.0)
  }
  label_set_dimensions(d, 10.0, 10.0)

  graph
}

///|
test "NodeMicroLayout minimum size" {
  let graph_applied = node_micro_layout_fixture(true)
  let node_applied = node_children(graph_applied)[0]
  if !node_micro_layout_omit_micro_layout(graph_applied) {
    assert_eq(node_width(node_applied), 101.0)
    assert_eq(node_height(node_applied), 102.0)
  } else {
    assert_eq(node_width(node_applied), 100.0)
    assert_eq(node_height(node_applied), 100.0)
  }

  let graph_omitted = node_micro_layout_fixture(false)
  let node_omitted = node_children(graph_omitted)[0]
  if !node_micro_layout_omit_micro_layout(graph_omitted) {
    assert_eq(node_width(node_omitted), 101.0)
    assert_eq(node_height(node_omitted), 102.0)
  } else {
    assert_eq(node_width(node_omitted), 100.0)
    assert_eq(node_height(node_omitted), 100.0)
  }
}

///|
test "NodeMicroLayout node label positions" {
  let graph_applied = node_micro_layout_fixture(true)
  let node_applied = node_children(graph_applied)[0]
  if !node_micro_layout_omit_micro_layout(graph_applied) {
    node_micro_layout_verify_node_labels_have_been_positioned(node_applied)
  } else {
    node_micro_layout_verify_node_labels_have_not_been_positioned(node_applied)
  }

  let graph_omitted = node_micro_layout_fixture(false)
  let node_omitted = node_children(graph_omitted)[0]
  if !node_micro_layout_omit_micro_layout(graph_omitted) {
    node_micro_layout_verify_node_labels_have_been_positioned(node_omitted)
  } else {
    node_micro_layout_verify_node_labels_have_not_been_positioned(node_omitted)
  }
}
