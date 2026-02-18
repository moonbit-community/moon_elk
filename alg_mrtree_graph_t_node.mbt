///|
pub type MrtreeNode = Int

///|
priv struct MrtreeNodeData {
  mut id : Int
  graph : MrtreeGraph
  label : String
  position : KVector
  size : KVector
  mut outgoing_edges : Array[MrtreeEdge]
  mut incoming_edges : Array[MrtreeEdge]
  mut origin : ElkNode?
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
let mrtree_node_store : Ref[Array[MrtreeNodeData]] = Ref::new([])

///|
fn checked_mrtree_node(node : MrtreeNode) -> Unit {
  if node < 0 || node >= mrtree_node_store.val.length() {
    abort("invalid mrtree node id")
  }
}

///|
fn set_mrtree_node_data(node : MrtreeNode, data : MrtreeNodeData) -> Unit {
  checked_mrtree_node(node)
  mrtree_node_store.val[node] = data
}

///|
pub fn new_mrtree_node(
  id : Int,
  graph : MrtreeGraph,
  label? : String = "",
) -> MrtreeNode {
  checked_mrtree_graph(graph)
  let node = mrtree_node_store.val.length()
  mrtree_node_store.val.push({
    id,
    graph,
    label,
    position: new_kvector(),
    size: new_kvector(),
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
  })
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.nodes.push(node)
  set_mrtree_graph_data(graph, graph_data)
  node
}

///|
pub fn mrtree_node_copy_properties_from_elk(
  node : MrtreeNode,
  elk_node : ElkNode,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.origin = Some(elk_node)
  node_data.priority = node_get_double_property(elk_node, mrtree_priority).to_int()
  node_data.position_constraint = node_get_double_property(
    elk_node, mrtree_position_constraint,
  ).to_int()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_id(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].id
}

///|
pub fn mrtree_node_set_id(node : MrtreeNode, id : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.id = id
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_graph(node : MrtreeNode) -> MrtreeGraph {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].graph
}

///|
pub fn mrtree_node_label(node : MrtreeNode) -> String {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].label
}

///|
pub fn mrtree_node_position(node : MrtreeNode) -> KVector {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].position
}

///|
pub fn mrtree_node_size(node : MrtreeNode) -> KVector {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].size
}

///|
pub fn mrtree_node_outgoing_edges(node : MrtreeNode) -> Array[MrtreeEdge] {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].outgoing_edges
}

///|
pub fn mrtree_node_incoming_edges(node : MrtreeNode) -> Array[MrtreeEdge] {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].incoming_edges
}

///|
pub fn mrtree_node_set_outgoing_edges(
  node : MrtreeNode,
  edges : Array[MrtreeEdge],
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.outgoing_edges = edges.copy()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_outgoing_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
  node_data.outgoing_edges.push(edge)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_incoming_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
  node_data.incoming_edges.push(edge)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_add_outgoing_edge_unique(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
  if !node_data.outgoing_edges.contains(edge) {
    mrtree_node_add_outgoing_edge(node, edge)
  }
}

///|
pub fn mrtree_node_add_incoming_edge_unique(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
  if !node_data.incoming_edges.contains(edge) {
    mrtree_node_add_incoming_edge(node, edge)
  }
}

///|
pub fn mrtree_node_remove_outgoing_edge(
  node : MrtreeNode,
  edge : MrtreeEdge,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
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
  checked_mrtree_node(node)
  checked_mrtree_edge(edge)
  let node_data = mrtree_node_store.val[node]
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
  checked_mrtree_node(node)
  let children = []
  for edge in mrtree_node_store.val[node].outgoing_edges {
    children.push(mrtree_edge_target(edge))
  }
  children
}

///|
pub fn mrtree_node_parent(node : MrtreeNode) -> MrtreeNode? {
  checked_mrtree_node(node)
  let incoming = mrtree_node_store.val[node].incoming_edges
  if incoming.is_empty() {
    None
  } else {
    Some(mrtree_edge_source(incoming[0]))
  }
}

///|
pub fn mrtree_node_is_leaf(node : MrtreeNode) -> Bool {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].outgoing_edges.is_empty()
}

///|
pub fn mrtree_node_priority(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].priority
}

///|
pub fn mrtree_node_set_tree_level(node : MrtreeNode, value : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.tree_level = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_tree_level(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].tree_level
}

