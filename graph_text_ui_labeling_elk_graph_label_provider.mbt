///|
fn graph_text_ui_join_qualified_name(parts : Array[String]) -> String {
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
fn graph_text_ui_shape_name(
  provider : ElkGraphQualifiedNameProvider,
  shape : ElkConnectableShape,
) -> String {
  match shape {
    NodeShape(node) => {
      let text = graph_text_ui_join_qualified_name(
        provider.qualified_name(GraphNode(node)),
      )
      if text.is_empty() {
        "?"
      } else {
        text
      }
    }
    PortShape(port) => {
      let text = graph_text_ui_join_qualified_name(
        provider.qualified_name(GraphPort(port)),
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
pub struct ElkGraphLabelProvider {
  name_provider : ElkGraphQualifiedNameProvider
}

///|
pub fn new_elk_graph_label_provider(
  name_provider? : ElkGraphQualifiedNameProvider = new_elk_graph_qualified_name_provider(),
) -> ElkGraphLabelProvider {
  { name_provider, }
}

///|
pub fn ElkGraphLabelProvider::image_elk_node(
  self : ElkGraphLabelProvider,
  node : ElkNode,
) -> String {
  ignore(self)
  match node_parent(node) {
    Some(_) => "elknode.gif"
    None => "elkgraph.gif"
  }
}

///|
pub fn ElkGraphLabelProvider::image_elk_port(
  self : ElkGraphLabelProvider,
  port : ElkPort,
) -> String {
  ignore(self)
  ignore(port)
  "elkport.gif"
}

///|
pub fn ElkGraphLabelProvider::text_elk_edge(
  self : ElkGraphLabelProvider,
  edge : ElkEdge,
) -> String {
  let mut result = ""
  let id = edge_identifier(edge)
  if !id.is_empty() {
    result += id + ": "
  }

  let sources = edge_sources(edge)
  for i = 0; i < sources.length(); i = i + 1 {
    if i > 0 {
      result += ", "
    }
    result += graph_text_ui_shape_name(self.name_provider, sources[i])
  }

  result += " -> "

  let targets = edge_targets(edge)
  for i = 0; i < targets.length(); i = i + 1 {
    if i > 0 {
      result += ", "
    }
    result += graph_text_ui_shape_name(self.name_provider, targets[i])
  }
  result
}

///|
pub fn ElkGraphLabelProvider::image_elk_edge(
  self : ElkGraphLabelProvider,
  edge : ElkEdge,
) -> String {
  ignore(self)
  ignore(edge)
  "elkedge.gif"
}

///|
pub fn ElkGraphLabelProvider::text_elk_label(
  self : ElkGraphLabelProvider,
  label : ElkLabel,
) -> String {
  ignore(self)
  let mut result = ""
  let id = label_identifier(label)
  if !id.is_empty() {
    result += id + ": "
  }
  result += "\"" + label_text(label) + "\""
  result
}

///|
pub fn ElkGraphLabelProvider::image_elk_label(
  self : ElkGraphLabelProvider,
  label : ElkLabel,
) -> String {
  ignore(self)
  ignore(label)
  "elklabel.gif"
}
