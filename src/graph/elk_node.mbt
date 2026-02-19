///|
pub type ElkNode = Int

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
  kvector_properties : Map[String, String]
  bool_properties : Map[String, Bool]
  string_properties : Map[String, String]
  string_set_properties : Map[String, Array[String]]
  layout_option_string_values : Map[String, String]
  individual_spacing_option_string_values : Map[String, String]
}

///|
let node_store : Ref[Array[NodeData]] = Ref::new([])

///|
fn checked_node(node : ElkNode) -> Unit {
  if node < 0 || node >= node_store.val.length() {
    abort("invalid node id")
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
pub fn node_has_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Bool {
  checked_node(node)
  let data = node_store.val[node]
  data.double_properties.contains(property.get_id())
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
    kvector_properties: clone_string_string_map(source_data.kvector_properties),
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
