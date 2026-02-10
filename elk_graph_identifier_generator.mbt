///|
pub struct GraphIdentifierGenerator {
  graph : ElkNode
  validate : Bool
  generate : Bool
  unique : Bool
}

///|
priv enum GraphIdentifierElementType {
  NodeElement
  PortElement
  EdgeElement
  EdgeSectionElement
  LabelElement
}

///|
priv struct GraphIdentifierState {
  current_ids : Array[Int]
  existing_identifiers : Map[String, Bool]
}

///|
pub fn graph_identifier_generator_for_graph(
  graph : ElkNode,
) -> GraphIdentifierGenerator {
  checked_node(graph)
  { graph, validate: false, generate: false, unique: false }
}

///|
pub fn GraphIdentifierGenerator::assert_valid(
  self : GraphIdentifierGenerator,
) -> GraphIdentifierGenerator {
  {
    graph: self.graph,
    validate: true,
    generate: self.generate,
    unique: self.unique,
  }
}

///|
pub fn GraphIdentifierGenerator::assert_exists(
  self : GraphIdentifierGenerator,
) -> GraphIdentifierGenerator {
  {
    graph: self.graph,
    validate: self.validate,
    generate: true,
    unique: self.unique,
  }
}

///|
pub fn GraphIdentifierGenerator::assert_unique(
  self : GraphIdentifierGenerator,
) -> GraphIdentifierGenerator {
  {
    graph: self.graph,
    validate: self.validate,
    generate: self.generate,
    unique: true,
  }
}

///|
pub fn GraphIdentifierGenerator::execute(
  self : GraphIdentifierGenerator,
) -> Unit {
  if self.validate {
    validate_node_identifiers(self.graph)
  }
  if self.generate {
    let state = new_graph_identifier_state(self.graph)
    generate_node_identifiers(self.graph, state)
  }
  if self.unique {
    let known_ids : Map[String, Bool] = {}
    let random = @random.Rand::new()
    assert_unique_node_identifiers(self.graph, known_ids, random, false)
  }
}

///|
fn identifier_has_content(identifier : String) -> Bool {
  !identifier.trim().is_empty()
}

///|
fn graph_identifier_char_at(source : String, index : Int) -> Char {
  source[index].unsafe_to_char()
}

///|
fn validate_identifier(identifier : String) -> String? {
  if !identifier_has_content(identifier) {
    return None
  }
  let chars = []
  let mut changed = false
  for index = 0; index < identifier.length(); index = index + 1 {
    let current = graph_identifier_char_at(identifier, index)
    let valid = (current >= 'A' && current <= 'Z') ||
      (current >= 'a' && current <= 'z') ||
      current == '_' ||
      (index > 0 && current >= '0' && current <= '9')
    if valid {
      chars.push(current.to_string())
    } else {
      chars.push("_")
      changed = true
    }
  }
  if changed {
    Some(chars.join(""))
  } else {
    None
  }
}

///|
fn collect_identifier_if_present(
  identifier : String,
  ids : Map[String, Bool],
) -> Unit {
  if identifier_has_content(identifier) {
    ids[identifier] = true
  }
}

///|
fn collect_existing_label_identifiers(
  label : ElkLabel,
  ids : Map[String, Bool],
) -> Unit {
  collect_identifier_if_present(label_identifier(label), ids)
  for child in label_labels(label) {
    collect_existing_label_identifiers(child, ids)
  }
}

///|
fn collect_existing_port_identifiers(
  port : ElkPort,
  ids : Map[String, Bool],
) -> Unit {
  collect_identifier_if_present(port_identifier(port), ids)
  for label in port_labels(port) {
    collect_existing_label_identifiers(label, ids)
  }
}

///|
fn collect_existing_edge_identifiers(
  edge : ElkEdge,
  ids : Map[String, Bool],
) -> Unit {
  collect_identifier_if_present(edge_identifier(edge), ids)
  for label in edge_labels(edge) {
    collect_existing_label_identifiers(label, ids)
  }
  for section in edge_sections(edge) {
    collect_identifier_if_present(edge_section_identifier(section), ids)
  }
}

///|
fn collect_existing_node_identifiers(
  node : ElkNode,
  ids : Map[String, Bool],
  include_node : Bool,
) -> Unit {
  if include_node {
    collect_identifier_if_present(node_identifier(node), ids)
  }
  for label in node_labels(node) {
    collect_existing_label_identifiers(label, ids)
  }
  for port in node_ports(node) {
    collect_existing_port_identifiers(port, ids)
  }
  for edge in node_contained_edges(node) {
    collect_existing_edge_identifiers(edge, ids)
  }
  for child in node_children(node) {
    collect_existing_node_identifiers(child, ids, true)
  }
}

