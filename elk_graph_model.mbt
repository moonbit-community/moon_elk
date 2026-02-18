///|
priv struct NodeData {
  parent : ElkNode?
  children : Array[ElkNode]
  ports : Array[ElkPort]
  contained_edges : Array[ElkEdge]
  identifier : String
  x : Double
  y : Double
  width : Double
  height : Double
  int_properties : Map[String, Int]
  double_properties : Map[String, Double]
  kvector_properties : Map[String, KVector]
  bool_properties : Map[String, Bool]
  string_properties : Map[String, String]
  string_set_properties : Map[String, Array[String]]
  layout_option_string_values : Map[String, String]
  individual_spacing_option_string_values : Map[String, String]
}

///|
priv struct PortData {
  parent : ElkNode?
  identifier : String
  x : Double
  y : Double
  width : Double
  height : Double
  layout_option_string_values : Map[String, String]
}

///|
priv struct EdgeData {
  containing_node : ElkNode?
  sources : Array[ElkConnectableShape]
  targets : Array[ElkConnectableShape]
  identifier : String
  sections : Array[ElkEdgeSection]
  layout_option_string_values : Map[String, String]
}

///|
priv struct EdgeSectionData {
  edge : ElkEdge
  mut identifier : String
  mut start_x : Double
  mut start_y : Double
  mut end_x : Double
  mut end_y : Double
  mut incoming_shape : ElkConnectableShape?
  mut outgoing_shape : ElkConnectableShape?
  incoming_sections : Array[ElkEdgeSection]
  outgoing_sections : Array[ElkEdgeSection]
}

///|
let node_store : Ref[Array[NodeData]] = Ref::new([])

///|
let port_store : Ref[Array[PortData]] = Ref::new([])

///|
let edge_store : Ref[Array[EdgeData]] = Ref::new([])

///|
let edge_section_store : Ref[Array[EdgeSectionData]] = Ref::new([])

///|
fn checked_node(node : ElkNode) -> Unit {
  if node < 0 || node >= node_store.val.length() {
    abort("invalid node id")
  }
}

///|
fn checked_port(port : ElkPort) -> Unit {
  if port < 0 || port >= port_store.val.length() {
    abort("invalid port id")
  }
}

///|
fn checked_edge(edge : ElkEdge) -> Unit {
  if edge < 0 || edge >= edge_store.val.length() {
    abort("invalid edge id")
  }
}

///|
fn checked_edge_section(section : ElkEdgeSection) -> Unit {
  if section < 0 || section >= edge_section_store.val.length() {
    abort("invalid edge section id")
  }
}

///|
fn clone_string_int_map(source : Map[String, Int]) -> Map[String, Int] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_double_map(source : Map[String, Double]) -> Map[String, Double] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_kvector_map(
  source : Map[String, KVector],
) -> Map[String, KVector] {
  let result = {}
  source.each((key, value) => result[key] = value.clone())
  result
}

