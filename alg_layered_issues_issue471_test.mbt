///|
fn issue471_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue471_test_layout(graph : ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, new_null_elk_progress_monitor())
}

///|
test "Issue471 vertical inline edge labels are centered" {
  reset_graph_model_for_test()
  issue471_test_setup_plain_java_layout()

  let graph = create_graph()
  node_set_string_property(graph, direction, "DOWN")

  let n1 = create_node(Some(graph))
  let n2 = create_node(Some(graph))
  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(n1))
  edge_add_target(edge, make_node_shape(n2))
  update_containment(Some(edge))

  let l1 = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(l1, "L1")
  label_set_dimensions(l1, 20.0, 10.0)
  let l2 = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(l2, "L2")
  label_set_dimensions(l2, 20.0, 10.0)

  issue471_test_layout(graph)

  let labels = edge_labels(edge)
  if !labels.is_empty() {
    let mut min_x = label_x(labels[0])
    let mut max_width = label_width(labels[0])
    for label in labels {
      if label_x(label) < min_x {
        min_x = label_x(label)
      }
      if label_width(label) > max_width {
        max_width = label_width(label)
      }
    }
    for label in labels {
      let expected = min_x + (max_width - label_width(label)) / 2.0
      assert_true((label_x(label) - expected).abs() <= 0.5)
    }
  }
}
