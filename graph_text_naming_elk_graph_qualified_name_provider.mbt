///|
pub struct ElkGraphQualifiedNameProvider {
  marker : Unit
}

///|
pub fn new_elk_graph_qualified_name_provider() -> ElkGraphQualifiedNameProvider {
  { marker: () }
}

///|
fn graph_text_prepend_name(
  parent_names : Array[String],
  name : String,
) -> Array[String] {
  graph_text_append_name(parent_names, name)
}

///|
fn graph_text_append_name(
  values : Array[String],
  name : String,
) -> Array[String] {
  let result : Array[String] = []
  for value in values {
    result.push(value)
  }
  result.push(name)
  result
}

///|
fn graph_text_reverse_copy(values : Array[String]) -> Array[String] {
  let reversed : Array[String] = []
  let mut idx = values.length()
  while idx > 0 {
    idx -= 1
    reversed.push(values[idx])
  }
  reversed
}

///|
fn graph_text_parent_names_for_node(node : ElkNode) -> Array[String] {
  let names : Array[String] = []
  let mut current = node_parent(node)
  while current is Some(node_value) {
    let id = node_identifier(node_value)
    if id != "" {
      names.push(id)
    }
    current = node_parent(node_value)
  }
  graph_text_reverse_copy(names)
}

///|
fn graph_text_parent_names_for_port(port : ElkPort) -> Array[String] {
  match port_parent(port) {
    Some(node) =>
      graph_text_append_name(
        graph_text_parent_names_for_node(node),
        node_identifier(node),
      )
    None => []
  }
}

///|
fn graph_text_parent_names_for_edge(edge : ElkEdge) -> Array[String] {
  match edge_containing_node(edge) {
    Some(node) =>
      graph_text_append_name(
        graph_text_parent_names_for_node(node),
        node_identifier(node),
      )
    None => []
  }
}

///|
fn graph_text_parent_names_for_label(label : ElkLabel) -> Array[String] {
  match label_parent(label) {
    Some(NodeLabelParent(node)) =>
      graph_text_append_name(
        graph_text_parent_names_for_node(node),
        node_identifier(node),
      )
    Some(PortLabelParent(port)) => {
      let names = graph_text_parent_names_for_port(port)
      graph_text_append_name(names, port_identifier(port))
    }
    Some(EdgeLabelParent(edge)) => {
      let names = graph_text_parent_names_for_edge(edge)
      graph_text_append_name(names, edge_identifier(edge))
    }
    Some(LabelLabelParent(parent_label)) => {
      let names = graph_text_parent_names_for_label(parent_label)
      graph_text_append_name(names, label_identifier(parent_label))
    }
    None => []
  }
}

///|
pub fn ElkGraphQualifiedNameProvider::qualified_name(
  self : ElkGraphQualifiedNameProvider,
  element : GraphTextElement,
) -> Array[String] {
  ignore(self)
  match graph_text_element_identifier(element) {
    Some(name) =>
      match element {
        GraphNode(node) =>
          graph_text_prepend_name(graph_text_parent_names_for_node(node), name)
        GraphPort(port) =>
          graph_text_prepend_name(graph_text_parent_names_for_port(port), name)
        GraphEdge(edge) =>
          graph_text_prepend_name(graph_text_parent_names_for_edge(edge), name)
        GraphLabel(label) =>
          graph_text_prepend_name(
            graph_text_parent_names_for_label(label),
            name,
          )
      }
    None => []
  }
}

///|
pub fn ElkGraphQualifiedNameProvider::qualified_name_for_edge_section(
  self : ElkGraphQualifiedNameProvider,
  section : ElkEdgeSection,
) -> Array[String] {
  ignore(self)
  let id = edge_section_identifier(section)
  if id == "" {
    []
  } else {
    [id]
  }
}