///|
fn new_graph_identifier_state(graph : ElkNode) -> GraphIdentifierState {
  let ids : Map[String, Bool] = {}
  collect_existing_node_identifiers(graph, ids, false)
  { current_ids: [0, 0, 0, 0, 0], existing_identifiers: ids }
}

///|
fn graph_identifier_prefix(element_type : GraphIdentifierElementType) -> String {
  match element_type {
    NodeElement => "N"
    PortElement => "P"
    EdgeElement => "E"
    EdgeSectionElement => "ES"
    LabelElement => "L"
  }
}

///|
fn graph_identifier_type_index(
  element_type : GraphIdentifierElementType,
) -> Int {
  match element_type {
    NodeElement => 0
    PortElement => 1
    EdgeElement => 2
    EdgeSectionElement => 3
    LabelElement => 4
  }
}

///|
fn next_identifier(
  state : GraphIdentifierState,
  element_type : GraphIdentifierElementType,
) -> String {
  let prefix = graph_identifier_prefix(element_type)
  let index = graph_identifier_type_index(element_type)
  let mut identifier = ""
  while true {
    let current = state.current_ids[index] + 1
    state.current_ids[index] = current
    identifier = prefix + current.to_string()
    if !state.existing_identifiers.contains(identifier) {
      break
    }
  }
  identifier
}

///|
fn set_identifier_if_missing_node(
  node : ElkNode,
  state : GraphIdentifierState,
) -> Unit {
  if !identifier_has_content(node_identifier(node)) {
    node_set_identifier(node, next_identifier(state, NodeElement))
  }
}

///|
fn set_identifier_if_missing_port(
  port : ElkPort,
  state : GraphIdentifierState,
) -> Unit {
  if !identifier_has_content(port_identifier(port)) {
    port_set_identifier(port, next_identifier(state, PortElement))
  }
}

///|
fn set_identifier_if_missing_edge(
  edge : ElkEdge,
  state : GraphIdentifierState,
) -> Unit {
  if !identifier_has_content(edge_identifier(edge)) {
    edge_set_identifier(edge, next_identifier(state, EdgeElement))
  }
}

///|
fn set_identifier_if_missing_section(
  section : ElkEdgeSection,
  state : GraphIdentifierState,
) -> Unit {
  if !identifier_has_content(edge_section_identifier(section)) {
    edge_section_set_identifier(
      section,
      next_identifier(state, EdgeSectionElement),
    )
  }
}

///|
fn set_identifier_if_missing_label(
  label : ElkLabel,
  state : GraphIdentifierState,
) -> Unit {
  if !identifier_has_content(label_identifier(label)) {
    label_set_identifier(label, next_identifier(state, LabelElement))
  }
}

///|
fn validate_label_identifiers(label : ElkLabel) -> Unit {
  match validate_identifier(label_identifier(label)) {
    Some(identifier) => label_set_identifier(label, identifier)
    None => ()
  }
  for child in label_labels(label) {
    validate_label_identifiers(child)
  }
}

///|
fn validate_port_identifiers(port : ElkPort) -> Unit {
  match validate_identifier(port_identifier(port)) {
    Some(identifier) => port_set_identifier(port, identifier)
    None => ()
  }
  for label in port_labels(port) {
    validate_label_identifiers(label)
  }
}

///|
fn validate_edge_identifiers(edge : ElkEdge) -> Unit {
  match validate_identifier(edge_identifier(edge)) {
    Some(identifier) => edge_set_identifier(edge, identifier)
    None => ()
  }
  for label in edge_labels(edge) {
    validate_label_identifiers(label)
  }
  for section in edge_sections(edge) {
    match validate_identifier(edge_section_identifier(section)) {
      Some(identifier) => edge_section_set_identifier(section, identifier)
      None => ()
    }
  }
}

///|
fn validate_node_identifiers(node : ElkNode) -> Unit {
  match validate_identifier(node_identifier(node)) {
    Some(identifier) => node_set_identifier(node, identifier)
    None => ()
  }
  for label in node_labels(node) {
    validate_label_identifiers(label)
  }
  for port in node_ports(node) {
    validate_port_identifiers(port)
  }
  for edge in node_contained_edges(node) {
    validate_edge_identifiers(edge)
  }
  for child in node_children(node) {
    validate_node_identifiers(child)
  }
}

