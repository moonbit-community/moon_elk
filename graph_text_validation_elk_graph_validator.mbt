///|
pub let graph_text_feature_property_key : String = "ELK_PROPERTY_TO_VALUE_MAP_ENTRY__KEY"

///|
pub let graph_text_feature_property_value : String = "ELK_PROPERTY_TO_VALUE_MAP_ENTRY__VALUE"

///|
pub let graph_text_feature_graph_identifier : String = "ELK_GRAPH_ELEMENT__IDENTIFIER"

///|
pub let graph_text_feature_edge_section_identifier : String = "ELK_EDGE_SECTION__IDENTIFIER"

///|
pub let graph_text_feature_edge_section_incoming_shape : String = "ELK_EDGE_SECTION__INCOMING_SHAPE"

///|
pub let graph_text_feature_edge_section_outgoing_shape : String = "ELK_EDGE_SECTION__OUTGOING_SHAPE"

///|
pub struct ElkGraphValidator {
  base : AbstractElkGraphValidator
  layout_option_validator : LayoutOptionValidator
  value_converter : PropertyValueValueConverter
}

///|
pub fn new_elk_graph_validator(
  base? : AbstractElkGraphValidator = new_abstract_elk_graph_validator(),
  layout_option_validator? : LayoutOptionValidator = new_layout_option_validator(),
  value_converter? : PropertyValueValueConverter = new_property_value_value_converter(),
) -> ElkGraphValidator {
  { base, layout_option_validator, value_converter }
}

///|
pub fn ElkGraphValidator::get_epackages(
  self : ElkGraphValidator,
) -> Array[String] {
  self.base.get_epackages()
}

///|
fn graph_text_targets_contain(
  targets : Array[LayoutOptionTarget],
  target : LayoutOptionTarget,
) -> Bool {
  for value in targets {
    if graph_text_layout_option_target_eq(value, target) {
      return true
    }
  }
  false
}

///|
fn graph_text_layout_option_target_eq(
  left : LayoutOptionTarget,
  right : LayoutOptionTarget,
) -> Bool {
  match (left, right) {
    (NodesTarget, NodesTarget) => true
    (EdgesTarget, EdgesTarget) => true
    (PortsTarget, PortsTarget) => true
    (LabelsTarget, LabelsTarget) => true
    (ParentsTarget, ParentsTarget) => true
    _ => false
  }
}

///|
fn graph_text_validator_option_target_message(
  target : LayoutOptionTarget,
) -> String {
  target.to_string().to_lower()
}

///|
fn graph_text_validator_check_option_target(
  option : LayoutOptionData,
  target_types : Array[LayoutOptionTarget],
) -> GraphTextValidationIssue? {
  for target in target_types {
    if graph_text_targets_contain(option.get_targets(), target) {
      return None
    }
  }
  let target_name = if target_types.length() == 0 {
    "elements"
  } else {
    graph_text_validator_option_target_message(target_types[0])
  }
  Some(
    new_graph_text_validation_issue(
      "The layout option '" +
      option.get_id() +
      "' is not applicable to " +
      target_name +
      ".",
      graph_text_feature_property_key,
      graph_text_issue_warning,
      code=Some(graph_text_option_not_applicable),
    ),
  )
}

///|
fn graph_text_validator_issue_from_graph_issue(
  issue : GraphIssue,
) -> GraphTextValidationIssue {
  let severity = if issue.get_severity() == issue_error {
    graph_text_issue_error
  } else {
    graph_text_issue_warning
  }
  new_graph_text_validation_issue(
    issue.get_message(),
    graph_text_feature_property_value,
    severity,
  )
}

///|
fn graph_text_validator_algorithm_for_element(
  element : GraphTextElement,
) -> LayoutAlgorithmData? {
  elk_graph_text_util_get_algorithm(element)
}

///|
fn graph_text_validator_check_algorithm_support(
  option : LayoutOptionData,
  element : GraphTextElement,
) -> GraphTextValidationIssue? {
  if option.get_id() == algorithm.get_id() {
    return None
  }
  match graph_text_validator_algorithm_for_element(element) {
    Some(algorithm_data) =>
      if !algorithm_data.knows_option(option.get_id()) {
        Some(
          new_graph_text_validation_issue(
            "The algorithm '" +
            algorithm_data.get_id() +
            "' does not support the option '" +
            option.get_id() +
            "'.",
            graph_text_feature_property_key,
            graph_text_issue_warning,
          ),
        )
      } else {
        None
      }
    None => None
  }
}

///|
pub fn ElkGraphValidator::check_property_key(
  self : ElkGraphValidator,
  entry : GraphTextPropertyAssignment,
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  match graph_text_property_key_to_layout_option(entry.key) {
    Some(_) => []
    None =>
      [
        new_graph_text_validation_issue(
          "'" +
          graph_text_property_key_id(entry.key) +
          "' is not a layout option.",
          graph_text_feature_property_key,
          graph_text_issue_warning,
        ),
      ]
  }
}

