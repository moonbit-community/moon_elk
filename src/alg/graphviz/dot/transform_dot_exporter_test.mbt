///|
fn option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
fn option_vector_or_none(value : @core.KVector?) -> String {
  match value {
    Some(v) => v.to_string()
    None => "none"
  }
}

///|
fn option_int_or_none(value : Int?) -> String {
  match value {
    Some(v) => v.to_string()
    None => "none"
  }
}

///|
test "DotExporter create_attribute overloads" {
  let attr0 = dot_exporter_create_attribute(dot_attr_label, "\"hello\"")
  inspect(option_string_or_none(attr0.get_name()), content="label")
  inspect(option_string_or_none(attr0.get_value()), content="\"hello\"")

  let attr1 = dot_exporter_create_attribute_int(dot_attr_fontsize, 16)
  inspect(option_string_or_none(attr1.get_name()), content="fontsize")
  inspect(option_string_or_none(attr1.get_value()), content="\"16\"")

  let attr2 = dot_exporter_create_attribute_float(dot_attr_width, 1.5)
  inspect(option_string_or_none(attr2.get_value()), content="\"1.5\"")

  let attr3 = dot_exporter_create_attribute_double(dot_attr_height, 2.25)
  inspect(option_string_or_none(attr3.get_value()), content="\"2.25\"")
}

///|
test "DotExporter create_string escaping" {
  let escaped = dot_exporter_create_string("a\"b\\c\n\td")
  inspect(escaped, content="\"a_b_c\\nd\"")
}

///|
test "DotExporter create_attribute_map" {
  let attr0 = dot_exporter_create_attribute(dot_attr_label, "\"x\"")
  let attr1 = dot_exporter_create_attribute(dot_attr_pos, "\"1,2\"")
  let attr2 = dot_exporter_create_attribute(dot_attr_comment, "\"edge1\"")
  let attribute_map = dot_exporter_create_attribute_map([attr0, attr1, attr2])

  inspect(
    option_string_or_none(attribute_map.get(dot_attr_label)),
    content="\"x\"",
  )
  inspect(
    option_string_or_none(attribute_map.get(dot_attr_pos)),
    content="\"1,2\"",
  )
  inspect(
    option_string_or_none(attribute_map.get(dot_attr_comment)),
    content="\"edge1\"",
  )
  inspect(option_string_or_none(attribute_map.get("missing")), content="none")
}

///|
test "DotExporter set_general_node_attributes and set_general_edge_attributes" {
  let statements : Array[DotStatement] = []

  let node_attrs = dot_exporter_set_general_node_attributes(statements)
  let edge_attrs = dot_exporter_set_general_edge_attributes(statements)

  inspect(statements.length(), content="2")
  inspect(node_attrs.length(), content="2")
  inspect(option_string_or_none(node_attrs[0].get_name()), content="shape")
  inspect(option_string_or_none(node_attrs[0].get_value()), content="box")
  inspect(option_string_or_none(node_attrs[1].get_name()), content="fixedsize")
  inspect(option_string_or_none(node_attrs[1].get_value()), content="true")
  inspect(edge_attrs.length(), content="1")
  inspect(option_string_or_none(edge_attrs[0].get_name()), content="dir")
  inspect(option_string_or_none(edge_attrs[0].get_value()), content="none")
  inspect(
    match statements[0] {
      DotStatementAttributeStatement(stmt) =>
        dot_attribute_type_to_string(stmt.get_type())
      _ => "none"
    },
    content="node",
  )
  inspect(
    match statements[1] {
      DotStatementAttributeStatement(stmt) =>
        dot_attribute_type_to_string(stmt.get_type())
      _ => "none"
    },
    content="edge",
  )
}

///|
test "DotExporter wrappers and is_inside_graph" {
  let exporter = new_dot_exporter()
  let statements : Array[DotStatement] = []
  ignore(exporter.set_general_node_attributes(statements))
  ignore(exporter.set_general_edge_attributes(statements))
  inspect(statements.length(), content="2")

  let root = @graph.create_node(None)
  let child = @graph.create_node(Some(root))
  let grandchild = @graph.create_node(Some(child))
  let other_root = @graph.create_node(None)
  let other_child = @graph.create_node(Some(other_root))

  inspect(dot_exporter_is_inside_graph(grandchild, root), content="true")
  inspect(exporter.is_inside_graph(grandchild, root), content="true")
  inspect(dot_exporter_is_inside_graph(other_child, root), content="false")

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)
  exporter.set_graph_attributes(statements, root, data)
  inspect(statements.length(), content="2")
}

