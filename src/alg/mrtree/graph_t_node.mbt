///|
pub struct MrtreeNode {
  priv mut data : MrtreeNodeData
  priv handle : Int
}

///|
pub impl Eq for MrtreeNode with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl Hash for MrtreeNode with fn hash(self) {
  self.handle
}

///|
pub impl Hash for MrtreeNode with fn hash_combine(self, hasher) {
  hasher.combine_int(self.handle)
}

///|
priv struct MrtreeNodeData {
  mut id : Int
  graph : MrtreeGraph
  label : String
  position : @core.KVector
  size : @core.KVector
  mut outgoing_edges : Array[MrtreeEdge]
  mut incoming_edges : Array[MrtreeEdge]
  mut origin : @graph.ElkNode?
  mut priority : Int
  mut tree_level : Int
  mut position_constraint : Int
  mut fan : Int
  mut descendants : Int
  mut internal_id : String
  mut position_in_level : Int
  mut level_height : Double
  mut left_neighbor : MrtreeNode?
  mut right_neighbor : MrtreeNode?
  mut left_sibling : MrtreeNode?
  mut right_sibling : MrtreeNode?
  mut xcoor : Int
  mut ycoor : Int
  mut level_min : Double
  mut level_max : Double
  mut compact_level_ascension : Bool
  mut compact_constraints : Array[MrtreeNode]
  mut prelim : Double
  mut modifier : Double
  mut root : Bool
  mut dummy : Bool
}

///|
fn set_mrtree_node_data(node : MrtreeNode, data : MrtreeNodeData) -> Unit {
  node.data = data
}

///|
pub fn new_mrtree_node(
  id : Int,
  graph : MrtreeGraph,
  label? : String = "",
) -> MrtreeNode {
  let node : MrtreeNode = {
    data: {
      id,
      graph,
      label,
      position: @core.new_kvector(),
      size: @core.new_kvector(),
      outgoing_edges: [],
      incoming_edges: [],
      origin: None,
      priority: 1,
      tree_level: 0,
      position_constraint: -1,
      fan: 0,
      descendants: 1,
      internal_id: "",
      position_in_level: 0,
      level_height: 0.0,
      left_neighbor: None,
      right_neighbor: None,
      left_sibling: None,
      right_sibling: None,
      xcoor: 0,
      ycoor: 0,
      level_min: 0.0,
      level_max: 0.0,
      compact_level_ascension: false,
      compact_constraints: [],
      prelim: 0.0,
      modifier: 0.0,
      root: false,
      dummy: false,
    },
    handle: graph.data.nodes.length(),
  }
  let graph_data = graph.data
  graph_data.nodes.push(node)
  set_mrtree_graph_data(graph, graph_data)
  node
}

