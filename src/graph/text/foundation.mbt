///|
pub(all) enum GraphTextPropertyKey {
  LayoutOption(@core.LayoutOptionData)
  CustomProperty(String)
}

///|
pub fn graph_text_property_key_id(key : GraphTextPropertyKey) -> String {
  match key {
    LayoutOption(option_data) => option_data.get_id()
    CustomProperty(id) => id
  }
}

///|
pub fn graph_text_property_key_group(key : GraphTextPropertyKey) -> String {
  match key {
    LayoutOption(option_data) => option_data.get_group()
    CustomProperty(_) => ""
  }
}

///|
pub fn graph_text_property_key_to_layout_option(
  key : GraphTextPropertyKey,
) -> @core.LayoutOptionData? {
  match key {
    LayoutOption(option_data) => Some(option_data)
    CustomProperty(id) => @core.layout_meta_data_service_get_option_data_opt(id)
  }
}

///|
pub(all) enum GraphTextPropertyValue {
  NullValue
  StringValue(String)
  NumberValue(Double)
  BooleanValue(Bool)
  ProxyValue(String)
} derive(Show)

///|
pub fn graph_text_property_value_to_string(
  value : GraphTextPropertyValue,
) -> String {
  match value {
    NullValue => "null"
    StringValue(text) => text
    NumberValue(number) =>
      if number.to_int().to_double() == number {
        number.to_int().to_string()
      } else {
        number.to_string()
      }
    BooleanValue(flag) => if flag { "true" } else { "false" }
    ProxyValue(text) => text
  }
}

///|
pub struct GraphTextPropertyAssignment {
  key : GraphTextPropertyKey
  value : GraphTextPropertyValue
}

///|
pub fn new_graph_text_property_assignment(
  key : GraphTextPropertyKey,
  value : GraphTextPropertyValue,
) -> GraphTextPropertyAssignment {
  { key, value }
}

///|
pub type GraphTextIssueSeverity = Int

///|
pub let graph_text_issue_error : GraphTextIssueSeverity = 1

///|
pub let graph_text_issue_warning : GraphTextIssueSeverity = 2

///|
pub struct GraphTextValidationIssue {
  message : String
  feature : String
  severity : GraphTextIssueSeverity
  code : String?
}

///|
pub fn new_graph_text_validation_issue(
  message : String,
  feature : String,
  severity : GraphTextIssueSeverity,
  code? : String? = None,
) -> GraphTextValidationIssue {
  { message, feature, severity, code }
}

///|
pub(all) enum GraphTextListTransient {
  ListTransientYes
  ListTransientNo
} derive(Show)

///|
pub(all) enum GraphTextElement {
  GraphNode(@graph.ElkNode)
  GraphPort(@graph.ElkPort)
  GraphEdge(@graph.ElkEdge)
  GraphLabel(@graph.ElkLabel)
}

///|
pub fn graph_text_element_identifier(element : GraphTextElement) -> String? {
  match element {
    GraphNode(node) =>
      if @graph.node_identifier(node) == "" {
        None
      } else {
        Some(@graph.node_identifier(node))
      }
    GraphPort(port) =>
      if @graph.port_identifier(port) == "" {
        None
      } else {
        Some(@graph.port_identifier(port))
      }
    GraphEdge(edge) =>
      if @graph.edge_identifier(edge) == "" {
        None
      } else {
        Some(@graph.edge_identifier(edge))
      }
    GraphLabel(label) =>
      if @graph.label_identifier(label) == "" {
        None
      } else {
        Some(@graph.label_identifier(label))
      }
  }
}

///|
pub(all) enum GraphTextLabelOwner {
  LabelOnNode(@graph.ElkNode)
  LabelOnPort(@graph.ElkPort)
  LabelOnEdge(@graph.ElkEdge)
  LabelOnLabel(@graph.ElkLabel)
}

///|
pub fn graph_text_label_owner_to_parent(
  owner : GraphTextLabelOwner,
) -> @graph.ElkLabelParent {
  match owner {
    LabelOnNode(node) => @graph.make_node_label_parent(node)
    LabelOnPort(port) => @graph.make_port_label_parent(port)
    LabelOnEdge(edge) => @graph.make_edge_label_parent(edge)
    LabelOnLabel(label) => @graph.make_label_label_parent(label)
  }
}

///|
pub(all) enum GraphTextShape {
  ShapeNode(@graph.ElkNode)
  ShapePort(@graph.ElkPort)
  ShapeLabel(@graph.ElkLabel)
}

///|
pub fn graph_text_shape_set_location(
  shape : GraphTextShape,
  x : Double,
  y : Double,
) -> Unit {
  match shape {
    ShapeNode(node) => @graph.node_set_location(node, x, y)
    ShapePort(port) => @graph.port_set_location(port, x, y)
    ShapeLabel(label) => @graph.label_set_location(label, x, y)
  }
}

///|
pub fn graph_text_shape_set_size(
  shape : GraphTextShape,
  width : Double,
  height : Double,
) -> Unit {
  match shape {
    ShapeNode(node) => @graph.node_set_dimensions(node, width, height)
    ShapePort(port) => @graph.port_set_dimensions(port, width, height)
    ShapeLabel(label) => @graph.label_set_dimensions(label, width, height)
  }
}
