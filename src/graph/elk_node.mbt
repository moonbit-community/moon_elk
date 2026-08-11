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
  mut properties : NodePropertyBag?
  mut layout_options : OptionBag?
  mut individual_spacings : OptionBag?
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
      properties: None,
      layout_options: None,
      individual_spacings: None,
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
    properties: data.properties,
    layout_options: data.layout_options,
    individual_spacings: data.individual_spacings,
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
    properties: data.properties,
    layout_options: data.layout_options,
    individual_spacings: data.individual_spacings,
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
  data.properties = Some(
    node_property_bag_set(
      data.properties,
      property.get_property_id(),
      property.get_id(),
      NodeIntValue(value),
    ),
  )
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
  let property_id = property.get_property_id()
  match node_property_bag_get(data.properties, property_id, NodeIntValue(0)) {
    Some(NodeIntValue(value)) => value
    None =>
      match
        node_property_bag_get(data.properties, property_id, NodeStringValue("")) {
        Some(NodeStringValue(text)) =>
          match parse_int_property_text(text) {
            Some(parsed) => parsed
            None =>
              match option_bag_get(data.layout_options, property_id) {
                Some(option_text) =>
                  parse_int_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match option_bag_get(data.layout_options, property_id) {
            Some(option_text) =>
              parse_int_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
        _ => property.get_default()
      }
    _ => property.get_default()
  }
}

///|
pub fn node_has_int_property(node : ElkNode, property : IProperty[Int]) -> Bool {
  let data = node_data(node)
  node_property_bag_has(
    data.properties,
    property.get_property_id(),
    NodeIntValue(0),
  )
}

///|
pub fn node_clear_int_property(
  node : ElkNode,
  property : IProperty[Int],
) -> Unit {
  let data = node_data(node)
  data.properties = node_property_bag_remove(
    data.properties,
    property.get_property_id(),
    NodeIntValue(0),
  )
}

///|
pub fn node_set_double_property(
  node : ElkNode,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  let data = node_data(node)
  data.properties = Some(
    node_property_bag_set(
      data.properties,
      property.get_property_id(),
      property.get_id(),
      NodeDoubleValue(value),
    ),
  )
}

///|
pub fn node_get_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Double {
  let data = node_data(node)
  let property_id = property.get_property_id()
  match
    node_property_bag_get(data.properties, property_id, NodeDoubleValue(0.0)) {
    Some(NodeDoubleValue(value)) => value
    None =>
      match
        node_property_bag_get(data.properties, property_id, NodeStringValue("")) {
        Some(NodeStringValue(text)) =>
          match parse_double_property_text(text) {
            Some(parsed) => parsed
            None =>
              match option_bag_get(data.layout_options, property_id) {
                Some(option_text) =>
                  parse_double_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match option_bag_get(data.layout_options, property_id) {
            Some(option_text) =>
              parse_double_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
        _ => property.get_default()
      }
    _ => property.get_default()
  }
}

///|
pub fn node_has_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Bool {
  let data = node_data(node)
  node_property_bag_has(
    data.properties,
    property.get_property_id(),
    NodeDoubleValue(0.0),
  )
}

///|
pub fn node_clear_double_property(
  node : ElkNode,
  property : IProperty[Double],
) -> Unit {
  let data = node_data(node)
  data.properties = node_property_bag_remove(
    data.properties,
    property.get_property_id(),
    NodeDoubleValue(0.0),
  )
}

///|
pub fn node_set_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  let data = node_data(node)
  data.properties = Some(
    node_property_bag_set(
      data.properties,
      property.get_property_id(),
      property.get_id(),
      NodeBoolValue(value),
    ),
  )
}

///|
pub fn node_get_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  let data = node_data(node)
  let property_id = property.get_property_id()
  match
    node_property_bag_get(data.properties, property_id, NodeBoolValue(false)) {
    Some(NodeBoolValue(value)) => value
    None =>
      match
        node_property_bag_get(data.properties, property_id, NodeStringValue("")) {
        Some(NodeStringValue(text)) =>
          match parse_bool_property_text(text) {
            Some(parsed) => parsed
            None =>
              match option_bag_get(data.layout_options, property_id) {
                Some(option_text) =>
                  parse_bool_property_text(option_text).unwrap_or(
                    property.get_default(),
                  )
                None => property.get_default()
              }
          }
        None =>
          match option_bag_get(data.layout_options, property_id) {
            Some(option_text) =>
              parse_bool_property_text(option_text).unwrap_or(
                property.get_default(),
              )
            None => property.get_default()
          }
        _ => property.get_default()
      }
    _ => property.get_default()
  }
}

///|
pub fn node_has_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  let data = node_data(node)
  node_property_bag_has(
    data.properties,
    property.get_property_id(),
    NodeBoolValue(false),
  )
}

///|
pub fn node_clear_bool_property(
  node : ElkNode,
  property : IProperty[Bool],
) -> Unit {
  let data = node_data(node)
  data.properties = node_property_bag_remove(
    data.properties,
    property.get_property_id(),
    NodeBoolValue(false),
  )
}

///|
pub fn node_set_string_property(
  node : ElkNode,
  property : IProperty[String],
  value : String,
) -> Unit {
  let data = node_data(node)
  data.properties = Some(
    node_property_bag_set(
      data.properties,
      property.get_property_id(),
      property.get_id(),
      NodeStringValue(value),
    ),
  )
}

///|
pub fn node_get_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> String {
  let data = node_data(node)
  let property_id = property.get_property_id()
  match
    node_property_bag_get(data.properties, property_id, NodeStringValue("")) {
    Some(NodeStringValue(value)) => value
    None =>
      match option_bag_get(data.layout_options, property_id) {
        Some(value) => value
        None => property.get_default()
      }
    _ => property.get_default()
  }
}

///|
pub fn node_has_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Bool {
  let data = node_data(node)
  node_property_bag_has(
    data.properties,
    property.get_property_id(),
    NodeStringValue(""),
  )
}

///|
pub fn node_clear_string_property(
  node : ElkNode,
  property : IProperty[String],
) -> Unit {
  let data = node_data(node)
  data.properties = node_property_bag_remove(
    data.properties,
    property.get_property_id(),
    NodeStringValue(""),
  )
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
    properties: data.properties,
    layout_options: data.layout_options,
    individual_spacings: data.individual_spacings,
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
  data.properties = Some(
    node_property_bag_set(
      data.properties,
      property.get_property_id(),
      property.get_id(),
      NodeStringSetValue(value.copy()),
    ),
  )
}

///|
pub fn node_get_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Array[String] {
  let data = node_data(node)
  match
    node_property_bag_get(
      data.properties,
      property.get_property_id(),
      NodeStringSetValue([]),
    ) {
    Some(NodeStringSetValue(value)) => value.copy()
    None => property.get_default().copy()
    _ => property.get_default().copy()
  }
}

///|
pub fn node_has_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Bool {
  let data = node_data(node)
  node_property_bag_has(
    data.properties,
    property.get_property_id(),
    NodeStringSetValue([]),
  )
}

///|
pub fn node_clear_string_set_property(
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Unit {
  let data = node_data(node)
  data.properties = node_property_bag_remove(
    data.properties,
    property.get_property_id(),
    NodeStringSetValue([]),
  )
}

///|
pub fn node_int_property_entries(node : ElkNode) -> Array[(String, Int)] {
  let result = []
  match node_data(node).properties {
    Some(bag) =>
      for entry in bag.entries {
        match entry.value {
          NodeIntValue(value) => result.push((entry.external_id, value))
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
pub fn node_bool_property_entries(node : ElkNode) -> Array[(String, Bool)] {
  let result = []
  match node_data(node).properties {
    Some(bag) =>
      for entry in bag.entries {
        match entry.value {
          NodeBoolValue(value) => result.push((entry.external_id, value))
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
pub fn node_double_property_entries(node : ElkNode) -> Array[(String, Double)] {
  let result = []
  match node_data(node).properties {
    Some(bag) =>
      for entry in bag.entries {
        match entry.value {
          NodeDoubleValue(value) => result.push((entry.external_id, value))
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
pub fn node_kvector_property_entries(node : ElkNode) -> Array[(String, String)] {
  ignore(node_data(node))
  []
}

///|
pub fn node_string_property_entries(node : ElkNode) -> Array[(String, String)] {
  let result = []
  match node_data(node).properties {
    Some(bag) =>
      for entry in bag.entries {
        match entry.value {
          NodeStringValue(value) => result.push((entry.external_id, value))
          _ => ()
        }
      }
    None => ()
  }
  result
}

///|
pub fn node_string_set_property_entries(
  node : ElkNode,
) -> Array[(String, Array[String])] {
  let entries : Array[(String, Array[String])] = []
  match node_data(node).properties {
    Some(bag) =>
      for entry in bag.entries {
        match entry.value {
          NodeStringSetValue(value) =>
            entries.push((entry.external_id, value.copy()))
          _ => ()
        }
      }
    None => ()
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
  data.layout_options = Some(
    option_bag_set(
      data.layout_options,
      option_id_from_string(option_id),
      option_id,
      value,
    ),
  )
}

///|
pub fn node_layout_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  option_bag_entries(node_data(node).layout_options)
}

///|
pub fn node_layout_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  option_bag_get(
    node_data(node).layout_options,
    option_id_from_string(option_id),
  )
}

///|
pub fn node_layout_option_string_value_by_option_id(
  node : ElkNode,
  option_id : OptionId,
) -> String? {
  option_bag_get(node_data(node).layout_options, option_id)
}

///|
pub fn node_set_individual_spacing_option_string_by_id(
  node : ElkNode,
  option_id : String,
  value : String,
) -> Unit {
  let data = node_data(node)
  data.individual_spacings = Some(
    option_bag_set(
      data.individual_spacings,
      option_id_from_string(option_id),
      option_id,
      value,
    ),
  )
}

///|
pub fn node_individual_spacing_option_string_entries(
  node : ElkNode,
) -> Array[(String, String)] {
  option_bag_entries(node_data(node).individual_spacings)
}

///|
pub fn node_individual_spacing_option_string_value(
  node : ElkNode,
  option_id : String,
) -> String? {
  option_bag_get(
    node_data(node).individual_spacings,
    option_id_from_string(option_id),
  )
}

///|
pub fn node_individual_spacing_option_string_value_by_option_id(
  node : ElkNode,
  option_id : OptionId,
) -> String? {
  option_bag_get(node_data(node).individual_spacings, option_id)
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
    properties: clone_node_property_bag(source_data.properties),
    layout_options: clone_option_bag(source_data.layout_options),
    individual_spacings: clone_option_bag(source_data.individual_spacings),
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