///|
fn clone_string_bool_map(source : Map[String, Bool]) -> Map[String, Bool] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_map(source : Map[String, String]) -> Map[String, String] {
  let result = {}
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_array_map(
  source : Map[String, Array[String]],
) -> Map[String, Array[String]] {
  let result = {}
  source.each((key, value) => result[key] = value.copy())
  result
}

///|
pub fn reset_graph_model_for_test() -> Unit {
  node_store.val.clear()
  port_store.val.clear()
  edge_store.val.clear()
  edge_section_store.val.clear()
  label_store.val.clear()
}

///|
pub fn create_graph() -> ElkNode {
  create_node(None)
}

///|
fn append_child(parent_id : ElkNode, child_id : ElkNode) -> Unit {
  let parent_data = node_store.val[parent_id]
  parent_data.children.push(child_id)
  node_store.val[parent_id] = parent_data
}

///|
fn append_port(parent_id : ElkNode, port_id : ElkPort) -> Unit {
  let parent_data = node_store.val[parent_id]
  parent_data.ports.push(port_id)
  node_store.val[parent_id] = parent_data
}

///|
fn append_contained_edge(parent_id : ElkNode, edge_id : ElkEdge) -> Unit {
  let parent_data = node_store.val[parent_id]
  parent_data.contained_edges.push(edge_id)
  node_store.val[parent_id] = parent_data
}

///|
fn remove_contained_edge(parent_id : ElkNode, edge_id : ElkEdge) -> Unit {
  let parent_data = node_store.val[parent_id]
  let filtered = []
  for current in parent_data.contained_edges {
    if current != edge_id {
      filtered.push(current)
    }
  }
  parent_data.contained_edges.clear()
  for current in filtered {
    parent_data.contained_edges.push(current)
  }
  node_store.val[parent_id] = parent_data
}

///|
pub fn create_node(parent : ElkNode?) -> ElkNode {
  let id = node_store.val.length()
  node_store.val.push({
    parent,
    children: [],
    ports: [],
    contained_edges: [],
    identifier: "",
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    int_properties: {},
    double_properties: {},
    kvector_properties: {},
    bool_properties: {},
    string_properties: {},
    string_set_properties: {},
    layout_option_string_values: {},
    individual_spacing_option_string_values: {},
  })
  if parent is Some(parent_id) {
    checked_node(parent_id)
    append_child(parent_id, id)
  }
  id
}

///|
pub fn create_port(parent : ElkNode?) -> ElkPort {
  let id = port_store.val.length()
  port_store.val.push({
    parent,
    identifier: "",
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    layout_option_string_values: {},
  })
  if parent is Some(parent_id) {
    checked_node(parent_id)
    append_port(parent_id, id)
  }
  id
}

///|
pub fn port_set_location(port : ElkPort, x : Double, y : Double) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
    parent: data.parent,
    identifier: data.identifier,
    x,
    y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_x(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].x
}

///|
pub fn port_y(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].y
}

///|
pub fn port_set_dimensions(
  port : ElkPort,
  width : Double,
  height : Double,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
    parent: data.parent,
    identifier: data.identifier,
    x: data.x,
    y: data.y,
    width,
    height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_width(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].width
}

///|
pub fn port_height(port : ElkPort) -> Double {
  checked_port(port)
  port_store.val[port].height
}

