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
  shape : ElkConnectableShape,
) -> String {
  match shape {
    NodeShape(node) => node_identifier(node)
    PortShape(port) => port_identifier(port)
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
  label : ElkLabel,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "label "
  let id = label_identifier(label)
  if id != "" {
    text += id + ": "
  }
  text += "\"" + label_text(label) + "\""
  text += graph_json_text_formatter_shape_layout(
    label_x(label),
    label_y(label),
    label_width(label),
    label_height(label),
  )
  let nested = label_labels(label)
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
  port : ElkPort,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "port " + port_identifier(port)
  text += graph_json_text_formatter_shape_layout(
    port_x(port),
    port_y(port),
    port_width(port),
    port_height(port),
  )
  let labels = port_labels(port)
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
  section : ElkEdgeSection,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let id = edge_section_identifier(section)
  let mut text = if id == "" { indent } else { indent + "section " + id + " [" }
  if edge_section_incoming_shape(section) is Some(shape) {
    text += "incoming: " +
      graph_json_text_formatter_connectable_shape_id(shape) +
      " "
  }
  if edge_section_outgoing_shape(section) is Some(shape) {
    text += "outgoing: " +
      graph_json_text_formatter_connectable_shape_id(shape) +
      " "
  }
  text += "start: " +
    edge_section_start_x(section).to_string() +
    ", " +
    edge_section_start_y(section).to_string() +
    " "
  text += "end: " +
    edge_section_end_x(section).to_string() +
    ", " +
    edge_section_end_y(section).to_string()
  if id != "" {
    text += "]"
  }
  text + "\n"
}

///|
fn graph_json_text_formatter_format_edge(
  formatter : ElkGraphJsonFormatter,
  edge : ElkEdge,
  level : Int,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = indent + "edge "
  let edge_id = edge_identifier(edge)
  if edge_id != "" {
    text += edge_id + ": "
  }
  let sources : Array[String] = []
  for source in edge_sources(edge) {
    sources.push(graph_json_text_formatter_connectable_shape_id(source))
  }
  let targets : Array[String] = []
  for target in edge_targets(edge) {
    targets.push(graph_json_text_formatter_connectable_shape_id(target))
  }
  text += sources.join(", ") + " -> " + targets.join(", ")
  let sections = edge_sections(edge)
  let labels = edge_labels(edge)
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
  node : ElkNode,
  level : Int,
  root : Bool,
) -> String {
  let indent = graph_json_text_formatter_indent(level, formatter.indent_size)
  let mut text = if root { "graph" } else { indent + "node" }
  let id = node_identifier(node)
  if id != "" {
    text += " " + id
  }
  text += graph_json_text_formatter_shape_layout(
    node_x(node),
    node_y(node),
    node_width(node),
    node_height(node),
  )
  let labels = node_labels(node)
  let ports = node_ports(node)
  let children = node_children(node)
  let edges = node_contained_edges(node)
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
  root : ElkNode,
) -> String {
  graph_json_text_formatter_format_node(self, root, 0, true)
}