///|
pub fn mrtree_node_set_fan(node : MrtreeNode, value : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.fan = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_fan(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].fan
}

///|
pub fn mrtree_node_set_descendants(node : MrtreeNode, value : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.descendants = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_descendants(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].descendants
}

///|
pub fn mrtree_node_set_internal_id(node : MrtreeNode, value : String) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.internal_id = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_internal_id(node : MrtreeNode) -> String {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].internal_id
}

///|
pub fn mrtree_node_set_position_in_level(
  node : MrtreeNode,
  value : Int,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.position_in_level = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_position_in_level(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].position_in_level
}

///|
pub fn mrtree_node_position_constraint(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].position_constraint
}

///|
pub fn mrtree_node_set_position_constraint(
  node : MrtreeNode,
  value : Int,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.position_constraint = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_set_level_height(node : MrtreeNode, value : Double) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.level_height = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_height(node : MrtreeNode) -> Double {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].level_height
}

///|
pub fn mrtree_node_set_left_neighbor(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.left_neighbor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_left_neighbor(node : MrtreeNode) -> MrtreeNode? {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].left_neighbor
}

///|
pub fn mrtree_node_set_right_neighbor(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.right_neighbor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_right_neighbor(node : MrtreeNode) -> MrtreeNode? {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].right_neighbor
}

///|
pub fn mrtree_node_set_left_sibling(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.left_sibling = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_left_sibling(node : MrtreeNode) -> MrtreeNode? {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].left_sibling
}

///|
pub fn mrtree_node_set_right_sibling(
  node : MrtreeNode,
  value : MrtreeNode?,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.right_sibling = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_right_sibling(node : MrtreeNode) -> MrtreeNode? {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].right_sibling
}

///|
pub fn mrtree_node_set_xcoor(node : MrtreeNode, value : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.xcoor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_xcoor(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].xcoor
}

///|
pub fn mrtree_node_set_ycoor(node : MrtreeNode, value : Int) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.ycoor = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_ycoor(node : MrtreeNode) -> Int {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].ycoor
}

///|
pub fn mrtree_node_set_level_min(node : MrtreeNode, value : Double) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.level_min = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_min(node : MrtreeNode) -> Double {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].level_min
}

///|
pub fn mrtree_node_set_level_max(node : MrtreeNode, value : Double) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.level_max = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_level_max(node : MrtreeNode) -> Double {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].level_max
}

///|
pub fn mrtree_node_set_compact_level_ascension(
  node : MrtreeNode,
  value : Bool,
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.compact_level_ascension = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_compact_level_ascension(node : MrtreeNode) -> Bool {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].compact_level_ascension
}

///|
pub fn mrtree_node_set_compact_constraints(
  node : MrtreeNode,
  constraints : Array[MrtreeNode],
) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.compact_constraints = constraints.copy()
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_compact_constraints(node : MrtreeNode) -> Array[MrtreeNode] {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].compact_constraints
}

///|
pub fn mrtree_node_add_compact_constraint(
  node : MrtreeNode,
  constraint : MrtreeNode,
) -> Unit {
  checked_mrtree_node(node)
  checked_mrtree_node(constraint)
  let node_data = mrtree_node_store.val[node]
  node_data.compact_constraints.push(constraint)
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_set_prelim(node : MrtreeNode, value : Double) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.prelim = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_prelim(node : MrtreeNode) -> Double {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].prelim
}

///|
pub fn mrtree_node_set_modifier(node : MrtreeNode, value : Double) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.modifier = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_modifier(node : MrtreeNode) -> Double {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].modifier
}

///|
pub fn mrtree_node_set_root(node : MrtreeNode, value : Bool) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.root = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_root(node : MrtreeNode) -> Bool {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].root
}

///|
pub fn mrtree_node_set_dummy(node : MrtreeNode, value : Bool) -> Unit {
  checked_mrtree_node(node)
  let node_data = mrtree_node_store.val[node]
  node_data.dummy = value
  set_mrtree_node_data(node, node_data)
}

///|
pub fn mrtree_node_dummy(node : MrtreeNode) -> Bool {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].dummy
}

///|
pub fn mrtree_node_origin(node : MrtreeNode) -> ElkNode? {
  checked_mrtree_node(node)
  mrtree_node_store.val[node].origin
}