///|
pub fn port_set_identifier(port : ElkPort, identifier : String) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  port_store.val[port] = {
    parent: data.parent,
    identifier,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn port_identifier(port : ElkPort) -> String {
  checked_port(port)
  port_store.val[port].identifier
}

///|
pub fn create_edge(containing_node : ElkNode?) -> ElkEdge {
  if containing_node is Some(node_id) {
    checked_node(node_id)
  }
  let id = edge_store.val.length()
  edge_store.val.push({
    containing_node,
    sources: [],
    targets: [],
    identifier: "",
    sections: [],
    layout_option_string_values: {},
  })
  if containing_node is Some(node_id) {
    append_contained_edge(node_id, id)
  }
  id
}

///|
pub fn edge_add_source(edge : ElkEdge, source : ElkConnectableShape) -> Unit {
  checked_edge(edge)
  match source {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  let data = edge_store.val[edge]
  data.sources.push(source)
  edge_store.val[edge] = data
}

///|
pub fn edge_add_target(edge : ElkEdge, target : ElkConnectableShape) -> Unit {
  checked_edge(edge)
  match target {
    NodeShape(node) => checked_node(node)
    PortShape(port) => checked_port(port)
  }
  let data = edge_store.val[edge]
  data.targets.push(target)
  edge_store.val[edge] = data
}

///|
pub fn node_parent(node : ElkNode) -> ElkNode? {
  checked_node(node)
  node_store.val[node].parent
}

///|
pub fn node_children(node : ElkNode) -> Array[ElkNode] {
  checked_node(node)
  node_store.val[node].children
}

///|
pub fn node_ports(node : ElkNode) -> Array[ElkPort] {
  checked_node(node)
  node_store.val[node].ports
}

///|
pub fn node_contained_edges(node : ElkNode) -> Array[ElkEdge] {
  checked_node(node)
  node_store.val[node].contained_edges
}

///|
pub fn node_set_location(node : ElkNode, x : Double, y : Double) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  node_store.val[node] = {
    parent: data.parent,
    children: data.children,
    ports: data.ports,
    contained_edges: data.contained_edges,
    identifier: data.identifier,
    x,
    y,
    width: data.width,
    height: data.height,
    int_properties: data.int_properties,
    double_properties: data.double_properties,
    kvector_properties: data.kvector_properties,
    bool_properties: data.bool_properties,
    string_properties: data.string_properties,
    string_set_properties: data.string_set_properties,
    layout_option_string_values: data.layout_option_string_values,
    individual_spacing_option_string_values: data.individual_spacing_option_string_values,
  }
}

///|
pub fn node_x(node : ElkNode) -> Double {
  checked_node(node)
  node_store.val[node].x
}

///|
pub fn node_y(node : ElkNode) -> Double {
  checked_node(node)
  node_store.val[node].y
}

///|
pub fn node_set_dimensions(
  node : ElkNode,
  width : Double,
  height : Double,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  node_store.val[node] = {
    parent: data.parent,
    children: data.children,
    ports: data.ports,
    contained_edges: data.contained_edges,
    identifier: data.identifier,
    x: data.x,
    y: data.y,
    width,
    height,
    int_properties: data.int_properties,
    double_properties: data.double_properties,
    kvector_properties: data.kvector_properties,
    bool_properties: data.bool_properties,
    string_properties: data.string_properties,
    string_set_properties: data.string_set_properties,
    layout_option_string_values: data.layout_option_string_values,
    individual_spacing_option_string_values: data.individual_spacing_option_string_values,
  }
}

///|
pub fn node_width(node : ElkNode) -> Double {
  checked_node(node)
  node_store.val[node].width
}

///|
pub fn node_height(node : ElkNode) -> Double {
  checked_node(node)
  node_store.val[node].height
}

///|
pub fn node_set_int_property(
  node : ElkNode,
  property : IProperty[Int],
  value : Int,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.int_properties[property.get_id()] = value
  node_store.val[node] = data
}

///|
pub fn node_get_int_property(node : ElkNode, property : IProperty[Int]) -> Int {
  checked_node(node)
  let data = node_store.val[node]
  match data.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn node_has_int_property(node : ElkNode, property : IProperty[Int]) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.int_properties.contains(property.get_id())
}

///|
pub fn node_clear_int_property(
  node : ElkNode,
  property : IProperty[Int],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.int_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_set_double_property(
  node : ElkNode,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.double_properties[property.get_id()] = value
  node_store.val[node] = data
}

///|
pub fn node_set_kvector_property(
  node : ElkNode,
  property : IProperty[KVector],
  value : KVector,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.kvector_properties[property.get_id()] = value.clone()
  node_store.val[node] = data
}

///|
pub fn node_get_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Double {
  checked_node(node)
  let data = node_store.val[node]
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn node_get_kvector_property(
  node : ElkNode,
  property : IProperty[KVector],
) -> KVector {
  checked_node(node)
  let data = node_store.val[node]
  match data.kvector_properties.get(property.get_id()) {
    Some(value) => value.clone()
    None => property.get_default().clone()
  }
}

///|
pub fn node_has_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.double_properties.contains(property.get_id())
}

///|
pub fn node_has_kvector_property(
  node : ElkNode,
  property : IProperty[KVector],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.kvector_properties.contains(property.get_id())
}

///|
pub fn node_clear_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.double_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_clear_kvector_property(
  node : ElkNode,
  property : IProperty[KVector],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.kvector_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_set_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.bool_properties[property.get_id()] = value
  node_store.val[node] = data
}

///|
pub fn node_get_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn node_has_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.bool_properties.contains(property.get_id())
}

///|
pub fn node_clear_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.bool_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_set_string_property(
  node : ElkNode,
  property : IProperty[String],
  value : String,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.string_properties[property.get_id()] = value
  node_store.val[node] = data
}

///|
pub fn node_get_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> String {
  checked_node(node)
  let data = node_store.val[node]
  match data.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn node_has_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.string_properties.contains(property.get_id())
}

///|
pub fn node_clear_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.string_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_set_identifier(node : ElkNode, identifier : String) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  node_store.val[node] = {
    parent: data.parent,
    children: data.children,
    ports: data.ports,
    contained_edges: data.contained_edges,
    identifier,
    x: data.x,
    y: data.y,
    width: data.width,
    height: data.height,
    int_properties: data.int_properties,
    double_properties: data.double_properties,
    kvector_properties: data.kvector_properties,
    bool_properties: data.bool_properties,
    string_properties: data.string_properties,
    string_set_properties: data.string_set_properties,
    layout_option_string_values: data.layout_option_string_values,
    individual_spacing_option_string_values: data.individual_spacing_option_string_values,
  }
}