///|
test "DotExporter node and edge id generation" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let n0 = @graph.create_node(Some(root))
  let n1 = @graph.create_node(Some(root))
  let e0 = @graph.create_edge(Some(root))

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  let map_property = dot_exporter_graph_elems
  data.set_graph_elem_map_property(map_property, {})

  let node_id = dot_exporter_get_node_id(
    n0,
    dot_exporter_node_type_node(),
    data,
  )
  let cluster_id = dot_exporter_get_node_id(
    n1,
    dot_exporter_node_type_cluster(),
    data,
  )
  let dummy_id = dot_exporter_get_node_id(
    n1,
    dot_exporter_node_type_dummy(),
    data,
  )
  let edge_id = dot_exporter_get_edge_id(e0, data)

  inspect(node_id, content="node1")
  inspect(cluster_id, content="cluster2")
  inspect(dummy_id, content="dummy3")
  inspect(edge_id, content="edge1")
  inspect(data.get_int_property(dot_exporter_next_node_id), content="4")
  inspect(data.get_int_property(dot_exporter_next_edge_id), content="2")
  inspect(
    @graph.node_get_string_property(n1, dot_exporter_cluster_dummy),
    content="dummy3",
  )

  let graph_elems = data.get_graph_elem_map_property(map_property)
  inspect(graph_elems.length(), content="3")
  inspect(
    option_int_or_none(
      match graph_elems.get("node1") {
        Some(element) => dot_graph_element_as_node(element)
        None => None
      },
    ),
    content="1",
  )
  inspect(
    option_int_or_none(
      match graph_elems.get("cluster2") {
        Some(element) => dot_graph_element_as_node(element)
        None => None
      },
    ),
    content="2",
  )
  inspect(
    option_int_or_none(
      match graph_elems.get("edge1") {
        Some(element) => dot_graph_element_as_edge(element)
        None => None
      },
    ),
    content="0",
  )
}

///|
test "DotExporter transform basic graph" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source = @graph.create_node(Some(root))
  @graph.node_set_dimensions(source, 72.0, 36.0)
  @graph.node_set_location(source, 10.0, 20.0)
  let source_label = @graph.create_label(
    Some(@graph.make_node_label_parent(source)),
  )
  @graph.label_set_text(source_label, "source")

  let target = @graph.create_node(Some(root))
  @graph.node_set_dimensions(target, 36.0, 72.0)
  @graph.node_set_location(target, 100.0, 200.0)

  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)

  let exporter = new_dot_exporter()
  exporter.transform(data)

  inspect(data.get_target_graphs().length(), content="1")
  let model = data.get_target_graphs()[0]
  inspect(model.get_graphs().length(), content="1")
  let graph = model.get_graphs()[0]
  inspect(dot_graph_type_to_string(graph.get_type()), content="digraph")
  inspect(graph.get_statements().length(), content="3")

  let node_stmt_0 = match graph.get_statements()[0] {
    DotStatementNodeStatement(statement) => statement
    _ => dot_create_node_statement()
  }
  let node_stmt_1 = match graph.get_statements()[1] {
    DotStatementNodeStatement(statement) => statement
    _ => dot_create_node_statement()
  }
  let edge_stmt = match graph.get_statements()[2] {
    DotStatementEdgeStatement(statement) => statement
    _ => dot_create_edge_statement()
  }

  inspect(
    option_string_or_none(
      match node_stmt_0.get_node() {
        Some(node) => node.get_name()
        None => None
      },
    ),
    content="node1",
  )
  inspect(
    option_string_or_none(
      match node_stmt_1.get_node() {
        Some(node) => node.get_name()
        None => None
      },
    ),
    content="node2",
  )
  inspect(
    option_string_or_none(
      match edge_stmt.get_source_node() {
        Some(node) => node.get_name()
        None => None
      },
    ),
    content="node1",
  )
  inspect(
    option_string_or_none(
      match edge_stmt.get_edge_targets()[0].get_targetnode() {
        Some(node) => node.get_name()
        None => None
      },
    ),
    content="node2",
  )
}

