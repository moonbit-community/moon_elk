///|
fn graphviz_dot_writer_indent(output : StringBuilder, depth : Int) -> Unit {
  for i = 0; i < depth; i = i + 1 {
    output.write_string("  ")
  }
}

///|
pub fn graphviz_dot_quote(value : String) -> String {
  let output = StringBuilder()
  output.write_char('"')
  for ch in value {
    match ch {
      '"' => output.write_string("\\\"")
      '\\' => output.write_string("\\\\")
      '\n' => output.write_string("\\n")
      '\r' => output.write_string("\\r")
      _ => output.write_char(ch)
    }
  }
  output.write_char('"')
  output.to_string()
}

///|
fn graphviz_dot_writer_attributes(attributes : Array[DotAttribute]) -> String {
  let output = StringBuilder()
  output.write_string("[")
  for i = 0; i < attributes.length(); i = i + 1 {
    if i > 0 {
      output.write_string(", ")
    }
    let attribute = attributes[i]
    output.write_string(graphviz_dot_quote(attribute.get_name().unwrap_or("")))
    output.write_string(" = ")
    output.write_string(graphviz_dot_quote(attribute.get_value().unwrap_or("")))
  }
  output.write_string("]")
  output.to_string()
}

///|
fn graphviz_dot_writer_port(port : DotPort) -> String {
  let output = StringBuilder()
  output.write_string(":")
  output.write_string(graphviz_dot_quote(port.get_name().unwrap_or("")))
  match port.get_compass_pt() {
    Some(compass) => {
      output.write_string(":")
      output.write_string(graphviz_dot_quote(compass))
    }
    None => ()
  }
  output.to_string()
}

///|
fn graphviz_dot_writer_node(node : DotNode) -> String {
  let output = StringBuilder()
  output.write_string(graphviz_dot_quote(node.get_name().unwrap_or("")))
  match node.get_port() {
    Some(port) => output.write_string(graphviz_dot_writer_port(port))
    None => ()
  }
  output.to_string()
}

///|
fn graphviz_dot_writer_attribute_statement(
  output : StringBuilder,
  statement : DotAttributeStatement,
  depth : Int,
) -> Unit {
  let statement_type = match statement.get_type() {
    DotAttributeTypeGraph => "graph"
    DotAttributeTypeNode => "node"
    DotAttributeTypeEdge => "edge"
  }
  graphviz_dot_writer_indent(output, depth)
  output.write_string(statement_type)
  output.write_string(" ")
  output.write_string(
    graphviz_dot_writer_attributes(statement.get_attributes()),
  )
  output.write_string(";\n")
}

///|
fn graphviz_dot_writer_node_statement(
  output : StringBuilder,
  statement : DotNodeStatement,
  depth : Int,
) -> Unit {
  graphviz_dot_writer_indent(output, depth)
  match statement.get_node() {
    Some(node) => output.write_string(graphviz_dot_writer_node(node))
    None => output.write_string("\"\"")
  }
  let attributes = statement.get_attributes()
  if !attributes.is_empty() {
    output.write_string(" ")
    output.write_string(graphviz_dot_writer_attributes(attributes))
  }
  output.write_string(";\n")
}

///|
fn graphviz_dot_writer_edge_operator(operator : DotEdgeOperator) -> String {
  match operator {
    DotEdgeOperatorDirected => "->"
    DotEdgeOperatorUndirected => "--"
  }
}