///|
pub fn mrtree_node_copy_properties_from_elk(
  node : MrtreeNode,
  elk_node : @graph.ElkNode,
) -> Unit {
  let node_data = node.data
  node_data.origin = Some(elk_node)
  node_data.priority = @graph.node_get_double_property(
    elk_node, mrtree_priority,
  ).to_int()
  node_data.position_constraint = @graph.node_get_double_property(
    elk_node, mrtree_position_constraint,
  ).to_int()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_id(node : MrtreeNode) -> Int {
  node.data.id
}

///|
pub fn mrtree_node_set_id(node : MrtreeNode, id : Int) -> Unit {
  let node_data = node.data
  node_data.id = id
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_graph(node : MrtreeNode) -> MrtreeGraph {
  node.data.graph
}

///|
pub fn mrtree_node_label(node : MrtreeNode) -> String {
  node.data.label
}

///|
pub fn mrtree_node_to_string(node : MrtreeNode) -> String {
  let node_data = node.data
  if node_data.label.is_empty() {
    "n_" + node_data.id.to_string()
  } else {
    "n_" + node_data.label
  }
}

///|
pub fn mrtree_node_position(node : MrtreeNode) -> @core.KVector {
  node.data.position
}

///|
pub fn mrtree_node_size(node : MrtreeNode) -> @core.KVector {
  node.data.size
}

///|
pub fn mrtree_node_outgoing_edges(node : MrtreeNode) -> Array[MrtreeEdge] {
  node.data.outgoing_edges
}

///|
pub fn mrtree_node_incoming_edges(node : MrtreeNode) -> Array[MrtreeEdge] {
  node.data.incoming_edges
}

///|
pub fn mrtree_node_set_outgoing_edges(
  node : MrtreeNode,
  edges : Array[MrtreeEdge],
) -> Unit {
  let node_data = node.data
  node_data.outgoing_edges = edges.copy()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_outgoing_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  node_data.outgoing_edges.push(edge)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_incoming_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  node_data.incoming_edges.push(edge)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_outgoing_edge_unique(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  if !node_data.outgoing_edges.contains(edge) {
    mrtree_node_add_outgoing_edge(node, edge)
  }
}

///|
pub fn mrtree_node_add_incoming_edge_unique(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  if !node_data.incoming_edges.contains(edge) {
    mrtree_node_add_incoming_edge(node, edge)
  }
}

///|
pub fn mrtree_node_remove_outgoing_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  let filtered = []
  for current in node_data.outgoing_edges {
    if current != edge {
      filtered.push(current)
    }
  }
  node_data.outgoing_edges = filtered
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_remove_incoming_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  let node_data = node.data
  let filtered = []
  for current in node_data.incoming_edges {
    if current != edge {
      filtered.push(current)
    }
  }
  node_data.incoming_edges = filtered
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_children_copy(node : MrtreeNode) -> Array[MrtreeNode] {
  let children = []
  for edge in node.data.outgoing_edges {
    children.push(mrtree_edge_target(edge))
  }
  children
}

///|
pub fn mrtree_node_parent(node : MrtreeNode) -> MrtreeNode? {
  let incoming = node.data.incoming_edges
  if incoming.is_empty() {
    None
  } else {
    Some(mrtree_edge_source(incoming[0]))
  }
}

///|
pub fn mrtree_node_is_leaf(node : MrtreeNode) -> Bool {
  node.data.outgoing_edges.is_empty()
}

///|
pub fn mrtree_node_priority(node : MrtreeNode) -> Int {
  node.data.priority
}

///|
pub fn mrtree_node_set_tree_level(node : MrtreeNode, value : Int) -> Unit {
  let node_data = node.data
  node_data.tree_level = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_tree_level(node : MrtreeNode) -> Int {
  node.data.tree_level
}

///|
pub fn mrtree_node_set_fan(node : MrtreeNode, value : Int) -> Unit {
  let node_data = node.data
  node_data.fan = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_fan(node : MrtreeNode) -> Int {
  node.data.fan
}

///|
pub fn mrtree_node_set_descendants(node : MrtreeNode, value : Int) -> Unit {
  let node_data = node.data
  node_data.descendants = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_descendants(node : MrtreeNode) -> Int {
  node.data.descendants
}

///|
pub fn mrtree_node_set_internal_id(node : MrtreeNode, value : String) -> Unit {
  let node_data = node.data
  node_data.internal_id = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_internal_id(node : MrtreeNode) -> String {
  node.data.internal_id
}

///|
pub fn mrtree_node_set_position_in_level(
  node : MrtreeNode,
  value : Int,
) -> Unit {
  let node_data = node.data
  node_data.position_in_level = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_position_in_level(node : MrtreeNode) -> Int {
  node.data.position_in_level
}

///|
pub fn mrtree_node_position_constraint(node : MrtreeNode) -> Int {
  node.data.position_constraint
}

///|
pub fn mrtree_node_set_position_constraint(
  node : MrtreeNode,
  value : Int,
) -> Unit {
  let node_data = node.data
  node_data.position_constraint = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_set_level_height(node : MrtreeNode, value : Double) -> Unit {
  let node_data = node.data
  node_data.level_height = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_height(node : MrtreeNode) -> Double {
  node.data.level_height
}

///|
pub fn mrtree_node_set_left_neighbor(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  let node_data = node.data
  node_data.left_neighbor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_left_neighbor(node : MrtreeNode) -> MrtreeNode? {
  node.data.left_neighbor
}

///|
pub fn mrtree_node_set_right_neighbor(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  let node_data = node.data
  node_data.right_neighbor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_right_neighbor(node : MrtreeNode) -> MrtreeNode? {
  node.data.right_neighbor
}

///|
pub fn mrtree_node_set_left_sibling(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  let node_data = node.data
  node_data.left_sibling = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_left_sibling(node : MrtreeNode) -> MrtreeNode? {
  node.data.left_sibling
}

///|
pub fn mrtree_node_set_right_sibling(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  let node_data = node.data
  node_data.right_sibling = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_right_sibling(node : MrtreeNode) -> MrtreeNode? {
  node.data.right_sibling
}

///|
pub fn mrtree_node_set_xcoor(node : MrtreeNode, value : Int) -> Unit {
  let node_data = node.data
  node_data.xcoor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_xcoor(node : MrtreeNode) -> Int {
  node.data.xcoor
}

///|
pub fn mrtree_node_set_ycoor(node : MrtreeNode, value : Int) -> Unit {
  let node_data = node.data
  node_data.ycoor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_ycoor(node : MrtreeNode) -> Int {
  node.data.ycoor
}

///|
pub fn mrtree_node_set_level_min(node : MrtreeNode, value : Double) -> Unit {
  let node_data = node.data
  node_data.level_min = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_min(node : MrtreeNode) -> Double {
  node.data.level_min
}

///|
pub fn mrtree_node_set_level_max(node : MrtreeNode, value : Double) -> Unit {
  let node_data = node.data
  node_data.level_max = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_max(node : MrtreeNode) -> Double {
  node.data.level_max
}

///|
pub fn mrtree_node_set_compact_level_ascension(
  node : MrtreeNode,
  value : Bool,
) -> Unit {
  let node_data = node.data
  node_data.compact_level_ascension = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_compact_level_ascension(node : MrtreeNode) -> Bool {
  node.data.compact_level_ascension
}

///|
pub fn mrtree_node_set_compact_constraints(
  node : MrtreeNode,
  constraints : Array[MrtreeNode],
) -> Unit {
  let node_data = node.data
  node_data.compact_constraints = constraints.copy()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_compact_constraints(node : MrtreeNode) -> Array[MrtreeNode] {
  node.data.compact_constraints
}

///|
pub fn mrtree_node_add_compact_constraint(
  node : MrtreeNode,
  constraint : MrtreeNode,
) -> Unit {
  let node_data = node.data
  node_data.compact_constraints.push(constraint)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_set_prelim(node : MrtreeNode, value : Double) -> Unit {
  let node_data = node.data
  node_data.prelim = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_prelim(node : MrtreeNode) -> Double {
  node.data.prelim
}

///|
pub fn mrtree_node_set_modifier(node : MrtreeNode, value : Double) -> Unit {
  let node_data = node.data
  node_data.modifier = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_modifier(node : MrtreeNode) -> Double {
  node.data.modifier
}

///|
pub fn mrtree_node_set_root(node : MrtreeNode, value : Bool) -> Unit {
  let node_data = node.data
  node_data.root = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_root(node : MrtreeNode) -> Bool {
  node.data.root
}

///|
pub fn mrtree_node_set_dummy(node : MrtreeNode, value : Bool) -> Unit {
  let node_data = node.data
  node_data.dummy = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_dummy(node : MrtreeNode) -> Bool {
  node.data.dummy
}

///|
pub fn mrtree_node_origin(node : MrtreeNode) -> @graph.ElkNode? {
  node.data.origin
}
