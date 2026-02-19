///|
fn dot_importer_test_option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
    None => "none"
  }
}

///|
fn dot_importer_test_find_node_by_identifier(
  parent : ElkNode,
  identifier : String,
) -> ElkNode? {
  for child in node_children(parent) {
    if node_identifier(child) == identifier {
      return Some(child)
    }
  }
  None
}

///|
fn dot_importer_test_find_node_statement(
  statements : Array[DotStatement],
  node_name : String,
) -> DotNodeStatement? {
  for statement in statements {
    match statement {
      DotStatementNodeStatement(node_statement) =>
        match node_statement.get_node() {
          Some(node) =>
            if node.get_name() == Some(node_name) {
              return Some(node_statement)
            }
          None => ()
        }
      _ => ()
    }
  }
  None
}

///|
fn dot_importer_test_find_edge_statement(
  statements : Array[DotStatement],
  source_name : String,
  target_name : String,
) -> DotEdgeStatement? {
  for statement in statements {
    match statement {
      DotStatementEdgeStatement(edge_statement) =>
        if edge_statement.get_source_node() is Some(source_node) &&
          source_node.get_name() == Some(source_name) &&
          !edge_statement.get_edge_targets().is_empty() &&
          edge_statement.get_edge_targets()[0].get_targetnode()
          is Some(target_node) &&
          target_node.get_name() == Some(target_name) {
          return Some(edge_statement)
        }
      _ => ()
    }
  }
  None
}

///|
test "DotImporter transform basic graph" {
  reset_graph_model_for_test()
  let graphviz_model = dot_create_graphviz_model()
  let graph = dot_create_graph()
  graph.set_type(Some(dot_graph_type_digraph()))
  graphviz_model.get_graphs().push(graph)

  let graph_attr_statement = dot_create_attribute_statement()
  graph_attr_statement.set_type(Some(dot_attribute_type_graph()))
  graph_attr_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_rankdir, "\"LR\""))
  graph
  .get_statements()
  .push(dot_statement_attribute_statement(graph_attr_statement))

  let node_a_statement = dot_create_node_statement()
  let node_a = dot_create_node()
  node_a.set_name(Some("a"))
  node_a_statement.set_node(Some(node_a))
  node_a_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_width, "\"2\""))
  node_a_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_height, "\"1\""))
  node_a_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_label, "\"node-a\""))
  graph.get_statements().push(dot_statement_node_statement(node_a_statement))

  let node_b_statement = dot_create_node_statement()
  let node_b = dot_create_node()
  node_b.set_name(Some("b"))
  node_b_statement.set_node(Some(node_b))
  graph.get_statements().push(dot_statement_node_statement(node_b_statement))

  let edge_statement = dot_create_edge_statement()
  let source_node = dot_create_node()
  source_node.set_name(Some("a"))
  edge_statement.set_source_node(Some(source_node))
  let edge_target = dot_create_edge_target()
  let target_node = dot_create_node()
  target_node.set_name(Some("b"))
  edge_target.set_targetnode(Some(target_node))
  edge_statement.get_edge_targets().push(edge_target)
  edge_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_label, "\"edge-label\""))
  graph.get_statements().push(dot_statement_edge_statement(edge_statement))

  let data : DotTransformationData[DotGraphvizModel, ElkNode] = new_dot_transformation_data()
  data.set_source_graph(graphviz_model)
  let importer = new_dot_importer()
  importer.transform(data)

  inspect(data.get_target_graphs().length(), content="1")
  let root = data.get_target_graphs()[0]
  inspect(node_children(root).length(), content="2")
  inspect(node_get_string_property(root, direction), content="RIGHT")

  let node_a_imported = match
    dot_importer_test_find_node_by_identifier(root, "a") {
    Some(node) => node
    None => create_node(None)
  }
  inspect(node_width(node_a_imported), content="144")
  inspect(node_height(node_a_imported), content="72")
  inspect(node_labels(node_a_imported).length(), content="1")
  inspect(label_text(node_labels(node_a_imported)[0]), content="node-a")

  inspect(node_outgoing_edges(node_a_imported).length(), content="1")
  let edge = node_outgoing_edges(node_a_imported)[0]
  inspect(edge_labels(edge).length(), content="1")
  inspect(label_text(edge_labels(edge)[0]), content="edge-label")
  inspect(
    dot_importer_test_option_string_or_none(
      label_layout_option_string_value(
        edge_labels(edge)[0],
        dot_exporter_option_edge_labels_placement,
      ),
    ),
    content="CENTER",
  )
}

