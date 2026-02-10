///|
fn layout_dot_exporter_test_option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
fn layout_dot_exporter_test_find_attribute_map(
  statements : Array[DotStatement],
  attribute_type : DotAttributeType,
) -> Map[String, String] {
  for statement in statements {
    match statement {
      DotStatementAttributeStatement(attribute_statement) =>
        if dot_attribute_type_value(attribute_statement.get_type()) ==
          dot_attribute_type_value(attribute_type) {
          return dot_exporter_create_attribute_map(
            attribute_statement.get_attributes(),
          )
        }
      _ => ()
    }
  }
  {}
}

///|
fn layout_dot_exporter_test_find_first_edge_attribute_map(
  statements : Array[DotStatement],
) -> Map[String, String] {
  for statement in statements {
    match statement {
      DotStatementEdgeStatement(edge_statement) =>
        return dot_exporter_create_attribute_map(
          edge_statement.get_attributes(),
        )
      DotStatementSubgraph(subgraph) => {
        let nested = layout_dot_exporter_test_find_first_edge_attribute_map(
          subgraph.get_statements(),
        )
        if !nested.is_empty() {
          return nested
        }
      }
      _ => ()
    }
  }
  {}
}

///|
fn layout_dot_exporter_test_setup_data(
  root : ElkNode,
  command : Command,
) -> DotTransformationData[ElkNode, DotGraphvizModel] {
  let data : DotTransformationData[ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)
  data.set_command_property(dot_exporter_command, command)
  data
}

///|
test "LayoutDotExporter sets DOT graph attributes and transformation flags" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_double_property(root, spacing_node_node, 72.0)
  node_set_string_property(root, direction, "RIGHT")
  node_set_string_property(
    root, graphviz_core_option_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  node_set_double_property(root, graphviz_option_layer_spacing_factor, 2.0)
  node_set_double_property(root, graphviz_option_iterations_factor, 0.5)
  node_set_bool_property(root, graphviz_option_concentrate, true)
  node_set_bool_property(root, graphviz_option_adapt_port_positions, false)
  let cluster = create_node(Some(root))
  ignore(create_node(Some(cluster)))

  let data = layout_dot_exporter_test_setup_data(root, command_parse("dot"))
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  inspect(data.get_bool_property(dot_exporter_use_edge_ids), content="true")
  inspect(data.get_bool_property(dot_exporter_hierarchy), content="true")
  inspect(
    data.get_bool_property(dot_exporter_transform_node_layout),
    content="false",
  )
  inspect(
    data.get_bool_property(dot_exporter_transform_edge_layout),
    content="false",
  )
  inspect(
    data.get_bool_property(dot_exporter_transform_node_labels),
    content="false",
  )
  inspect(
    data.get_bool_property(dot_exporter_adapt_port_positions),
    content="false",
  )
  inspect(data.get_bool_property(dot_exporter_use_splines), content="true")

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let graph_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    dot_attribute_type_graph(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_nodesep),
    ),
    content="\"1\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_ranksep),
    ),
    content="\"2\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_rankdir),
    ),
    content="LR",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_crossmin_limit),
    ),
    content="\"0.5\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_simplex_limit),
    ),
    content="\"50\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_compound),
    ),
    content="true",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_splines),
    ),
    content="spline",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_concentrate),
    ),
    content="true",
  )
}

///|
test "LayoutDotExporter sets NEATO specific graph and edge attributes" {
  reset_graph_model_for_test()
  let root = create_graph()
  node_set_double_property(root, spacing_node_node, 72.0)
  node_set_layout_option_string_by_id(
    root,
    graphviz_core_option_random_seed.get_id(),
    "0",
  )
  node_set_double_property(root, graphviz_option_epsilon, 0.2)
  node_set_string_property(root, graphviz_option_neato_model, "CIRCUIT")
  node_set_string_property(root, graphviz_option_overlap_mode, "SCALE")
  node_set_layout_option_string_by_id(
    root,
    graphviz_option_maxiter.get_id(),
    "10",
  )
  node_set_bool_property(
    root, graphviz_core_option_separate_connected_components, true,
  )
  node_set_string_property(root, graphviz_core_option_edge_routing, "POLYLINE")
  let n0 = create_node(Some(root))
  let n1 = create_node(Some(root))
  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(n0))
  edge_add_target(edge, make_node_shape(n1))

  let data = layout_dot_exporter_test_setup_data(root, command_parse("neato"))
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  inspect(data.get_bool_property(dot_exporter_use_splines), content="false")

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let graph_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    dot_attribute_type_graph(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_start),
    ),
    content="random-1",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_epsilon),
    ),
    content="\"0.2\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_neato_model),
    ),
    content="circuit",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_overlap),
    ),
    content="scale",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_sep),
    ),
    content="\"+36\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_pack),
    ),
    content="\"72\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_maxiter),
    ),
    content="\"10\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(dot_attr_splines),
    ),
    content="polyline",
  )

  let edge_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    dot_attribute_type_edge(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(dot_attr_edgedir),
    ),
    content="none",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(dot_attr_edgelen),
    ),
    content="\"1\"",
  )
}

///|
test "LayoutDotExporter appends label distance and angle for head/tail labels" {
  reset_graph_model_for_test()
  let root = create_graph()
  let source = create_node(Some(root))
  let target = create_node(Some(root))
  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  edge_set_layout_option_string_by_id(
    edge,
    graphviz_option_label_distance.get_id(),
    "2.5",
  )
  edge_set_layout_option_string_by_id(
    edge,
    graphviz_option_label_angle.get_id(),
    "-30",
  )
  let label = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(label, "head")
  label_set_layout_option_string_by_id(
    label, dot_exporter_option_edge_labels_placement, "HEAD",
  )

  let data = layout_dot_exporter_test_setup_data(root, command_parse("dot"))
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let edge_attrs = layout_dot_exporter_test_find_first_edge_attribute_map(
    graph.get_statements(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(dot_attr_labeldistance),
    ),
    content="\"2.5\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(dot_attr_labelangle),
    ),
    content="\"-30\"",
  )
}
