///|
fn layout_dot_exporter_test_option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
fn layout_dot_exporter_test_find_attribute_map(
  statements : Array[@dot.DotStatement],
  attribute_type : @dot.DotAttributeType,
) -> Map[String, String] {
  for statement in statements {
    match statement {
      @dot.DotStatementAttributeStatement(attribute_statement) =>
        if @dot.dot_attribute_type_value(attribute_statement.get_type()) ==
          @dot.dot_attribute_type_value(attribute_type) {
          return @dot.dot_exporter_create_attribute_map(
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
  statements : Array[@dot.DotStatement],
) -> Map[String, String] {
  for statement in statements {
    match statement {
      @dot.DotStatementEdgeStatement(edge_statement) =>
        return @dot.dot_exporter_create_attribute_map(
          edge_statement.get_attributes(),
        )
      @dot.DotStatementSubgraph(subgraph) => {
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
  root : @graph.ElkNode,
  command : @dot.Command,
) -> @dot.DotTransformationData[@graph.ElkNode, @dot.DotGraphvizModel] {
  let data : @dot.DotTransformationData[@graph.ElkNode, @dot.DotGraphvizModel] = @dot.new_dot_transformation_data()
  data.set_source_graph(root)
  data.set_command_property(@dot.dot_exporter_command, command)
  data
}

///|
test "LayoutDotExporter sets DOT graph attributes and transformation flags" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_double_property(root, @core.spacing_node_node, 72.0)
  @graph.node_set_string_property(root, @core.direction, "RIGHT")
  @graph.node_set_string_property(
    root, graphviz_core_option_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  @graph.node_set_double_property(
    root, graphviz_option_layer_spacing_factor, 2.0,
  )
  @graph.node_set_double_property(root, graphviz_option_iterations_factor, 0.5)
  @graph.node_set_bool_property(root, graphviz_option_concentrate, true)
  @graph.node_set_bool_property(
    root, graphviz_option_adapt_port_positions, false,
  )
  let cluster = @graph.create_node(Some(root))
  ignore(@graph.create_node(Some(cluster)))

  let data = layout_dot_exporter_test_setup_data(
    root,
    @dot.command_parse("dot"),
  )
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  inspect(
    data.get_bool_property(@dot.dot_exporter_use_edge_ids),
    content="true",
  )
  inspect(data.get_bool_property(@dot.dot_exporter_hierarchy), content="true")
  inspect(
    data.get_bool_property(@dot.dot_exporter_transform_node_layout),
    content="false",
  )
  inspect(
    data.get_bool_property(@dot.dot_exporter_transform_edge_layout),
    content="false",
  )
  inspect(
    data.get_bool_property(@dot.dot_exporter_transform_node_labels),
    content="false",
  )
  inspect(
    data.get_bool_property(@dot.dot_exporter_adapt_port_positions),
    content="false",
  )
  inspect(data.get_bool_property(@dot.dot_exporter_use_splines), content="true")

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let graph_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    @dot.dot_attribute_type_graph(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_nodesep),
    ),
    content="\"1\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_ranksep),
    ),
    content="\"2\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_rankdir),
    ),
    content="LR",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_crossmin_limit),
    ),
    content="\"0.5\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_simplex_limit),
    ),
    content="\"50\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_compound),
    ),
    content="true",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_splines),
    ),
    content="spline",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_concentrate),
    ),
    content="true",
  )
}

///|
test "LayoutDotExporter sets NEATO specific graph and edge attributes" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  @graph.node_set_double_property(root, @core.spacing_node_node, 72.0)
  @graph.node_set_layout_option_string_by_id(
    root,
    graphviz_core_option_random_seed.get_id(),
    "0",
  )
  @graph.node_set_double_property(root, graphviz_option_epsilon, 0.2)
  @graph.node_set_string_property(root, graphviz_option_neato_model, "CIRCUIT")
  @graph.node_set_string_property(root, graphviz_option_overlap_mode, "SCALE")
  @graph.node_set_layout_option_string_by_id(
    root,
    graphviz_option_maxiter.get_id(),
    "10",
  )
  @graph.node_set_bool_property(
    root, graphviz_core_option_separate_connected_components, true,
  )
  @graph.node_set_string_property(
    root, graphviz_core_option_edge_routing, "POLYLINE",
  )
  let n0 = @graph.create_node(Some(root))
  let n1 = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(n0))
  @graph.edge_add_target(edge, @graph.make_node_shape(n1))

  let data = layout_dot_exporter_test_setup_data(
    root,
    @dot.command_parse("neato"),
  )
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  inspect(
    data.get_bool_property(@dot.dot_exporter_use_splines),
    content="false",
  )

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let graph_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    @dot.dot_attribute_type_graph(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_start),
    ),
    content="random-1",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_epsilon),
    ),
    content="\"0.2\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_neato_model),
    ),
    content="circuit",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_overlap),
    ),
    content="scale",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_sep),
    ),
    content="\"+36\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_pack),
    ),
    content="\"72\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_maxiter),
    ),
    content="\"10\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      graph_attrs.get(@dot.dot_attr_splines),
    ),
    content="polyline",
  )

  let edge_attrs = layout_dot_exporter_test_find_attribute_map(
    graph.get_statements(),
    @dot.dot_attribute_type_edge(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(@dot.dot_attr_edgedir),
    ),
    content="none",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(@dot.dot_attr_edgelen),
    ),
    content="\"1\"",
  )
}

///|
test "LayoutDotExporter appends label distance and angle for head/tail labels" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))
  @graph.edge_set_layout_option_string_by_id(
    edge,
    graphviz_option_label_distance.get_id(),
    "2.5",
  )
  @graph.edge_set_layout_option_string_by_id(
    edge,
    graphviz_option_label_angle.get_id(),
    "-30",
  )
  let label = @graph.create_label(Some(@graph.make_edge_label_parent(edge)))
  @graph.label_set_text(label, "head")
  @graph.label_set_layout_option_string_by_id(
    label, @dot.dot_exporter_option_edge_labels_placement, "HEAD",
  )

  let data = layout_dot_exporter_test_setup_data(
    root,
    @dot.command_parse("dot"),
  )
  let exporter = new_layout_dot_exporter()
  exporter.transform(data)

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let edge_attrs = layout_dot_exporter_test_find_first_edge_attribute_map(
    graph.get_statements(),
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(@dot.dot_attr_labeldistance),
    ),
    content="\"2.5\"",
  )
  inspect(
    layout_dot_exporter_test_option_string_or_none(
      edge_attrs.get(@dot.dot_attr_labelangle),
    ),
    content="\"-30\"",
  )
}
