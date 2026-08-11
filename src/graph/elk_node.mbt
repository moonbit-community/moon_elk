///|
pub struct ElkNode {
  priv arena : GraphArena
  priv slot : Int
  priv generation : Int
  priv id : Int
}

///|
pub impl Eq for ElkNode with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for ElkNode with fn hash(self) {
  self.id
}

///|
pub impl Hash for ElkNode with fn hash_combine(self, hasher) {
  hasher.combine_int(self.id)
}

///|
pub impl @debug.Debug for ElkNode with fn to_repr(self) {
  Repr(self.id)
}

///|
pub impl Show for ElkNode with fn output(self, logger) {
  logger.write_string(self.id.to_string())
}

///|
pub impl Compare for ElkNode with fn compare(self, other) {
  self.id.compare(other.id)
}

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
priv struct NodeSlot {
  mut generation : Int
  handle : ElkNode
  mut data : NodeData?
}

///|
fn checked_node_slot(node : ElkNode) -> NodeSlot {
  let arena = node.arena
  checked_graph_arena(arena)
  if node.slot < 0 || node.slot >= arena.nodes.length() {
    abort("invalid or disposed node id")
  }
  let slot = arena.nodes[node.slot]
  if slot.generation != node.generation || slot.data is None {
    abort("invalid or disposed node id")
  }
  slot
}

///|
fn checked_node(node : ElkNode) -> Unit {
  ignore(checked_node_slot(node))
}

///|
fn node_data(node : ElkNode) -> NodeData {
  match checked_node_slot(node).data {
    Some(data) => data
    None => abort("invalid or disposed node id")
  }
}

///|
fn set_node_data(node : ElkNode, data : NodeData) -> Unit {
  checked_node_slot(node).data = Some(data)
}

///|
fn node_graph_arena(node : ElkNode) -> GraphArena {
  checked_node(node)
  node.arena
}

///|
pub fn ElkNode::graph_arena(self : ElkNode) -> GraphArena {
  node_graph_arena(self)
}

///|
fn dispose_node_slot(node : ElkNode) -> Unit {
  let slot = checked_node_slot(node)
  slot.data = None
  slot.generation += 1
}

