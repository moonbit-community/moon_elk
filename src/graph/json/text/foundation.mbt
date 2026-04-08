///|
pub(all) enum GraphJsonTextPropertyKey {
  GraphJsonTextLayoutOption(@core.LayoutOptionData)
  GraphJsonTextCustomProperty(String)
}

///|
pub fn graph_json_text_property_key_id(
  key : GraphJsonTextPropertyKey,
) -> String {
  match key {
    GraphJsonTextLayoutOption(option_data) => option_data.get_id()
    GraphJsonTextCustomProperty(id) => id
  }
}

///|
pub fn graph_json_text_property_key_group(
  key : GraphJsonTextPropertyKey,
) -> String {
  match key {
    GraphJsonTextLayoutOption(option_data) => option_data.get_group()
    GraphJsonTextCustomProperty(_) => ""
  }
}

///|
pub fn graph_json_text_property_key_to_layout_option(
  key : GraphJsonTextPropertyKey,
) -> @core.LayoutOptionData? {
  match key {
    GraphJsonTextLayoutOption(option_data) => Some(option_data)
    GraphJsonTextCustomProperty(id) =>
      @core.layout_meta_data_service_get_option_data_opt(id)
  }
}

///|
pub(all) enum GraphJsonTextPropertyValue {
  GraphJsonTextNullValue
  GraphJsonTextStringValue(String)
  GraphJsonTextNumberValue(Double)
  GraphJsonTextBooleanValue(Bool)
  GraphJsonTextProxyValue(String)
} derive(Debug)

///|
pub impl Show for GraphJsonTextPropertyValue with output(self, logger) {
  logger.write_string(to_repr(self).to_string())
}

///|
pub fn graph_json_text_property_value_to_string(
  value : GraphJsonTextPropertyValue,
) -> String {
  match value {
    GraphJsonTextNullValue => "null"
    GraphJsonTextStringValue(text) => text
    GraphJsonTextNumberValue(number) =>
      if number.to_int().to_double() == number {
        number.to_int().to_string()
      } else {
        number.to_string()
      }
    GraphJsonTextBooleanValue(flag) => if flag { "true" } else { "false" }
    GraphJsonTextProxyValue(text) => text
  }
}

///|
pub struct GraphJsonTextPropertyAssignment {
  key : GraphJsonTextPropertyKey
  value : GraphJsonTextPropertyValue
}

///|
pub fn new_graph_json_text_property_assignment(
  key : GraphJsonTextPropertyKey,
  value : GraphJsonTextPropertyValue,
) -> GraphJsonTextPropertyAssignment {
  { key, value }
}

///|
pub type GraphJsonTextIssueSeverity = Int

///|
pub let graph_json_text_issue_error : GraphJsonTextIssueSeverity = 1

///|
pub let graph_json_text_issue_warning : GraphJsonTextIssueSeverity = 2

///|
pub struct GraphJsonTextValidationIssue {
  message : String
  feature : String
  severity : GraphJsonTextIssueSeverity
  code : String?
}

///|
pub fn new_graph_json_text_validation_issue(
  message : String,
  feature : String,
  severity : GraphJsonTextIssueSeverity,
  code? : String? = None,
) -> GraphJsonTextValidationIssue {
  { message, feature, severity, code }
}

///|
pub(all) enum GraphJsonTextListTransient {
  GraphJsonTextListTransientYes
  GraphJsonTextListTransientNo
} derive(Debug)

///|
pub impl Show for GraphJsonTextListTransient with output(self, logger) {
  logger.write_string(to_repr(self).to_string())
}

///|
pub(all) enum GraphJsonTextElement {
  GraphJsonTextNode(@graph.ElkNode)
  GraphJsonTextPort(@graph.ElkPort)
  GraphJsonTextEdge(@graph.ElkEdge)
  GraphJsonTextLabel(@graph.ElkLabel)
}

///|
pub fn graph_json_text_element_identifier(
  element : GraphJsonTextElement,
) -> String? {
  match element {
    GraphJsonTextNode(node) =>
      if @graph.node_identifier(node) == "" {
        None
      } else {
        Some(@graph.node_identifier(node))
      }
    GraphJsonTextPort(port) =>
      if @graph.port_identifier(port) == "" {
        None
      } else {
        Some(@graph.port_identifier(port))
      }
    GraphJsonTextEdge(edge) =>
      if @graph.edge_identifier(edge) == "" {
        None
      } else {
        Some(@graph.edge_identifier(edge))
      }
    GraphJsonTextLabel(label) =>
      if @graph.label_identifier(label) == "" {
        None
      } else {
        Some(@graph.label_identifier(label))
      }
  }
}

///|
pub(all) enum GraphJsonTextLabelOwner {
  GraphJsonTextLabelOnNode(@graph.ElkNode)
  GraphJsonTextLabelOnPort(@graph.ElkPort)
  GraphJsonTextLabelOnEdge(@graph.ElkEdge)
  GraphJsonTextLabelOnLabel(@graph.ElkLabel)
}

///|
pub fn graph_json_text_label_owner_to_parent(
  owner : GraphJsonTextLabelOwner,
) -> @graph.ElkLabelParent {
  match owner {
    GraphJsonTextLabelOnNode(node) => @graph.make_node_label_parent(node)
    GraphJsonTextLabelOnPort(port) => @graph.make_port_label_parent(port)
    GraphJsonTextLabelOnEdge(edge) => @graph.make_edge_label_parent(edge)
    GraphJsonTextLabelOnLabel(label) => @graph.make_label_label_parent(label)
  }
}

///|
pub(all) enum GraphJsonTextShape {
  GraphJsonTextShapeNode(@graph.ElkNode)
  GraphJsonTextShapePort(@graph.ElkPort)
  GraphJsonTextShapeLabel(@graph.ElkLabel)
}

///|
pub fn graph_json_text_shape_set_location(
  shape : GraphJsonTextShape,
  x : Double,
  y : Double,
) -> Unit {
  match shape {
    GraphJsonTextShapeNode(node) => @graph.node_set_location(node, x, y)
    GraphJsonTextShapePort(port) => @graph.port_set_location(port, x, y)
    GraphJsonTextShapeLabel(label) => @graph.label_set_location(label, x, y)
  }
}

///|
pub fn graph_json_text_shape_set_size(
  shape : GraphJsonTextShape,
  width : Double,
  height : Double,
) -> Unit {
  match shape {
    GraphJsonTextShapeNode(node) =>
      @graph.node_set_dimensions(node, width, height)
    GraphJsonTextShapePort(port) =>
      @graph.port_set_dimensions(port, width, height)
    GraphJsonTextShapeLabel(label) =>
      @graph.label_set_dimensions(label, width, height)
  }
}
