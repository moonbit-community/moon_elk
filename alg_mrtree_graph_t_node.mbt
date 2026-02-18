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