///|
pub fn node_identifier(node : ElkNode) -> String {
  checked_node(node)
  node_store.val[node].identifier
}

///|
pub fn node_set_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.string_set_properties[property.get_id()] = value.copy()
  node_store.val[node] = data
}

///|
pub fn node_get_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Array[String] {
  checked_node(node)
  let data = node_store.val[node]
  match data.string_set_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn node_has_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.string_set_properties.contains(property.get_id())
}

///|
pub fn node_clear_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.string_set_properties.remove(property.get_id())
  node_store.val[node] = data
}

///|
pub fn node_double_property_entries(node : ElkNode) -> Array[(String, Double)] {
  checked_node(node)
  node_store.val[node].double_properties.to_array()
}

///|
pub fn node_set_layout_option_string_value(
  node : ElkNode,
  option : LayoutOptionData,
  value : String,
) -> Unit {
  node_set_layout_option_string_by_id(node, option.get_id(), value)
}

///|
pub fn node_set_layout_option_string_by_id(
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.layout_option_string_values[option_id] = value
  node_store.val[node] = data
}

///|
pub fn node_layout_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  checked_node(node)
  node_store.val[node].layout_option_string_values.to_array()
}

///|
pub fn node_layout_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  checked_node(node)
  node_store.val[node].layout_option_string_values.get(option_id)
}

///|
pub fn node_set_individual_spacing_option_string_by_id(
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  checked_node(node)
  let data = node_store.val[node]
  data.individual_spacing_option_string_values[option_id] = value
  node_store.val[node] = data
}

///|
pub fn node_individual_spacing_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  checked_node(node)
  node_store.val[node].individual_spacing_option_string_values.to_array()
}

///|
pub fn node_individual_spacing_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  checked_node(node)
  node_store.val[node].individual_spacing_option_string_values.get(option_id)
}

///|
pub fn node_copy_properties(target : ElkNode, source : ElkNode) -> Unit {
  checked_node(target)
  checked_node(source)
  let target_data = node_store.val[target]
  let source_data = node_store.val[source]
  node_store.val[target] = {
    parent: target_data.parent,
    children: target_data.children,
    ports: target_data.ports,
    contained_edges: target_data.contained_edges,
    identifier: target_data.identifier,
    x: target_data.x,
    y: target_data.y,
    width: target_data.width,
    height: target_data.height,
    int_properties: clone_string_int_map(source_data.int_properties),
    double_properties: clone_string_double_map(source_data.double_properties),
    kvector_properties: clone_string_kvector_map(source_data.kvector_properties),
    bool_properties: clone_string_bool_map(source_data.bool_properties),
    string_properties: clone_string_string_map(source_data.string_properties),
    string_set_properties: clone_string_string_array_map(
      source_data.string_set_properties,
    ),
    layout_option_string_values: clone_string_string_map(
      source_data.layout_option_string_values,
    ),
    individual_spacing_option_string_values: clone_string_string_map(
      source_data.individual_spacing_option_string_values,
    ),
  }
}

///|
pub fn port_set_layout_option_string_by_id(
  port : ElkPort,
  option_id : String,
  value : String,
) -> Unit {
  checked_port(port)
  let data = port_store.val[port]
  data.layout_option_string_values[option_id] = value
  port_store.val[port] = data
}

