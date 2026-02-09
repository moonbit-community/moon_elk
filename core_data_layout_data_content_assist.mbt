///|
pub struct LayoutDataProposal[T] {
  proposal : String
  label : String?
  data : T
}

///|
pub fn[T] new_layout_data_proposal(
  proposal : String,
  data : T,
  label? : String? = None,
) -> LayoutDataProposal[T] {
  { proposal, label, data }
}

///|
pub fn[T] LayoutDataProposal::get_proposal(
  self : LayoutDataProposal[T],
) -> String {
  self.proposal
}

///|
pub fn[T] LayoutDataProposal::get_label(
  self : LayoutDataProposal[T],
) -> String? {
  self.label
}

///|
pub fn[T] LayoutDataProposal::get_data(self : LayoutDataProposal[T]) -> T {
  self.data
}

///|
pub enum LayoutDataContentAssistElement {
  NodeLayoutDataElement(ElkNode)
  EdgeLayoutDataElement(ElkEdge)
  PortLayoutDataElement(ElkPort)
  LabelLayoutDataElement(ElkLabel)
}

///|
fn target_equals(left : LayoutOptionTarget, right : LayoutOptionTarget) -> Bool {
  match (left, right) {
    (ParentsTarget, ParentsTarget) => true
    (NodesTarget, NodesTarget) => true
    (EdgesTarget, EdgesTarget) => true
    (PortsTarget, PortsTarget) => true
    (LabelsTarget, LabelsTarget) => true
    _ => false
  }
}

///|
fn target_sets_intersect(
  left : Array[LayoutOptionTarget],
  right : Array[LayoutOptionTarget],
) -> Bool {
  if left.is_empty() {
    return true
  }
  for left_target in left {
    for right_target in right {
      if target_equals(left_target, right_target) {
        return true
      }
    }
  }
  false
}

///|
fn is_hidden_visibility(visibility : LayoutOptionVisibility) -> Bool {
  match visibility {
    HiddenOption => true
    _ => false
  }
}

///|
fn split_dotted(text : String) -> Array[String] {
  if text.is_empty() {
    return []
  }
  let parts = []
  for part in text.split(".") {
    if !part.is_empty() {
      parts.push(part.to_string())
    }
  }
  parts
}

///|
fn join_dotted(parts : Array[String], start : Int) -> String {
  let mut result = ""
  for i = start; i < parts.length(); i = i + 1 {
    if i > start {
      result += "."
    }
    result += parts[i]
  }
  result
}

///|
fn sub_parts(parts : Array[String], start : Int) -> Array[String] {
  let result = []
  for i = start; i < parts.length(); i = i + 1 {
    result.push(parts[i])
  }
  result
}

///|
fn count_group_dots(group : String) -> Int {
  if group.is_empty() {
    return 0
  }
  split_dotted(group).length() - 1
}

///|
fn prefix_matches_parts(
  parts : Array[String],
  prefix_parts : Array[String],
) -> Bool {
  if prefix_parts.is_empty() {
    return true
  }
  if parts.length() < prefix_parts.length() {
    return false
  }
  let upper = parts.length() - prefix_parts.length() + 1
  for i = 0; i < upper; i = i + 1 {
    let mut matches = true
    for j = 0; j < prefix_parts.length(); j = j + 1 {
      if !parts[i + j].has_prefix(prefix_parts[j]) {
        matches = false
      }
    }
    if matches {
      return true
    }
  }
  false
}

///|
fn proposal_for_layout_option(
  option_data : LayoutOptionData,
  prefix : String,
) -> LayoutDataProposal[LayoutOptionData]? {
  let matches_name = !prefix.is_empty() &&
    option_data.get_name().to_lower().contains(prefix.to_lower())
  let id_parts = split_dotted(option_data.get_id())
  if id_parts.is_empty() {
    return None
  }
  let prefix_parts = if matches_name { [] } else { split_dotted(prefix) }
  let mut start = id_parts.length() - 1
  if !option_data.get_group().is_empty() {
    start = start - 1
    start = start - count_group_dots(option_data.get_group())
  }
  if start < 0 {
    start = 0
  }
  let mut i = start
  while i >= 0 {
    let suffix = join_dotted(id_parts, i)
    if layout_meta_data_service_get_option_data_by_suffix(suffix) is Some(_) {
      let suffix_parts = sub_parts(id_parts, i)
      if matches_name || prefix_matches_parts(suffix_parts, prefix_parts) {
        return Some(new_layout_data_proposal(suffix, option_data))
      }
    }
    i = i - 1
  }
  None
}

///|
fn proposal_for_layout_algorithm(
  algorithm_data : LayoutAlgorithmData,
  prefix : String,
) -> LayoutDataProposal[LayoutAlgorithmData]? {
  let id_parts = split_dotted(algorithm_data.get_id())
  if id_parts.is_empty() {
    return None
  }
  let prefix_parts = split_dotted(prefix)
  let mut i = id_parts.length() - 1
  while i >= 0 {
    let suffix = join_dotted(id_parts, i)
    if layout_meta_data_service_get_algorithm_data_by_suffix(suffix) is Some(_) {
      let suffix_parts = sub_parts(id_parts, i)
      if prefix_matches_parts(suffix_parts, prefix_parts) {
        return Some(new_layout_data_proposal(suffix, algorithm_data))
      }
    }
    i = i - 1
  }
  None
}

