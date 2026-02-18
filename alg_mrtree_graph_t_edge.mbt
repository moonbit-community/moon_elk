///|
pub type MrtreeEdge = Int

///|
priv struct MrtreeEdgeData {
  source : MrtreeNode
  target : MrtreeNode
  bend_points : KVectorChain
  mut origin : ElkEdge?
}

///|
let mrtree_edge_store : Ref[Array[MrtreeEdgeData]] = Ref::new([])

///|
fn checked_mrtree_edge(edge : MrtreeEdge) -> Unit {
  if edge < 0 || edge >= mrtree_edge_store.val.length() {
    abort("invalid mrtree edge id")
  }
}

///|
fn set_mrtree_edge_data(edge : MrtreeEdge, data : MrtreeEdgeData) -> Unit {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge] = data
}

///|
pub fn new_mrtree_edge(source : MrtreeNode, target : MrtreeNode) -> MrtreeEdge {
  checked_mrtree_node(source)
  checked_mrtree_node(target)
  let edge = mrtree_edge_store.val.length()
  mrtree_edge_store.val.push({
    source,
    target,
    bend_points: new_kvector_chain(),
    origin: None,
  })
  let source_data = mrtree_node_store.val[source]
  source_data.outgoing_edges.push(edge)
  set_mrtree_node_data(source, source_data)
  let target_data = mrtree_node_store.val[target]
  target_data.incoming_edges.push(edge)
  set_mrtree_node_data(target, target_data)
  let graph = source_data.graph
  let graph_data = mrtree_graph_store.val[graph]
  graph_data.edges.push(edge)
  set_mrtree_graph_data(graph, graph_data)
  edge
}

///|
pub fn mrtree_edge_set_origin(edge : MrtreeEdge, origin : ElkEdge?) -> Unit {
  checked_mrtree_edge(edge)
  let edge_data = mrtree_edge_store.val[edge]
  edge_data.origin = origin
  set_mrtree_edge_data(edge, edge_data)
}

///|
pub fn mrtree_edge_origin(edge : MrtreeEdge) -> ElkEdge? {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].origin
}

///|
pub fn mrtree_edge_source(edge : MrtreeEdge) -> MrtreeNode {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].source
}

///|
pub fn mrtree_edge_target(edge : MrtreeEdge) -> MrtreeNode {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].target
}

///|
pub fn mrtree_edge_bend_points(edge : MrtreeEdge) -> KVectorChain {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].bend_points
}
