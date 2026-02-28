///|
fn graph_json_text_ui_join_qualified_name(parts : Array[String]) -> String {
  if parts.is_empty() {
    return ""
  }
  let mut result = ""
  for i = 0; i < parts.length(); i = i + 1 {
    if i > 0 {
      result += "."
    }
    result += parts[i]
  }
  result
}

///|
fn graph_json_text_ui_shape_name(
  provider : @text.ElkGraphJsonQualifiedNameProvider,
  shape : @graph.ElkConnectableShape,
) -> String {
  match shape {
    NodeShape(node) => {
      let text = graph_json_text_ui_join_qualified_name(
        provider.qualified_name(@text.GraphJsonTextNode(node)),
      )
      if text.is_empty() {
        "?"
      } else {
        text
      }
    }
    PortShape(port) => {
      let text = graph_json_text_ui_join_qualified_name(
        provider.qualified_name(@text.GraphJsonTextPort(port)),
      )
      if text.is_empty() {
        "?"
      } else {
        text
      }
    }
  }
}

///|
pub struct ElkGraphJsonLabelProvider {
  name_provider : @text.ElkGraphJsonQualifiedNameProvider
}

///|
pub fn new_elk_graph_json_label_provider(
  name_provider? : @text.ElkGraphJsonQualifiedNameProvider = @text.new_elk_graph_json_qualified_name_provider(),
) -> ElkGraphJsonLabelProvider {
  { name_provider, }
}

///|
pub fn ElkGraphJsonLabelProvider::image_elk_node(
  self : ElkGraphJsonLabelProvider,
  node : @graph.ElkNode,
) -> String {
  ignore(self)
  match @graph.node_parent(node) {
    Some(_) => "elknode.gif"
    None => "elkgraph.gif"
  }
}

///|
pub fn ElkGraphJsonLabelProvider::image_elk_port(
  self : ElkGraphJsonLabelProvider,
  port : @graph.ElkPort,
) -> String {
  ignore(self)
  ignore(port)
  "elkport.gif"
}

///|
pub fn ElkGraphJsonLabelProvider::text_elk_node(
  self : ElkGraphJsonLabelProvider,
  node : @graph.ElkNode,
) -> String {
  let text = graph_json_text_ui_join_qualified_name(
    self.name_provider.qualified_name(@text.GraphJsonTextNode(node)),
  )
  if text.is_empty() {
    "<unnamed>"
  } else {
    text
  }
}

///|
pub fn ElkGraphJsonLabelProvider::text_elk_edge(
  self : ElkGraphJsonLabelProvider,
  edge : @graph.ElkEdge,
) -> String {
  let mut result = ""
  let id = @graph.edge_identifier(edge)
  if !id.is_empty() {
    result += id + ": "
  }

  let sources = @graph.edge_sources(edge)
  for i = 0; i < sources.length(); i = i + 1 {
    if i > 0 {
      result += ", "
    }
    result += graph_json_text_ui_shape_name(self.name_provider, sources[i])
  }

  result += " -> "

  let targets = @graph.edge_targets(edge)
  for i = 0; i < targets.length(); i = i + 1 {
    if i > 0 {
      result += ", "
    }
    result += graph_json_text_ui_shape_name(self.name_provider, targets[i])
  }
  result
}

///|
pub fn ElkGraphJsonLabelProvider::image_elk_edge(
  self : ElkGraphJsonLabelProvider,
  edge : @graph.ElkEdge,
) -> String {
  ignore(self)
  ignore(edge)
  "elkedge.gif"
}

///|
pub fn ElkGraphJsonLabelProvider::text_elk_label(
  self : ElkGraphJsonLabelProvider,
  label : @graph.ElkLabel,
) -> String {
  ignore(self)
  let mut result = ""
  let id = @graph.label_identifier(label)
  if !id.is_empty() {
    result += id + ": "
  }
  result += "\"" + @graph.label_text(label) + "\""
  result
}

///|
pub fn ElkGraphJsonLabelProvider::image_elk_label(
  self : ElkGraphJsonLabelProvider,
  label : @graph.ElkLabel,
) -> String {
  ignore(self)
  ignore(label)
  "elklabel.gif"
}