///|
fn element_target_types(
  element : LayoutDataContentAssistElement,
) -> Array[LayoutOptionTarget] {
  match element {
    NodeLayoutDataElement(node) =>
      if node_children(node).is_empty() {
        [NodesTarget]
      } else {
        [NodesTarget, ParentsTarget]
      }
    EdgeLayoutDataElement(_) => [EdgesTarget]
    PortLayoutDataElement(_) => [PortsTarget]
    LabelLayoutDataElement(_) => [LabelsTarget]
  }
}

///|
fn element_option_string_value(
  element : LayoutDataContentAssistElement,
  option_id : String,
) -> String? {
  match element {
    NodeLayoutDataElement(node) =>
      node_layout_option_string_value(node, option_id)
    EdgeLayoutDataElement(edge) =>
      edge_layout_option_string_value(edge, option_id)
    PortLayoutDataElement(port) =>
      port_layout_option_string_value(port, option_id)
    LabelLayoutDataElement(label) =>
      label_layout_option_string_value(label, option_id)
  }
}

///|
fn relevant_node_for_port(port : ElkPort) -> ElkNode? {
  match port_parent(port) {
    Some(parent) =>
      match node_parent(parent) {
        Some(grandparent) => Some(grandparent)
        None => Some(parent)
      }
    None => None
  }
}

///|
fn relevant_node_for_label(label : ElkLabel) -> ElkNode? {
  match label_parent(label) {
    Some(NodeLabelParent(node)) =>
      match node_parent(node) {
        Some(parent) => Some(parent)
        None => Some(node)
      }
    Some(EdgeLabelParent(edge)) => edge_containing_node(edge)
    Some(PortLabelParent(port)) => relevant_node_for_port(port)
    Some(LabelLabelParent(parent_label)) =>
      relevant_node_for_label(parent_label)
    None => None
  }
}

///|
fn relevant_node_for_element(
  element : LayoutDataContentAssistElement,
) -> ElkNode? {
  match element {
    NodeLayoutDataElement(node) =>
      match node_parent(node) {
        Some(parent) => Some(parent)
        None => Some(node)
      }
    EdgeLayoutDataElement(edge) => edge_containing_node(edge)
    PortLayoutDataElement(port) => relevant_node_for_port(port)
    LabelLayoutDataElement(label) => relevant_node_for_label(label)
  }
}

///|
fn algorithm_for_element(
  element : LayoutDataContentAssistElement,
) -> LayoutAlgorithmData? {
  match relevant_node_for_element(element) {
    Some(node) =>
      match node_layout_option_string_value(node, algorithm.get_id()) {
        Some(algorithm_id) =>
          if algorithm_id.trim().is_empty() {
            None
          } else {
            layout_meta_data_service_get_algorithm_data_by_suffix(algorithm_id)
          }
        None => None
      }
    None => None
  }
}

///|
pub fn layout_data_content_assist_get_layout_option_proposals_for_element(
  element : LayoutDataContentAssistElement,
  prefix : String,
) -> Array[LayoutDataProposal[LayoutOptionData]] {
  let target_types = element_target_types(element)
  let responsible_algorithm = algorithm_for_element(element)
  let proposals = []
  for option_data in layout_meta_data_service_option_data_values() {
    if is_hidden_visibility(option_data.get_visibility()) {
      continue
    }
    if !target_sets_intersect(option_data.get_targets(), target_types) {
      continue
    }
    match responsible_algorithm {
      Some(algorithm_data) =>
        if !algorithm_data.knows_option(option_data.get_id()) &&
          option_data.get_id() != algorithm.get_id() {
          continue
        }
      None => ()
    }
    if element_option_string_value(element, option_data.get_id()) is Some(_) {
      continue
    }
    match proposal_for_layout_option(option_data, prefix) {
      Some(proposal) => proposals.push(proposal)
      None => ()
    }
  }
  proposals
}

///|
pub fn layout_data_content_assist_get_layout_option_proposals(
  element : ElkNode,
  prefix : String,
) -> Array[LayoutDataProposal[LayoutOptionData]] {
  layout_data_content_assist_get_layout_option_proposals_for_element(
    NodeLayoutDataElement(element),
    prefix,
  )
}

///|
pub fn layout_data_content_assist_get_layout_option_proposals_for_edge(
  element : ElkEdge,
  prefix : String,
) -> Array[LayoutDataProposal[LayoutOptionData]] {
  layout_data_content_assist_get_layout_option_proposals_for_element(
    EdgeLayoutDataElement(element),
    prefix,
  )
}

///|
pub fn layout_data_content_assist_get_layout_option_proposals_for_port(
  element : ElkPort,
  prefix : String,
) -> Array[LayoutDataProposal[LayoutOptionData]] {
  layout_data_content_assist_get_layout_option_proposals_for_element(
    PortLayoutDataElement(element),
    prefix,
  )
}

///|
pub fn layout_data_content_assist_get_layout_option_proposals_for_label(
  element : ElkLabel,
  prefix : String,
) -> Array[LayoutDataProposal[LayoutOptionData]] {
  layout_data_content_assist_get_layout_option_proposals_for_element(
    LabelLayoutDataElement(element),
    prefix,
  )
}

///|
pub fn layout_data_content_assist_get_layout_algorithm_proposals(
  prefix : String,
) -> Array[LayoutDataProposal[LayoutAlgorithmData]] {
  let proposals = []
  for algorithm_data in layout_meta_data_service_algorithm_data_values() {
    match proposal_for_layout_algorithm(algorithm_data, prefix) {
      Some(proposal) => proposals.push(proposal)
      None => ()
    }
  }
  proposals
}