///|
fn graphviz_dot_writer_edge_statement(
  output : StringBuilder,
  statement : DotEdgeStatement,
  depth : Int,
) -> Unit {
  graphviz_dot_writer_indent(output, depth)
  match statement.get_source_node() {
    Some(node) => output.write_string(graphviz_dot_writer_node(node))
    None => output.write_string("\"\"")
  }
  for target in statement.get_edge_targets() {
    output.write_string(" ")
    output.write_string(
      graphviz_dot_writer_edge_operator(target.get_operator()),
    )
    output.write_string(" ")
    match target.get_targetnode() {
      Some(node) => output.write_string(graphviz_dot_writer_node(node))
      None =>
        match target.get_target_subgraph() {
          Some(subgraph) =>
            output.write_string(
              graphviz_dot_writer_subgraph(subgraph, depth + 1),
            )
          None => output.write_string("\"\"")
        }
    }
  }
  let attributes = statement.get_attributes()
  if !attributes.is_empty() {
    output.write_string(" ")
    output.write_string(graphviz_dot_writer_attributes(attributes))
  }
  output.write_string(";\n")
}

///|
fn graphviz_dot_writer_subgraph(subgraph : DotSubgraph, depth : Int) -> String {
  let output = StringBuilder()
  output.write_string("subgraph")
  match subgraph.get_name() {
    Some(name) => {
      output.write_string(" ")
      output.write_string(graphviz_dot_quote(name))
    }
    None => ()
  }
  output.write_string(" {\n")
  for statement in subgraph.get_statements() {
    graphviz_dot_writer_statement(output, statement, depth + 1)
  }
  graphviz_dot_writer_indent(output, depth)
  output.write_string("}")
  output.to_string()
}

///|
fn graphviz_dot_writer_statement(
  output : StringBuilder,
  statement : DotStatement,
  depth : Int,
) -> Unit {
  match statement {
    DotStatementBase => ()
    DotStatementAttribute(attribute) => {
      graphviz_dot_writer_indent(output, depth)
      output.write_string(
        graphviz_dot_quote(attribute.get_name().unwrap_or("")),
      )
      output.write_string(" = ")
      output.write_string(
        graphviz_dot_quote(attribute.get_value().unwrap_or("")),
      )
      output.write_string(";\n")
    }
    DotStatementNodeStatement(statement) =>
      graphviz_dot_writer_node_statement(output, statement, depth)
    DotStatementEdgeStatement(statement) =>
      graphviz_dot_writer_edge_statement(output, statement, depth)
    DotStatementAttributeStatement(statement) =>
      graphviz_dot_writer_attribute_statement(output, statement, depth)
    DotStatementSubgraph(subgraph) => {
      graphviz_dot_writer_indent(output, depth)
      output.write_string(graphviz_dot_writer_subgraph(subgraph, depth))
      output.write_string(";\n")
    }
  }
}

///|
fn graphviz_dot_writer_graph(output : StringBuilder, graph : DotGraph) -> Unit {
  if graph.is_strict() {
    output.write_string("strict ")
  }
  output.write_string(
    match graph.get_type() {
      DotGraphTypeGraph => "graph"
      DotGraphTypeDigraph => "digraph"
    },
  )
  match graph.get_name() {
    Some(name) => {
      output.write_string(" ")
      output.write_string(graphviz_dot_quote(name))
    }
    None => ()
  }
  output.write_string(" {\n")
  for statement in graph.get_statements() {
    graphviz_dot_writer_statement(output, statement, 1)
  }
  output.write_string("}\n")
}

///|
pub fn graphviz_dot_serialize_model(model : DotGraphvizModel) -> String {
  let output = StringBuilder()
  for graph in model.get_graphs() {
    graphviz_dot_writer_graph(output, graph)
  }
  output.to_string()
}

///|
pub fn graphviz_dot_serialize_model_bytes(
  model : DotGraphvizModel,
) -> Array[Int] {
  let bytes = @utf8.encode(graphviz_dot_serialize_model(model))
  let result : Array[Int] = []
  for byte in bytes {
    result.push(byte.to_int())
  }
  result
}

///|
pub fn graphviz_dot_parse_model_bytes(
  bytes : Array[Int],
) -> DotGraphvizModel raise {
  let encoded : Array[Byte] = []
  for byte in bytes {
    encoded.push(byte.to_byte())
  }
  let text = @utf8.decode(Bytes::from_array(encoded))
  new_graphviz_dot_parser().parse(text)
}
