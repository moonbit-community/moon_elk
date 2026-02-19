///|
fn issue603_test_setup_plain_java_layout() -> Unit {
  layout_meta_data_service_reset_for_test()
  plain_java_initialization_reset_for_test()
  plain_java_initialization_initialize_plain_java_layout()
}

///|
fn issue603_test_layout(graph : @graph.ElkNode) -> Unit {
  let resolver = new_layout_algorithm_resolver()
  apply_visitors(graph, [resolver.to_visitor()])
  let layout_engine = new_recursive_graph_layout_engine()
  layout_engine.layout(graph, @core.new_null_elk_progress_monitor())
}

///|
fn issue603_test_rectangles_overlap(
  left_x : Double,
  left_y : Double,
  left_w : Double,
  left_h : Double,
  right_x : Double,
  right_y : Double,
  right_w : Double,
  right_h : Double,
) -> Bool {
  left_x < right_x + right_w &&
  left_x + left_w > right_x &&
  left_y < right_y + right_h &&
  left_y + left_h > right_y
}

///|
fn issue603_test_node_label_placement_strings(
  placements : Array[NodeLabelPlacement],
) -> Array[String] {
  let values : Array[String] = []
  for placement in placements {
    values.push(@core.node_label_placement_to_string(placement))
  }
  values
}

///|
fn issue603_test_configure_node_label_placement(graph : @graph.ElkNode) -> Unit {
  for node in @graph.node_children(graph) {
    node_set_string_set_property(
      node,
      @core.node_labels_placement,
      issue603_test_node_label_placement_strings(
        node_label_placement_inside_top_center(),
      ),
    )
  }
}

///|
fn issue603_test_create_labeled_compound(
  parent : @graph.ElkNode,
  id_prefix : String,
) -> @graph.ElkNode {
  let compound = @graph.create_node(Some(parent))
  @graph.node_set_identifier(compound, id_prefix + "_compound")
  @graph.node_set_string_property(
    compound, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_dimensions(compound, 220.0, 140.0)

  let label = @graph.create_label(Some(make_node_label_parent(compound)))
  @graph.label_set_text(label, id_prefix + "_label")
  @graph.label_set_dimensions(label, 92.0, 18.0)

  let source = @graph.create_node(Some(compound))
  @graph.node_set_identifier(source, id_prefix + "_source")
  @graph.node_set_dimensions(source, 40.0, 30.0)
  let target = @graph.create_node(Some(compound))
  @graph.node_set_identifier(target, id_prefix + "_target")
  @graph.node_set_dimensions(target, 40.0, 30.0)

  let edge = create_edge(None)
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  update_containment(Some(edge))

  compound
}

///|
fn issue603_test_build_graph() -> @graph.ElkNode {
  let graph = create_graph()
  @graph.node_set_string_property(
    graph, @core.algorithm, "org.eclipse.elk.layered",
  )
  @graph.node_set_string_property(graph, @core.direction, "RIGHT")

  ignore(issue603_test_create_labeled_compound(graph, "left"))
  ignore(issue603_test_create_labeled_compound(graph, "right"))
  graph
}

///|
fn issue603_test_do_no_label_node_overlaps(node : @graph.ElkNode) -> Unit {
  let labels = node_labels(node)
  let children = @graph.node_children(node)

  for first = 0; first < labels.length(); first = first + 1 {
    let first_label = labels[first]
    for second = first + 1; second < labels.length(); second = second + 1 {
      let second_label = labels[second]
      if issue603_test_rectangles_overlap(
          @graph.label_x(first_label),
          @graph.label_y(first_label),
          @graph.label_width(first_label),
          @graph.label_height(first_label),
          @graph.label_x(second_label),
          @graph.label_y(second_label),
          @graph.label_width(second_label),
          @graph.label_height(second_label),
        ) {
        abort("Issue603 label-label @common.overlap detected")
      }
    }

    for child in children {
      if issue603_test_rectangles_overlap(
          @graph.label_x(first_label),
          @graph.label_y(first_label),
          @graph.label_width(first_label),
          @graph.label_height(first_label),
          @graph.node_x(child),
          @graph.node_y(child),
          @graph.node_width(child),
          @graph.node_height(child),
        ) {
        abort("Issue603 label-child @common.overlap detected")
      }
    }
  }

  for first = 0; first < children.length(); first = first + 1 {
    let first_child = children[first]
    for second = first + 1; second < children.length(); second = second + 1 {
      let second_child = children[second]
      if issue603_test_rectangles_overlap(
          @graph.node_x(first_child),
          @graph.node_y(first_child),
          @graph.node_width(first_child),
          @graph.node_height(first_child),
          @graph.node_x(second_child),
          @graph.node_y(second_child),
          @graph.node_width(second_child),
          @graph.node_height(second_child),
        ) {
        abort("Issue603 child-child @common.overlap detected")
      }
    }
  }
}

///|
fn issue603_test_assert_no_label_node_overlaps(graph : @graph.ElkNode) -> Unit {
  let queue : Array[@graph.ElkNode] = []
  for child in @graph.node_children(graph) {
    queue.push(child)
  }

  let mut index = 0
  while index < queue.length() {
    let node = queue[index]
    index = index + 1

    if !node_labels(node).is_empty() && !@graph.node_children(node).is_empty() {
      issue603_test_do_no_label_node_overlaps(node)
    }

    for child in @graph.node_children(node) {
      queue.push(child)
    }
  }
}

///|
fn issue603_test_layout_with_configured_placement() -> @graph.ElkNode {
  reset_graph_model_for_test()
  issue603_test_setup_plain_java_layout()

  let graph = issue603_test_build_graph()
  issue603_test_configure_node_label_placement(graph)
  issue603_test_layout(graph)
  graph
}

///|
test "Issue603 no @common.overlap between compound labels and child nodes" {
  let graph = issue603_test_layout_with_configured_placement()
  issue603_test_assert_no_label_node_overlaps(graph)
}