///|
test "DotExporter transform emits edge ids when enabled" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)
  data.set_bool_property(dot_exporter_use_edge_ids, true)

  let exporter = new_dot_exporter()
  exporter.transform(data)
  let model = data.get_target_graphs()[0]
  let graph = model.get_graphs()[0]
  let edge_stmt = match graph.get_statements()[2] {
    DotStatementEdgeStatement(statement) => statement
    _ => dot_create_edge_statement()
  }
  let edge_attrs = dot_exporter_create_attribute_map(edge_stmt.get_attributes())
  inspect(
    option_string_or_none(edge_attrs.get(dot_attr_comment)),
    content="\"edge1\"",
  )

  let graph_elems = data.get_graph_elem_map_property(dot_exporter_graph_elems)
  inspect(
    option_int_or_none(
      match graph_elems.get("edge1") {
        Some(element) => dot_graph_element_as_edge(element)
        None => None
      },
    ),
    content="0",
  )
}

///|
test "DotExporter transform exports edge position from section" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))
  let section = @graph.create_edge_section(edge)
  @graph.edge_section_set_start(section, 10.0, 20.0)
  @graph.edge_section_set_end(section, 30.0, 40.0)

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)

  let exporter = new_dot_exporter()
  exporter.transform(data)

  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let edge_stmt = match graph.get_statements()[2] {
    DotStatementEdgeStatement(statement) => statement
    _ => dot_create_edge_statement()
  }
  let edge_attrs = dot_exporter_create_attribute_map(edge_stmt.get_attributes())
  inspect(
    option_string_or_none(edge_attrs.get(dot_attr_pos)),
    content="\"10,20 30,40\"",
  )
}

///|
test "DotExporter transfer_layout applies node edge and label geometry" {
  @graph.reset_graph_model_for_test()
  let root = @graph.create_graph()
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))

  let center_label = @graph.create_label(
    Some(@graph.make_edge_label_parent(edge)),
  )
  @graph.label_set_text(center_label, "mid")
  @graph.label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_edge_labels_placement, "CENTER",
  )
  @graph.label_set_dimensions(center_label, 20.0, 10.0)

  let data : DotTransformationData[@graph.ElkNode, DotGraphvizModel] = new_dot_transformation_data()
  data.set_source_graph(root)
  data.set_bool_property(dot_exporter_use_edge_ids, true)
  data.set_bool_property(dot_exporter_use_splines, true)

  let exporter = new_dot_exporter()
  exporter.transform(data)
  let graph = data.get_target_graphs()[0].get_graphs()[0]
  let statements = graph.get_statements()

  let graph_attr_stmt = dot_create_attribute_statement()
  graph_attr_stmt.set_type(Some(dot_attribute_type_graph()))
  graph_attr_stmt
  .get_attributes()
  .push(
    dot_exporter_create_attribute(dot_attr_boundingbox, "\"10,100,210,20\""),
  )
  statements.insert(0, dot_statement_attribute_statement(graph_attr_stmt))

  let node_stmt_0 = match statements[1] {
    DotStatementNodeStatement(statement) => statement
    _ => dot_create_node_statement()
  }
  node_stmt_0
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_pos, "\"46,92\""))
  node_stmt_0
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_width, "\"1\""))
  node_stmt_0
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_height, "\"1\""))

  let node_stmt_1 = match statements[2] {
    DotStatementNodeStatement(statement) => statement
    _ => dot_create_node_statement()
  }
  node_stmt_1
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_pos, "\"154,92\""))
  node_stmt_1
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_width, "\"1\""))
  node_stmt_1
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_height, "\"1\""))

  let edge_stmt = match statements[3] {
    DotStatementEdgeStatement(statement) => statement
    _ => dot_create_edge_statement()
  }
  let edge_attrs = edge_stmt.get_attributes()
  edge_attrs.push(
    dot_exporter_create_attribute(dot_attr_pos, "\"e,154,92 100,92 s,46,92\""),
  )
  edge_attrs.push(
    dot_exporter_create_attribute(dot_attr_labelpos, "\"100,100\""),
  )
  edge_attrs.push(dot_exporter_create_attribute(dot_attr_comment, "edge1"))

  exporter.transfer_layout(data)

  inspect(@graph.node_x(root), content="0")
  inspect(@graph.node_y(root), content="0")
  inspect(@graph.node_width(root), content="224")
  inspect(@graph.node_height(root), content="104")
  inspect(@graph.node_x(source), content="12")
  inspect(@graph.node_y(source), content="48")
  inspect(@graph.node_x(target), content="120")
  inspect(@graph.node_y(target), content="48")

  let section = @graph.edge_sections(edge)[0]
  inspect(@graph.edge_section_start_x(section), content="48")
  inspect(@graph.edge_section_start_y(section), content="84")
  inspect(@graph.edge_section_end_x(section), content="156")
  inspect(@graph.edge_section_end_y(section), content="84")

  inspect(
    option_string_or_none(
      @graph.edge_layout_option_string_value(
        edge, dot_exporter_option_edge_routing,
      ),
    ),
    content="SPLINES",
  )
  inspect(@graph.label_x(center_label), content="92")
  inspect(@graph.label_y(center_label), content="87")
}