///|
fn graph_text_validator_effective_value(
  value_converter : PropertyValueValueConverter,
  entry : GraphTextPropertyAssignment,
) -> GraphTextPropertyValue {
  match entry.value {
    ProxyValue(proxy_value) =>
      value_converter.to_value(proxy_value, property_key=Some(entry.key))
    _ => entry.value
  }
}

///|
fn graph_text_validator_check_property_target(
  option : LayoutOptionData,
  container : GraphTextElement,
) -> GraphTextValidationIssue? {
  match container {
    GraphNode(_) =>
      graph_text_validator_check_option_target(option, [
        NodesTarget,
        ParentsTarget,
      ])
    GraphEdge(_) =>
      graph_text_validator_check_option_target(option, [EdgesTarget])
    GraphPort(_) =>
      graph_text_validator_check_option_target(option, [PortsTarget])
    GraphLabel(_) =>
      graph_text_validator_check_option_target(option, [LabelsTarget])
  }
}

///|
fn graph_text_validator_option_context_node(
  container : GraphTextElement,
) -> ElkNode? {
  match container {
    GraphNode(node) => Some(node)
    _ => None
  }
}

///|
pub fn ElkGraphValidator::check_property_value(
  self : ElkGraphValidator,
  entry : GraphTextPropertyAssignment,
  container : GraphTextElement,
) -> Array[GraphTextValidationIssue] {
  let issues : Array[GraphTextValidationIssue] = []
  match graph_text_property_key_to_layout_option(entry.key) {
    Some(option) => {
      match graph_text_validator_check_property_target(option, container) {
        Some(issue) => issues.push(issue)
        None => ()
      }
      match graph_text_validator_check_algorithm_support(option, container) {
        Some(issue) => issues.push(issue)
        None => ()
      }
      let value = graph_text_validator_effective_value(
        self.value_converter,
        entry,
      )
      let text_value = graph_text_property_value_to_string(value)
      for
        issue in self.layout_option_validator.check_property(option, text_value) {
        issues.push(graph_text_validator_issue_from_graph_issue(issue))
      }
      if option.get_id() == algorithm.get_id() {
        match
          layout_meta_data_service_get_algorithm_data_by_suffix(text_value) {
          Some(_) => ()
          None =>
            issues.push(
              new_graph_text_validation_issue(
                "No layout algorithm with identifier '" +
                text_value +
                "' can be found.",
                graph_text_feature_property_value,
                graph_text_issue_error,
              ),
            )
        }
      }
    }
    None => ()
  }
  ignore(graph_text_validator_option_context_node(container))
  issues
}

///|
pub fn ElkGraphValidator::check_unique_properties(
  self : ElkGraphValidator,
  properties : Array[GraphTextPropertyAssignment],
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  let issues : Array[GraphTextValidationIssue] = []
  let used : Map[String, Int] = {}
  for property in properties {
    let key_id = graph_text_property_key_id(property.key)
    match used.get(key_id) {
      None => used[key_id] = 1
      Some(state) =>
        if state == 1 {
          issues.push(
            new_graph_text_validation_issue(
              "Property is already assigned.", graph_text_feature_property_key, graph_text_issue_error,
            ),
          )
          issues.push(
            new_graph_text_validation_issue(
              "Property is already assigned.", graph_text_feature_property_key, graph_text_issue_error,
            ),
          )
          used[key_id] = 2
        } else {
          issues.push(
            new_graph_text_validation_issue(
              "Property is already assigned.", graph_text_feature_property_key, graph_text_issue_error,
            ),
          )
        }
    }
  }
  issues
}

///|
fn graph_text_validator_report_duplicate_name(
  issues : Array[GraphTextValidationIssue],
  feature : String,
) -> Unit {
  issues.push(
    new_graph_text_validation_issue(
      "Identifier is already used.", feature, graph_text_issue_error,
    ),
  )
}

///|
pub fn ElkGraphValidator::check_unique_names_for_node(
  self : ElkGraphValidator,
  node : ElkNode,
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  let used : Map[String, Int] = {}
  let issues : Array[GraphTextValidationIssue] = []
  for child in node_children(node) {
    let id = node_identifier(child)
    if id != "" {
      match used.get(id) {
        None => used[id] = 1
        Some(state) =>
          if state == 1 {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            used[id] = 2
          } else {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
          }
      }
    }
  }
  for port in node_ports(node) {
    let id = port_identifier(port)
    if id != "" {
      match used.get(id) {
        None => used[id] = 1
        Some(state) =>
          if state == 1 {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            used[id] = 2
          } else {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
          }
      }
    }
  }
  for edge in node_contained_edges(node) {
    let id = edge_identifier(edge)
    if id != "" {
      match used.get(id) {
        None => used[id] = 1
        Some(state) =>
          if state == 1 {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            used[id] = 2
          } else {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
          }
      }
    }
  }
  for label in node_labels(node) {
    let id = label_identifier(label)
    if id != "" {
      match used.get(id) {
        None => used[id] = 1
        Some(state) =>
          if state == 1 {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
            used[id] = 2
          } else {
            graph_text_validator_report_duplicate_name(
              issues, graph_text_feature_graph_identifier,
            )
          }
      }
    }
  }
  issues
}

