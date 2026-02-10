///|
fn option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
fn option_vector_or_none(value : KVector?) -> String {
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

  let root = create_node(None)
  let child = create_node(Some(root))
  let grandchild = create_node(Some(child))
  let other_root = create_node(None)
  let other_child = create_node(Some(other_root))

  inspect(dot_exporter_is_inside_graph(grandchild, root), content="true")
  inspect(exporter.is_inside_graph(grandchild, root), content="true")
  inspect(dot_exporter_is_inside_graph(other_child, root), content="false")

  exporter.set_graph_attributes(statements, root)
  inspect(statements.length(), content="2")
}

///|
test "DotExporter set_edge_labels stacks and formats labels" {
  let root = create_node(None)
  let source = create_node(Some(root))
  let target = create_node(Some(root))
  let edge = create_edge(Some(root))
  edge_add_source(edge, make_node_shape(source))
  edge_add_target(edge, make_node_shape(target))
  edge_set_layout_option_string_by_id(edge, spacing_edge_label.get_id(), "3")

  let center_label = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(center_label, "mid")
  label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_edge_labels_placement, "CENTER",
  )
  label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_font_name, "Arial",
  )
  label_set_layout_option_string_by_id(
    center_label, dot_exporter_option_font_size, "10",
  )

  let head_label = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(head_label, "head")
  label_set_layout_option_string_by_id(
    head_label, dot_exporter_option_edge_labels_placement, "HEAD",
  )

  let tail_label = create_label(Some(make_edge_label_parent(edge)))
  label_set_text(tail_label, "tail")
  label_set_layout_option_string_by_id(
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
  let splines : Array[KVectorChain] = []
  let endpoints = dot_exporter_parse_spline_points(
    "\"s,1,2 3,4 5,6 e,7,8;9,10 11,12\"",
    splines,
    new_kvector_xy(10.0, 20.0),
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
  let splines : Array[KVectorChain] = []
  let endpoints = dot_exporter_parse_spline_points(
    "\"bad s,1 x,y e,4,5\"",
    splines,
    new_kvector(),
  )

  inspect(option_vector_or_none(endpoints.get_first()), content="none")
  inspect(option_vector_or_none(endpoints.get_second()), content="(4,5)")
  inspect(splines.length(), content="1")
  inspect(splines[0].size(), content="0")
}