///|
fn clone_string_int_map(source : Map[String, Int]) -> Map[String, Int] {
  let result = Map([])
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_double_map(source : Map[String, Double]) -> Map[String, Double] {
  let result = Map([])
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_bool_map(source : Map[String, Bool]) -> Map[String, Bool] {
  let result = Map([])
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_map(source : Map[String, String]) -> Map[String, String] {
  let result = Map([])
  source.each((key, value) => result[key] = value)
  result
}

///|
fn clone_string_string_array_map(
  source : Map[String, Array[String]],
) -> Map[String, Array[String]] {
  let result = Map([])
  source.each((key, value) => result[key] = value.copy())
  result
}

///|
pub fn create_graph() -> ElkNode {
  new_graph_arena().create_graph()
}

///|
fn append_child(parent_id : ElkNode, child_id : ElkNode) -> Unit {
  let parent_data = node_data(parent_id)
  parent_data.children.push(child_id)
  set_node_data(parent_id, parent_data)
}

///|
fn append_port(parent_id : ElkNode, port_id : ElkPort) -> Unit {
  let parent_data = node_data(parent_id)
  parent_data.ports.push(port_id)
  set_node_data(parent_id, parent_data)
}

///|
fn append_contained_edge(parent_id : ElkNode, edge_id : ElkEdge) -> Unit {
  let parent_data = node_data(parent_id)
  parent_data.contained_edges.push(edge_id)
  set_node_data(parent_id, parent_data)
}

///|
fn remove_contained_edge(parent_id : ElkNode, edge_id : ElkEdge) -> Unit {
  let parent_data = node_data(parent_id)
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
  set_node_data(parent_id, parent_data)
}

///|
fn create_node_in_arena(parent : ElkNode?, arena : GraphArena) -> ElkNode {
  checked_graph_arena(arena)
  let slot = arena.nodes.length()
  let node : ElkNode = {
    arena,
    slot,
    generation: 0,
    id: arena.allocate_object_id(),
  }
  arena.nodes.push({
    generation: 0,
    handle: node,
    data: Some({
      parent,
      children: [],
      ports: [],
      contained_edges: [],
      identifier: "",
      x: 0.0,
      y: 0.0,
      width: 0.0,
      height: 0.0,
      int_properties: Map([]),
      double_properties: Map([]),
      kvector_properties: Map([]),
      bool_properties: Map([]),
      string_properties: Map([]),
      string_set_properties: Map([]),
      layout_option_string_values: Map([]),
      individual_spacing_option_string_values: Map([]),
    }),
  })
  if parent is Some(parent_id) {
    checked_node(parent_id)
    append_child(parent_id, node)
  }
  node
}

///|
pub fn create_node(parent : ElkNode?) -> ElkNode {
  match parent {
    Some(parent_id) => {
      checked_node(parent_id)
      create_node_in_arena(Some(parent_id), node_graph_arena(parent_id))
    }
    None => new_graph_arena().create_graph()
  }
}

///|
pub fn node_parent(node : ElkNode) -> ElkNode? {
  node_data(node).parent
}

///|
pub fn node_children(node : ElkNode) -> Array[ElkNode] {
  node_data(node).children.copy()
}

///|
pub fn node_ports(node : ElkNode) -> Array[ElkPort] {
  node_data(node).ports.copy()
}

///|
pub fn node_contained_edges(node : ElkNode) -> Array[ElkEdge] {
  node_data(node).contained_edges.copy()
}

///|
pub fn node_set_location(node : ElkNode, x : Double, y : Double) -> Unit {
  let data = node_data(node)
  set_node_data(node, {
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
  })
}

///|
pub fn node_x(node : ElkNode) -> Double {
  node_data(node).x
}

///|
pub fn node_y(node : ElkNode) -> Double {
  node_data(node).y
}

///|
pub fn node_set_dimensions(
  node : ElkNode,
  width : Double,
  height : Double,
) -> Unit {
  let data = node_data(node)
  set_node_data(node, {
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
  })
}

///|
pub fn node_width(node : ElkNode) -> Double {
  node_data(node).width
}

///|
pub fn node_height(node : ElkNode) -> Double {
  node_data(node).height
}

///|
pub fn node_set_int_property(
  node : ElkNode,
  property : IProperty[Int],
  value : Int,
) -> Unit {
  let data = node_data(node)
  data.int_properties[property.get_id()] = value
  set_node_data(node, data)
}

///|
fn parse_int_property_text(value : String) -> Int? {
  try @string.parse_int(value.trim()) catch {
    _ => None
  } noraise {
    result => Some(result)
  }
}

///|
fn parse_double_property_text(value : String) -> Double? {
  try @string.parse_double(value.trim()) catch {
    _ => None
  } noraise {
    result => Some(result)
  }
}

///|
fn parse_bool_property_text(value : String) -> Bool? {
  let normalized = value.trim().to_lower()
  if normalized == "true" || normalized == "1" || normalized == "yes" {
    Some(true)
  } else if normalized == "false" || normalized == "0" || normalized == "no" {
    Some(false)
  } else {
    None
  }
}

///|
pub fn node_get_int_property(node : ElkNode, property : IProperty[Int]) -> Int {
  let data = node_data(node)
  match data.int_properties.get(property.get_id()) {
    Some(value) => value
    None =>
      match data.string_properties.get(property.get_id()) {
        Some(text) =>
          match parse_int_property_text(text) {
            Some(parsed) => parsed
            None =>
              match data.layout_option_string_values.get(property.get_id()) {
                Some(option_text) =>
                  parse_int_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match data.layout_option_string_values.get(property.get_id()) {
            Some(option_text) =>
              parse_int_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
      }
  }
}

///|
pub fn node_has_int_property(node : ElkNode, property : IProperty[Int]) -> Bool {
  let data = node_data(node)
  data.int_properties.contains(property.get_id())
}

///|
pub fn node_clear_int_property(
  node : ElkNode,
  property : IProperty[Int],
) -> Unit {
  let data = node_data(node)
  data.int_properties.remove(property.get_id())
  set_node_data(node, data)
}

///|
pub fn node_set_double_property(
  node : ElkNode,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  let data = node_data(node)
  data.double_properties[property.get_id()] = value
  set_node_data(node, data)
}

///|
pub fn node_get_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Double {
  let data = node_data(node)
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None =>
      match data.string_properties.get(property.get_id()) {
        Some(text) =>
          match parse_double_property_text(text) {
            Some(parsed) => parsed
            None =>
              match data.layout_option_string_values.get(property.get_id()) {
                Some(option_text) =>
                  parse_double_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match data.layout_option_string_values.get(property.get_id()) {
            Some(option_text) =>
              parse_double_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
      }
  }
}

///|
pub fn node_has_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Bool {
  let data = node_data(node)
  data.double_properties.contains(property.get_id())
}

///|
pub fn node_clear_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Unit {
  let data = node_data(node)
  data.double_properties.remove(property.get_id())
  set_node_data(node, data)
}

///|
pub fn node_set_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  let data = node_data(node)
  data.bool_properties[property.get_id()] = value
  set_node_data(node, data)
}

///|
pub fn node_get_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  let data = node_data(node)
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None =>
      match data.string_properties.get(property.get_id()) {
        Some(text) =>
          match parse_bool_property_text(text) {
            Some(parsed) => parsed
            None =>
              match data.layout_option_string_values.get(property.get_id()) {
                Some(option_text) =>
                  parse_bool_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match data.layout_option_string_values.get(property.get_id()) {
            Some(option_text) =>
              parse_bool_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
      }
  }
}

///|
pub fn node_has_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  let data = node_data(node)
  data.bool_properties.contains(property.get_id())
}

///|
pub fn node_clear_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Unit {
  let data = node_data(node)
  data.bool_properties.remove(property.get_id())
  set_node_data(node, data)
}

///|
pub fn node_set_string_property(
  node : ElkNode,
  property : IProperty[String],
  value : String,
) -> Unit {
  let data = node_data(node)
  data.string_properties[property.get_id()] = value
  set_node_data(node, data)
}

///|
pub fn node_get_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> String {
  let data = node_data(node)
  match data.string_properties.get(property.get_id()) {
    Some(value) => value
    None =>
      match data.layout_option_string_values.get(property.get_id()) {
        Some(value) => value
        None => property.get_default()
      }
  }
}

///|
pub fn node_has_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Bool {
  let data = node_data(node)
  data.string_properties.contains(property.get_id())
}

///|
pub fn node_clear_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Unit {
  let data = node_data(node)
  data.string_properties.remove(property.get_id())
  set_node_data(node, data)
}

///|
pub fn node_set_identifier(node : ElkNode, identifier : String) -> Unit {
  let data = node_data(node)
  set_node_data(node, {
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
  })
}

///|
pub fn node_identifier(node : ElkNode) -> String {
  node_data(node).identifier
}

///|
pub fn node_set_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
  value : Array[String],
) -> Unit {
  let data = node_data(node)
  data.string_set_properties[property.get_id()] = value.copy()
  set_node_data(node, data)
}

///|
pub fn node_get_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Array[String] {
  let data = node_data(node)
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
  let data = node_data(node)
  data.string_set_properties.contains(property.get_id())
}

///|
pub fn node_clear_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Unit {
  let data = node_data(node)
  data.string_set_properties.remove(property.get_id())
  set_node_data(node, data)
}

///|
pub fn node_int_property_entries(node : ElkNode) -> Array[(String, Int)] {
  node_data(node).int_properties.to_array()
}

///|
pub fn node_bool_property_entries(node : ElkNode) -> Array[(String, Bool)] {
  node_data(node).bool_properties.to_array()
}

///|
pub fn node_double_property_entries(node : ElkNode) -> Array[(String, Double)] {
  node_data(node).double_properties.to_array()
}

///|
pub fn node_kvector_property_entries(node : ElkNode) -> Array[(String, String)] {
  node_data(node).kvector_properties.to_array()
}

///|
pub fn node_string_property_entries(node : ElkNode) -> Array[(String, String)] {
  node_data(node).string_properties.to_array()
}

///|
pub fn node_string_set_property_entries(
  node : ElkNode,
) -> Array[(String, Array[String])] {
  let entries : Array[(String, Array[String])] = []
  for entry in node_data(node).string_set_properties.to_array() {
    entries.push((entry.0, entry.1.copy()))
  }
  entries
}

///|
pub fn node_set_layout_option_string_by_id(
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  let data = node_data(node)
  data.layout_option_string_values[option_id] = value
  set_node_data(node, data)
}

///|
pub fn node_layout_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  node_data(node).layout_option_string_values.to_array()
}

///|
pub fn node_layout_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  node_data(node).layout_option_string_values.get(option_id)
}

///|
pub fn node_set_individual_spacing_option_string_by_id(
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  let data = node_data(node)
  data.individual_spacing_option_string_values[option_id] = value
  set_node_data(node, data)
}

///|
pub fn node_individual_spacing_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  node_data(node).individual_spacing_option_string_values.to_array()
}

///|
pub fn node_individual_spacing_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  node_data(node).individual_spacing_option_string_values.get(option_id)
}

///|
pub fn node_copy_properties(target : ElkNode, source : ElkNode) -> Unit {
  let target_data = node_data(target)
  let source_data = node_data(source)
  set_node_data(target, {
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
  })
}

///|
pub fn node_all_descendants_including_self(root : ElkNode) -> Array[ElkNode] {
  let result = []
  let queue = [root]
  let visited : Map[ElkNode, Unit] = Map([])
  let mut index = 0
  while index < queue.length() {
    let current = queue[index]
    index += 1
    if visited.contains(current) {
      continue
    }
    visited[current] = ()
    result.push(current)
    for child in node_children(current) {
      queue.push(child)
    }
  }
  result
}

///|
pub fn node_incoming_edges(node : ElkNode) -> Array[ElkEdge] {
  let incoming = []
  for edge in node_graph_arena(node).all_edges() {
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
  let outgoing = []
  for edge in node_graph_arena(node).all_edges() {
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
