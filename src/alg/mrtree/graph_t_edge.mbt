///|
pub type MrtreeEdge = Int

///|
priv struct MrtreeEdgeData {
  mut source : MrtreeNode
  mut target : MrtreeNode
  labels : Array[MrtreeLabel]
  bend_points : @core.KVectorChain
  mut origin : @graph.ElkEdge?
}

///|
let mrtree_edge_store : Ref[Array[MrtreeEdgeData]] = Ref::new([])

///|
fn checked_mrtree_edge(edge : MrtreeEdge) -> Unit {
  if edge < 0 || edge >= mrtree_edge_store.val.length() {
    @core.layout_runtime_report_unsupported_configuration(
      "invalid mrtree edge id",
    )
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
    labels: [],
    bend_points: @core.new_kvector_chain(),
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
pub fn mrtree_edge_set_origin(
  edge : MrtreeEdge,
  origin : @graph.ElkEdge?,
) -> Unit {
  checked_mrtree_edge(edge)
  let edge_data = mrtree_edge_store.val[edge]
  edge_data.origin = origin
  set_mrtree_edge_data(edge, edge_data)
}

///|
pub fn mrtree_edge_origin(edge : MrtreeEdge) -> @graph.ElkEdge? {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].origin
}

///|
pub fn mrtree_edge_source(edge : MrtreeEdge) -> MrtreeNode {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].source
}

///|
pub fn mrtree_edge_set_source(edge : MrtreeEdge, source : MrtreeNode) -> Unit {
  checked_mrtree_edge(edge)
  checked_mrtree_node(source)
  let edge_data = mrtree_edge_store.val[edge]
  if edge_data.source != source {
    mrtree_node_remove_outgoing_edge(edge_data.source, edge)
    mrtree_node_add_outgoing_edge_unique(source, edge)
    edge_data.source = source
    set_mrtree_edge_data(edge, edge_data)
  }
}

///|
pub fn mrtree_edge_target(edge : MrtreeEdge) -> MrtreeNode {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].target
}

///|
pub fn mrtree_edge_set_target(edge : MrtreeEdge, target : MrtreeNode) -> Unit {
  checked_mrtree_edge(edge)
  checked_mrtree_node(target)
  let edge_data = mrtree_edge_store.val[edge]
  if edge_data.target != target {
    mrtree_node_remove_incoming_edge(edge_data.target, edge)
    mrtree_node_add_incoming_edge_unique(target, edge)
    edge_data.target = target
    set_mrtree_edge_data(edge, edge_data)
  }
}

///|
pub fn mrtree_edge_labels(edge : MrtreeEdge) -> Array[MrtreeLabel] {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].labels
}

///|
pub fn mrtree_edge_bend_points(edge : MrtreeEdge) -> @core.KVectorChain {
  checked_mrtree_edge(edge)
  mrtree_edge_store.val[edge].bend_points
}

///|
pub fn mrtree_edge_to_string(edge : MrtreeEdge) -> String {
  checked_mrtree_edge(edge)
  let edge_data = mrtree_edge_store.val[edge]
  "\{mrtree_node_to_string(edge_data.source)}->\{mrtree_node_to_string(edge_data.target)}"
}
