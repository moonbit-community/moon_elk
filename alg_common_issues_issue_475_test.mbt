///|
let issue_475_size = 20.0

///|
fn issue_475_do_test_compound_node_size(node : ElkNode) -> Unit raise {
  if node_get_bool_property(node, node_size_fixed_graph_size) {
    if node_width(node) != issue_475_size {
      fail("Expected fixed width to stay at 20.0")
    }
    if node_height(node) != issue_475_size {
      fail("Expected fixed height to stay at 20.0")
    }
  } else {
    let mut max_x = 0.0
    let mut max_y = 0.0
    for child in node_children(node) {
      let child_max_x = node_x(child) + node_width(child)
      let child_max_y = node_y(child) + node_height(child)
      if child_max_x > max_x {
        max_x = child_max_x
      }
      if child_max_y > max_y {
        max_y = child_max_y
      }
    }
    if node_width(node) < max_x {
      fail("Expected non-fixed width to enclose all children")
    }
    if node_height(node) < max_y {
      fail("Expected non-fixed height to enclose all children")
    }
  }
}

///|
fn issue_475_new_fixed_node(parent : ElkNode) -> ElkNode {
  let node = create_node(Some(parent))
  node_set_bool_property(node, node_size_fixed_graph_size, true)
  node_set_dimensions(node, issue_475_size, issue_475_size)
  node
}

///|
fn issue_475_new_non_fixed_node(parent : ElkNode) -> ElkNode {
  let node = create_node(Some(parent))
  node_set_bool_property(node, node_size_fixed_graph_size, false)
  node_set_dimensions(node, 100.0, 100.0)

  let child_a = create_node(Some(node))
  node_set_location(child_a, 10.0, 15.0)
  node_set_dimensions(child_a, 20.0, 10.0)

  let child_b = create_node(Some(node))
  node_set_location(child_b, 45.0, 55.0)
  node_set_dimensions(child_b, 30.0, 25.0)

  node
}

///|
test "Issue475 fixed-size node keeps configured dimensions" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let fixed_node = issue_475_new_fixed_node(graph)

  issue_475_do_test_compound_node_size(fixed_node)
}

///|
test "Issue475 non-fixed node encloses children bounds" {
  reset_graph_model_for_test()
  let graph = create_graph()
  let free_node = issue_475_new_non_fixed_node(graph)

  issue_475_do_test_compound_node_size(free_node)
}

///|
test "Issue475 top-level loop over graph children" {
  reset_graph_model_for_test()
  let graph = create_graph()
  ignore(issue_475_new_fixed_node(graph))
  ignore(issue_475_new_non_fixed_node(graph))

  for child in node_children(graph) {
    issue_475_do_test_compound_node_size(child)
  }
}
