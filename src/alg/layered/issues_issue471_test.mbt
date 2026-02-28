///|
fn issue471_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue471_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
test "Issue471 vertical inline edge labels are centered" {
  reset_graph_model_for_test()
  issue471_test_setup_plain_java_layout()

  let graph = create_graph()
  @graph.node_set_string_property(graph, @core.direction, "DOWN")
  @graph.node_set_layout_option_string_by_id(
    graph, "org.eclipse.elk.edgeLabels.inline", "true",
  )

  let n1 = @graph.create_node(Some(graph))
  let n2 = @graph.create_node(Some(graph))
  let n3 = @graph.create_node(Some(graph))

  let edge1 = create_edge(None)
  edge_add_source(edge1, make_node_shape(n1))
  edge_add_target(edge1, make_node_shape(n2))
  layered_test_update_containment(Some(edge1))

  let l1 = @graph.create_label(Some(make_edge_label_parent(edge1)))
  @graph.label_set_text(l1, "L1")
  @graph.label_set_dimensions(l1, 20.0, 10.0)

  let edge2 = create_edge(None)
  edge_add_source(edge2, make_node_shape(n2))
  edge_add_target(edge2, make_node_shape(n3))
  layered_test_update_containment(Some(edge2))

  let l2 = @graph.create_label(Some(make_edge_label_parent(edge2)))
  @graph.label_set_text(l2, "L2")
  @graph.label_set_dimensions(l2, 30.0, 10.0)

  issue471_test_layout(graph)

  for edge in @graph.node_contained_edges(graph) {
    let labels = @graph.edge_labels(edge)
    if labels.is_empty() {
      continue
    }

    let mut min_x = @graph.label_x(labels[0])
    let mut max_width = @graph.label_width(labels[0])
    for label in labels {
      if @graph.label_x(label) < min_x {
        min_x = @graph.label_x(label)
      }
      if @graph.label_width(label) > max_width {
        max_width = @graph.label_width(label)
      }
    }
    for label in labels {
      let expected = min_x + (max_width - @graph.label_width(label)) / 2.0
      assert_true((@graph.label_x(label) - expected).abs() <= 0.5)
    }
  }
}