///|
pub fn port_layout_option_string_value(
  port : ElkPort,
  option_id : String,
) -> String? {
  checked_port(port)
  port_store.val[port].layout_option_string_values.get(option_id)
}

///|
pub fn edge_set_layout_option_string_by_id(
  edge : ElkEdge,
  option_id : String,
  value : String,
) -> Unit {
  checked_edge(edge)
  let data = edge_store.val[edge]
  data.layout_option_string_values[option_id] = value
  edge_store.val[edge] = data
}

///|
pub fn edge_layout_option_string_value(
  edge : ElkEdge,
  option_id : String,
) -> String? {
  checked_edge(edge)
  edge_store.val[edge].layout_option_string_values.get(option_id)
}

///|
pub fn edge_layout_option_string_entries(
  edge : ElkEdge,
) -> Array[(String, String)] {
  checked_edge(edge)
  edge_store.val[edge].layout_option_string_values.to_array()
}

///|
pub fn edge_copy_properties(target : ElkEdge, source : ElkEdge) -> Unit {
  checked_edge(target)
  checked_edge(source)
  let target_data = edge_store.val[target]
  let source_data = edge_store.val[source]
  edge_store.val[target] = {
    containing_node: target_data.containing_node,
    sources: target_data.sources,
    targets: target_data.targets,
    identifier: target_data.identifier,
    sections: target_data.sections,
    layout_option_string_values: clone_string_string_map(
      source_data.layout_option_string_values,
    ),
  }
}

///|
pub fn node_all_descendants_including_self(root : ElkNode) -> Array[ElkNode] {
  checked_node(root)
  let result = []
  let queue = [root]
  let mut index = 0
  while index < queue.length() {
    let current = queue[index]
    index += 1
    result.push(current)
    for child in node_children(current) {
      queue.push(child)
    }
  }
  result
}

///|
pub fn port_parent(port : ElkPort) -> ElkNode? {
  checked_port(port)
  port_store.val[port].parent
}

///|
pub fn edge_sources(edge : ElkEdge) -> Array[ElkConnectableShape] {
  checked_edge(edge)
  edge_store.val[edge].sources
}

///|
pub fn edge_targets(edge : ElkEdge) -> Array[ElkConnectableShape] {
  checked_edge(edge)
  edge_store.val[edge].targets
}

///|
pub fn all_edges() -> Array[ElkEdge] {
  let edges = []
  for edge = 0; edge < edge_store.val.length(); edge = edge + 1 {
    edges.push(edge)
  }
  edges
}

