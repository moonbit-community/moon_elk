///|
pub struct ElkGraphJsonFormatter {
  indent_size : Int
}

///|
pub fn new_elk_graph_json_formatter(
  indent_size? : Int = 2,
) -> ElkGraphJsonFormatter {
  { indent_size, }
}

///|
fn graph_json_text_formatter_indent(level : Int, indent_size : Int) -> String {
  let mut result = ""
  let mut i = 0
  while i < level * indent_size {
    result += " "
    i += 1
  }
  result
}

///|
fn graph_json_text_formatter_connectable_shape_id(
  shape : @graph.ElkConnectableShape,
) -> String {
  match shape {
    NodeShape(node) => @graph.node_identifier(node)
    PortShape(port) => @graph.port_identifier(port)
  }
}

///|
fn graph_json_text_formatter_shape_layout(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> String {
  if x == 0.0 && y == 0.0 && width == 0.0 && height == 0.0 {
    ""
  } else if width == 0.0 && height == 0.0 {
    " layout [position: " + x.to_string() + ", " + y.to_string() + "]"
  } else if x == 0.0 && y == 0.0 {
    " layout [size: " + width.to_string() + ", " + height.to_string() + "]"
  } else {
    " layout [position: " +
    x.to_string() +
    ", " +
    y.to_string() +
    " size: " +
    width.to_string() +
    ", " +
    height.to_string() +
    "]"
  }
}

///|
fn graph_json_text_formatter_format_label(
  formatter : ElkGraphJsonFormatter,
  label : @graph.ElkLabel,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "label "
  let id = @graph.label_identifier(label)
  if id != "" {
    text += id + ": "
  }
  text += "\"" + @graph.label_text(label) + "\""
  text += graph_json_text_formatter_shape_layout(
    @graph.label_x(label),
    @graph.label_y(label),
    @graph.label_width(label),
    @graph.label_height(label),
  )
  let nested = @graph.label_labels(label)
  if nested.length() == 0 {
    return text + "\n"
  }
  let mut block = text + " {\n"
  for child in nested {
    block += graph_json_text_formatter_format_label(formatter, child, level + 1)
  }
  block + indent + "}\n"
}

///|
fn graph_json_text_formatter_format_port(
  formatter : ElkGraphJsonFormatter,
  port : @graph.ElkPort,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "port " + @graph.port_identifier(port)
  text += graph_json_text_formatter_shape_layout(
    @graph.port_x(port),
    @graph.port_y(port),
    @graph.port_width(port),
    @graph.port_height(port),
  )
  let labels = @graph.port_labels(port)
  if labels.length() == 0 {
    return text + "\n"
  }
  let mut block = text + " {\n"
  for label in labels {
    block += graph_json_text_formatter_format_label(formatter, label, level + 1)
  }
  block + indent + "}\n"
}

///|
fn graph_json_text_formatter_format_edge_section(
  formatter : ElkGraphJsonFormatter,
  section : @graph.ElkEdgeSection,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let id = @graph.edge_section_identifier(section)
  let mut text = if id == "" { indent } else { indent + "section " + id + " [" }
  if @graph.edge_section_incoming_shape(section) is Some(shape) {
    text += "incoming: " +
      graph_json_text_formatter_connectable_shape_id(shape) +
      " "
  }
  if @graph.edge_section_outgoing_shape(section) is Some(shape) {
    text += "outgoing: " +
      graph_json_text_formatter_connectable_shape_id(shape) +
      " "
  }
  text += "start: " +
    @graph.edge_section_start_x(section).to_string() +
    ", " +
    @graph.edge_section_start_y(section).to_string() +
    " "
  text += "end: " +
    @graph.edge_section_end_x(section).to_string() +
    ", " +
    @graph.edge_section_end_y(section).to_string()
  if id != "" {
    text += "]"
  }
  text + "\n"
}

///|
fn graph_json_text_formatter_format_edge(
  formatter : ElkGraphJsonFormatter,
  edge : @graph.ElkEdge,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "edge "
  let edge_id = @graph.edge_identifier(edge)
  if edge_id != "" {
    text += edge_id + ": "
  }
  let sources : Array[String] = []
  for source in @graph.edge_sources(edge) {
    sources.push(graph_json_text_formatter_connectable_shape_id(source))
  }
  let targets : Array[String] = []
  for target in @graph.edge_targets(edge) {
    targets.push(graph_json_text_formatter_connectable_shape_id(target))
  }
  text += sources.join(", ") + " -> " + targets.join(", ")
  let sections = @graph.edge_sections(edge)
  let labels = @graph.edge_labels(edge)
  if sections.length() == 0 && labels.length() == 0 {
    return text + "\n"
  }
  let mut block = text + " {\n"
  if sections.length() > 0 {
    block += indent +
      graph_json_text_formatter_indent(1, formatter.indent_size) +
      "layout [\n"
    for section in sections {
      block += graph_json_text_formatter_format_edge_section(
        formatter,
        section,
        level + 2,
      )
    }
    block += indent +
      graph_json_text_formatter_indent(1, formatter.indent_size) +
      "]\n"
  }
  for label in labels {
    block += graph_json_text_formatter_format_label(formatter, label, level + 1)
  }
  block + indent + "}\n"
}

///|
fn graph_json_text_formatter_format_node(
  formatter : ElkGraphJsonFormatter,
  node : @graph.ElkNode,
  level : Int,
  root : Bool,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = if root { "graph" } else { indent + "node" }
  let id = @graph.node_identifier(node)
  if id != "" {
    text += " " + id
  }
  text += graph_json_text_formatter_shape_layout(
    @graph.node_x(node),
    @graph.node_y(node),
    @graph.node_width(node),
    @graph.node_height(node),
  )
  let labels = @graph.node_labels(node)
  let ports = @graph.node_ports(node)
  let children = @graph.node_children(node)
  let edges = @graph.node_contained_edges(node)
  if labels.length() == 0 &&
    ports.length() == 0 &&
    children.length() == 0 &&
    edges.length() == 0 {
    return text + "\n"
  }
  let mut block = text + " {\n"
  for label in labels {
    block += graph_json_text_formatter_format_label(formatter, label, level + 1)
  }
  for port in ports {
    block += graph_json_text_formatter_format_port(formatter, port, level + 1)
  }
  for child in children {
    block += graph_json_text_formatter_format_node(
      formatter,
      child,
      level + 1,
      false,
    )
  }
  for edge in edges {
    block += graph_json_text_formatter_format_edge(formatter, edge, level + 1)
  }
  let close_indent = if root { "" } else { indent }
  block + close_indent + "}\n"
}

///|
pub fn ElkGraphJsonFormatter::format(
  self : ElkGraphJsonFormatter,
  root : @graph.ElkNode,
) -> String {
  graph_json_text_formatter_format_node(self, root, 0, true)
}