///|
test "DotExporter set_edge_labels stacks and formats labels" {
  let root = @graph.create_node(None)
  let source = @graph.create_node(Some(root))
  let target = @graph.create_node(Some(root))
  let edge = @graph.create_edge(Some(root))
  @graph.edge_add_source(edge, @graph.make_node_shape(source))
  @graph.edge_add_target(edge, @graph.make_node_shape(target))
  @graph.edge_set_layout_option_string_by_id(
    edge,
    @core.spacing_edge_label.get_id(),
    "3",
  )

  let center_label = @graph.create_label(
    Some(@graph.make_edge_label_parent(edge)),
  )
  @graph.label_set_text(center_label, "mid")
  @graph.label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_edge_labels_placement, "CENTER",
  )
  @graph.label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_font_name, "Arial",
  )
  @graph.label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_font_size, "10",
  )

  let head_label = @graph.create_label(
    Some(@graph.make_edge_label_parent(edge)),
  )
  @graph.label_set_text(head_label, "head")
  @graph.label_set_layout_option_string_by_id(
    head_label, dot_exporter_option_edge_labels_placement, "HEAD",
  )

  let tail_label = @graph.create_label(
    Some(@graph.make_edge_label_parent(edge)),
  )
  @graph.label_set_text(tail_label, "tail")
  @graph.label_set_layout_option_string_by_id(
    tail_label, dot_exporter_option_edge_labels_placement, "TAIL",
  )

  let attrs : Array[DotAttribute] = []
  dot_exporter_set_edge_labels(edge, attrs, false)
  let attr_map = dot_exporter_create_attribute_map(attrs)
  inspect(
    option_string_or_none(attr_map.get(dot_attr_label)),
    content="\"mid\\nO\\nO\"",
  )
  inspect(
    option_string_or_none(attr_map.get(dot_attr_headlabel)),
    content="\"head\"",
  )
  inspect(
    option_string_or_none(attr_map.get(dot_attr_taillabel)),
    content="\"tail\"",
  )
  inspect(
    option_string_or_none(attr_map.get(dot_attr_fontname)),
    content="\"Arial\"",
  )
  inspect(
    option_string_or_none(attr_map.get(dot_attr_fontsize)),
    content="\"14\"",
  )

  let exporter = new_dot_exporter()
  let vertical_attrs : Array[DotAttribute] = []
  exporter.set_edge_labels(edge, vertical_attrs, true)
  let vertical_map = dot_exporter_create_attribute_map(vertical_attrs)
  inspect(
    option_string_or_none(vertical_map.get(dot_attr_label)),
    content="\"midOO\"",
  )
}

///|
test "DotExporter parse_spline_points with source and target markers" {
  let splines : Array[@core.KVectorChain] = []
  let endpoints = dot_exporter_parse_spline_points(
    "\"s,1,2 3,4 5,6 e,7,8;9,10 11,12\"",
    splines,
    @core.new_kvector_xy(10.0, 20.0),
  )

  inspect(option_vector_or_none(endpoints.get_first()), content="(11,22)")
  inspect(option_vector_or_none(endpoints.get_second()), content="(17,28)")
  inspect(splines.length(), content="2")
  inspect(splines[0].size(), content="2")
  inspect(splines[0].get(0).to_string(), content="(13,24)")
  inspect(splines[0].get(1).to_string(), content="(15,26)")
  inspect(splines[1].size(), content="2")
  inspect(splines[1].get(0).to_string(), content="(19,30)")
  inspect(splines[1].get(1).to_string(), content="(21,32)")
}

///|
test "DotExporter parse_spline_points ignores malformed tokens" {
  let splines : Array[@core.KVectorChain] = []
  let endpoints = dot_exporter_parse_spline_points(
    "\"bad s,1 x,y e,4,5\"",
    splines,
    @core.new_kvector(),
  )

  inspect(option_vector_or_none(endpoints.get_first()), content="none")
  inspect(option_vector_or_none(endpoints.get_second()), content="(4,5)")
  inspect(splines.length(), content="1")
  inspect(splines[0].size(), content="0")
}