///|
pub fn port_incoming_edges(port : ElkPort) -> Array[ElkEdge] {
  checked_port(port)
  let incoming = []
  for edge in all_edges() {
    for target in edge_targets(edge) {
      match target {
        PortShape(target_port) =>
          if target_port == port {
            incoming.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  incoming
}

///|
pub fn port_outgoing_edges(port : ElkPort) -> Array[ElkEdge] {
  checked_port(port)
  let outgoing = []
  for edge in all_edges() {
    for source in edge_sources(edge) {
      match source {
        PortShape(source_port) =>
          if source_port == port {
            outgoing.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  outgoing
}

///|
pub fn node_incoming_edges(node : ElkNode) -> Array[ElkEdge] {
  checked_node(node)
  let incoming = []
  for edge in all_edges() {
    for target in edge_targets(edge) {
      match target {
        NodeShape(target_node) =>
          if target_node == node {
            incoming.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  incoming
}

///|
pub fn node_outgoing_edges(node : ElkNode) -> Array[ElkEdge] {
  checked_node(node)
  let outgoing = []
  for edge in all_edges() {
    for source in edge_sources(edge) {
      match source {
        NodeShape(source_node) =>
          if source_node == node {
            outgoing.push(edge)
            break
          }
        _ => ()
      }
    }
  }
  outgoing
}

///|
pub fn edge_is_connected(edge : ElkEdge) -> Bool {
  checked_edge(edge)
  !edge_store.val[edge].sources.is_empty() &&
  !edge_store.val[edge].targets.is_empty()
}

///|
pub fn edge_containing_node(edge : ElkEdge) -> ElkNode? {
  checked_edge(edge)
  edge_store.val[edge].containing_node
}

///|
pub fn edge_set_containing_node(
  edge : ElkEdge,
  containing_node : ElkNode?,
) -> Unit {
  checked_edge(edge)
  if containing_node is Some(node_id) {
    checked_node(node_id)
  }
  let data = edge_store.val[edge]
  if data.containing_node is Some(old_parent) {
    remove_contained_edge(old_parent, edge)
  }
  if containing_node is Some(new_parent) {
    append_contained_edge(new_parent, edge)
  }
  edge_store.val[edge] = {
    containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier: data.identifier,
    sections: data.sections,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn edge_set_identifier(edge : ElkEdge, identifier : String) -> Unit {
  checked_edge(edge)
  let data = edge_store.val[edge]
  edge_store.val[edge] = {
    containing_node: data.containing_node,
    sources: data.sources,
    targets: data.targets,
    identifier,
    sections: data.sections,
    layout_option_string_values: data.layout_option_string_values,
  }
}

///|
pub fn edge_identifier(edge : ElkEdge) -> String {
  checked_edge(edge)
  edge_store.val[edge].identifier
}

///|
pub fn create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  checked_edge(edge)
  let id = edge_section_store.val.length()
  edge_section_store.val.push({
    edge,
    identifier: "",
    start_x: 0.0,
    start_y: 0.0,
    end_x: 0.0,
    end_y: 0.0,
    incoming_shape: None,
    outgoing_shape: None,
    incoming_sections: [],
    outgoing_sections: [],
  })
  let edge_data = edge_store.val[edge]
  edge_data.sections.push(id)
  edge_store.val[edge] = edge_data
  id
}

///|
pub fn edge_sections(edge : ElkEdge) -> Array[ElkEdgeSection] {
  checked_edge(edge)
  edge_store.val[edge].sections
}

///|
pub fn edge_section_identifier(section : ElkEdgeSection) -> String {
  checked_edge_section(section)
  edge_section_store.val[section].identifier
}

///|
pub fn edge_section_set_identifier(
  section : ElkEdgeSection,
  identifier : String,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.identifier = identifier
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_start(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.start_x = x
  section_data.start_y = y
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_end(
  section : ElkEdgeSection,
  x : Double,
  y : Double,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.end_x = x
  section_data.end_y = y
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_start_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].start_x
}

///|
pub fn edge_section_start_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].start_y
}

///|
pub fn edge_section_end_x(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].end_x
}

///|
pub fn edge_section_end_y(section : ElkEdgeSection) -> Double {
  checked_edge_section(section)
  edge_section_store.val[section].end_y
}

///|
pub fn edge_section_set_incoming_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.incoming_shape = shape
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_set_outgoing_shape(
  section : ElkEdgeSection,
  shape : ElkConnectableShape?,
) -> Unit {
  checked_edge_section(section)
  let section_data = edge_section_store.val[section]
  section_data.outgoing_shape = shape
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_incoming_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[section].incoming_shape
}

///|
pub fn edge_section_outgoing_shape(
  section : ElkEdgeSection,
) -> ElkConnectableShape? {
  checked_edge_section(section)
  edge_section_store.val[section].outgoing_shape
}

///|
pub fn edge_section_add_incoming_section(
  section : ElkEdgeSection,
  incoming_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(incoming_section)
  let section_data = edge_section_store.val[section]
  section_data.incoming_sections.push(incoming_section)
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_add_outgoing_section(
  section : ElkEdgeSection,
  outgoing_section : ElkEdgeSection,
) -> Unit {
  checked_edge_section(section)
  checked_edge_section(outgoing_section)
  let section_data = edge_section_store.val[section]
  section_data.outgoing_sections.push(outgoing_section)
  edge_section_store.val[section] = section_data
}

///|
pub fn edge_section_incoming_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[section].incoming_sections
}

///|
pub fn edge_section_outgoing_sections(
  section : ElkEdgeSection,
) -> Array[ElkEdgeSection] {
  checked_edge_section(section)
  edge_section_store.val[section].outgoing_sections
}