///|
fn generate_label_identifiers(
  label : ElkLabel,
  state : GraphIdentifierState,
) -> Unit {
  set_identifier_if_missing_label(label, state)
  for child in label_labels(label) {
    generate_label_identifiers(child, state)
  }
}

///|
fn generate_port_identifiers(
  port : ElkPort,
  state : GraphIdentifierState,
) -> Unit {
  set_identifier_if_missing_port(port, state)
  for label in port_labels(port) {
    generate_label_identifiers(label, state)
  }
}

///|
fn generate_edge_identifiers(
  edge : ElkEdge,
  state : GraphIdentifierState,
) -> Unit {
  set_identifier_if_missing_edge(edge, state)
  for label in edge_labels(edge) {
    generate_label_identifiers(label, state)
  }
  for section in edge_sections(edge) {
    set_identifier_if_missing_section(section, state)
  }
}

///|
fn generate_node_identifiers(
  node : ElkNode,
  state : GraphIdentifierState,
) -> Unit {
  if node_parent(node) is None {
    if !identifier_has_content(node_identifier(node)) {
      node_set_identifier(node, "G1")
    }
  } else {
    set_identifier_if_missing_node(node, state)
  }
  for label in node_labels(node) {
    generate_label_identifiers(label, state)
  }
  for port in node_ports(node) {
    generate_port_identifiers(port, state)
  }
  for edge in node_contained_edges(node) {
    generate_edge_identifiers(edge, state)
  }
  for child in node_children(node) {
    generate_node_identifiers(child, state)
  }
}

///|
fn pad_zeroes(value : String, length : Int) -> String {
  if value.length() >= length {
    return value
  }
  let builder = StringBuilder::new()
  for index = 0; index < length - value.length(); index = index + 1 {
    ignore(index)
    builder.write_string("0")
  }
  builder.write_string(value)
  builder.to_string()
}

///|
fn four_digit_padded_random_number(random : @random.Rand) -> String {
  pad_zeroes(random.int(limit=10000).to_string(), 4)
}

///|
fn assert_unique_identifier(
  identifier : String,
  known_ids : Map[String, Bool],
  random : @random.Rand,
  set_identifier : (String) -> Unit,
) -> Unit {
  let mut current = identifier
  while known_ids.contains(current) {
    current = current + "_g" + four_digit_padded_random_number(random)
    set_identifier(current)
  }
  known_ids[current] = true
}

///|
fn assert_unique_label_identifiers(
  label : ElkLabel,
  known_ids : Map[String, Bool],
  random : @random.Rand,
) -> Unit {
  assert_unique_identifier(label_identifier(label), known_ids, random, identifier => {
    label_set_identifier(label, identifier)
  })
  for child in label_labels(label) {
    assert_unique_label_identifiers(child, known_ids, random)
  }
}

///|
fn assert_unique_port_identifiers(
  port : ElkPort,
  known_ids : Map[String, Bool],
  random : @random.Rand,
) -> Unit {
  assert_unique_identifier(port_identifier(port), known_ids, random, identifier => {
    port_set_identifier(port, identifier)
  })
  for label in port_labels(port) {
    assert_unique_label_identifiers(label, known_ids, random)
  }
}

///|
fn assert_unique_edge_identifiers(
  edge : ElkEdge,
  known_ids : Map[String, Bool],
  random : @random.Rand,
) -> Unit {
  assert_unique_identifier(edge_identifier(edge), known_ids, random, identifier => {
    edge_set_identifier(edge, identifier)
  })
  for label in edge_labels(edge) {
    assert_unique_label_identifiers(label, known_ids, random)
  }
}

///|
fn assert_unique_node_identifiers(
  node : ElkNode,
  known_ids : Map[String, Bool],
  random : @random.Rand,
  include_node : Bool,
) -> Unit {
  if include_node {
    assert_unique_identifier(node_identifier(node), known_ids, random, identifier => {
      node_set_identifier(node, identifier)
    })
  }
  for label in node_labels(node) {
    assert_unique_label_identifiers(label, known_ids, random)
  }
  for port in node_ports(node) {
    assert_unique_port_identifiers(port, known_ids, random)
  }
  for edge in node_contained_edges(node) {
    assert_unique_edge_identifiers(edge, known_ids, random)
  }
  for child in node_children(node) {
    assert_unique_node_identifiers(child, known_ids, random, true)
  }
}