///|
fn graph_text_validator_find_parent_edge(section : ElkEdgeSection) -> ElkEdge? {
  for edge in all_edges() {
    for candidate in edge_sections(edge) {
      if candidate == section {
        return Some(edge)
      }
    }
  }
  None
}

///|
fn graph_text_validator_shapes_contains(
  shapes : Array[ElkConnectableShape],
  target : ElkConnectableShape,
) -> Bool {
  for shape in shapes {
    if graph_text_shape_eq(shape, target) {
      return true
    }
  }
  false
}

///|
fn graph_text_shape_eq(
  left : ElkConnectableShape,
  right : ElkConnectableShape,
) -> Bool {
  match (left, right) {
    (NodeShape(left_node), NodeShape(right_node)) => left_node == right_node
    (PortShape(left_port), PortShape(right_port)) => left_port == right_port
    _ => false
  }
}

///|
fn graph_text_validator_shape_description(
  shape : ElkConnectableShape,
) -> String {
  match shape {
    NodeShape(node) => "ElkNode " + node_identifier(node)
    PortShape(port) => "ElkPort " + port_identifier(port)
  }
}

///|
pub fn ElkGraphValidator::check_edge_container(
  self : ElkGraphValidator,
  edge : ElkEdge,
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  if edge_sources(edge).length() == 0 && edge_targets(edge).length() == 0 {
    return []
  }
  let issues : Array[GraphTextValidationIssue] = []
  let best_container = find_best_edge_containment(Some(edge))
  match best_container {
    Some(best) =>
      if edge_containing_node(edge) != Some(best) {
        match node_parent(best) {
          None =>
            issues.push(
              new_graph_text_validation_issue(
                "This edge should be declared in the root node of this graph.", "ELK_EDGE__CONTAINING_NODE",
                graph_text_issue_warning,
              ),
            )
          Some(_) =>
            issues.push(
              new_graph_text_validation_issue(
                "This edge should be declared in node " +
                node_identifier(best) +
                ".",
                "ELK_EDGE__CONTAINING_NODE",
                graph_text_issue_warning,
              ),
            )
        }
      }
    None => ()
  }
  issues
}

///|
pub fn ElkGraphValidator::check_edge_section(
  self : ElkGraphValidator,
  edge_section : ElkEdgeSection,
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  let issues : Array[GraphTextValidationIssue] = []
  match graph_text_validator_find_parent_edge(edge_section) {
    Some(edge) => {
      match edge_section_incoming_shape(edge_section) {
        Some(incoming_shape) => {
          if !graph_text_validator_shapes_contains(
              edge_sources(edge),
              incoming_shape,
            ) {
            issues.push(
              new_graph_text_validation_issue(
                "The " +
                graph_text_validator_shape_description(incoming_shape) +
                " is not a source of this edge.",
                graph_text_feature_edge_section_incoming_shape,
                graph_text_issue_error,
              ),
            )
          }
          if edge_section_incoming_sections(edge_section).length() > 0 {
            issues.push(
              new_graph_text_validation_issue(
                "An edge section cannot be connected to an incoming shape and other sections at the same time.",
                graph_text_feature_edge_section_incoming_shape, graph_text_issue_error,
              ),
            )
          }
        }
        None => ()
      }
      match edge_section_outgoing_shape(edge_section) {
        Some(outgoing_shape) => {
          if !graph_text_validator_shapes_contains(
              edge_targets(edge),
              outgoing_shape,
            ) {
            issues.push(
              new_graph_text_validation_issue(
                "The " +
                graph_text_validator_shape_description(outgoing_shape) +
                " is not a target of this edge.",
                graph_text_feature_edge_section_outgoing_shape,
                graph_text_issue_error,
              ),
            )
          }
          if edge_section_outgoing_sections(edge_section).length() > 0 {
            issues.push(
              new_graph_text_validation_issue(
                "An edge section cannot be connected to an outgoing shape and other sections at the same time.",
                graph_text_feature_edge_section_outgoing_shape, graph_text_issue_error,
              ),
            )
          }
        }
        None => ()
      }
    }
    None => ()
  }
  issues
}

///|
pub fn ElkGraphValidator::check_unique_section_names(
  self : ElkGraphValidator,
  edge : ElkEdge,
) -> Array[GraphTextValidationIssue] {
  ignore(self)
  let used : Map[String, Int] = {}
  let issues : Array[GraphTextValidationIssue] = []
  for section in edge_sections(edge) {
    let id = edge_section_identifier(section)
    if id == "" {
      continue
    }
    match used.get(id) {
      None => used[id] = 1
      Some(state) =>
        if state == 1 {
          graph_text_validator_report_duplicate_name(
            issues, graph_text_feature_edge_section_identifier,
          )
          graph_text_validator_report_duplicate_name(
            issues, graph_text_feature_edge_section_identifier,
          )
          used[id] = 2
        } else {
          graph_text_validator_report_duplicate_name(
            issues, graph_text_feature_edge_section_identifier,
          )
        }
    }
  }
  issues
}