///|
test "DotImporter transfer_layout updates statements" {
  reset_graph_model_for_test()
  let graphviz_model = dot_create_graphviz_model()
  let graph = dot_create_graph()
  graph.set_type(Some(dot_graph_type_digraph()))
  graphviz_model.get_graphs().push(graph)

  let node_a_statement = dot_create_node_statement()
  let node_a = dot_create_node()
  node_a.set_name(Some("a"))
  node_a_statement.set_node(Some(node_a))
  graph.get_statements().push(dot_statement_node_statement(node_a_statement))

  let node_b_statement = dot_create_node_statement()
  let node_b = dot_create_node()
  node_b.set_name(Some("b"))
  node_b_statement.set_node(Some(node_b))
  graph.get_statements().push(dot_statement_node_statement(node_b_statement))

  let edge_statement = dot_create_edge_statement()
  let source_node = dot_create_node()
  source_node.set_name(Some("a"))
  edge_statement.set_source_node(Some(source_node))
  let edge_target = dot_create_edge_target()
  let target_node = dot_create_node()
  target_node.set_name(Some("b"))
  edge_target.set_targetnode(Some(target_node))
  edge_statement.get_edge_targets().push(edge_target)
  edge_statement
  .get_attributes()
  .push(dot_exporter_create_attribute(dot_attr_label, "\"edge-label\""))
  graph.get_statements().push(dot_statement_edge_statement(edge_statement))

  let data : DotTransformationData[DotGraphvizModel, ElkNode] = new_dot_transformation_data()
  data.set_source_graph(graphviz_model)
  let importer = new_dot_importer()
  importer.transform(data)

  let root = data.get_target_graphs()[0]
  let node_a_imported = match
    dot_importer_test_find_node_by_identifier(root, "a") {
    Some(node) => node
    None => create_node(None)
  }
  let node_b_imported = match
    dot_importer_test_find_node_by_identifier(root, "b") {
    Some(node) => node
    None => create_node(None)
  }

  node_set_location(node_a_imported, 10.0, 20.0)
  node_set_dimensions(node_a_imported, 30.0, 40.0)
  node_set_location(node_b_imported, 100.0, 120.0)
  node_set_dimensions(node_b_imported, 50.0, 60.0)
  node_set_dimensions(root, 240.0, 160.0)

  let edge = node_outgoing_edges(node_a_imported)[0]
  let section = create_edge_section(edge)
  edge_section_set_start(section, 25.0, 40.0)
  edge_section_set_end(section, 125.0, 150.0)

  let edge_label = edge_labels(edge)[0]
  label_set_location(edge_label, 60.0, 70.0)
  label_set_dimensions(edge_label, 20.0, 10.0)

  importer.transfer_layout(data)

  let updated_node_a_statement = match
    dot_importer_test_find_node_statement(graph.get_statements(), "a") {
    Some(statement) => statement
    None => dot_create_node_statement()
  }
  let updated_node_a_attr_map = dot_exporter_create_attribute_map(
    updated_node_a_statement.get_attributes(),
  )
  inspect(
    dot_importer_test_option_string_or_none(
      updated_node_a_attr_map.get(dot_attr_pos),
    ),
    content="\"25,40\"",
  )
  inspect(
    dot_importer_test_option_string_or_none(
      updated_node_a_attr_map.get(dot_attr_width),
    ),
    content="\"0.4166666666666667\"",
  )
  inspect(
    dot_importer_test_option_string_or_none(
      updated_node_a_attr_map.get(dot_attr_height),
    ),
    content="\"0.5555555555555556\"",
  )

  let updated_edge_statement = match
    dot_importer_test_find_edge_statement(graph.get_statements(), "a", "b") {
    Some(statement) => statement
    None => dot_create_edge_statement()
  }
  let updated_edge_attr_map = dot_exporter_create_attribute_map(
    updated_edge_statement.get_attributes(),
  )
  inspect(
    dot_importer_test_option_string_or_none(
      updated_edge_attr_map.get(dot_attr_pos),
    ),
    content="\"25,40 125,150\"",
  )
  inspect(
    dot_importer_test_option_string_or_none(
      updated_edge_attr_map.get(dot_attr_labelpos),
    ),
    content="\"70,75\"",
  )
}
