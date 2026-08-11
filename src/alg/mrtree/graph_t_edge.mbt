///|
pub struct MrtreeEdge {
  priv mut data : MrtreeEdgeData
}

///|
pub impl Eq for MrtreeEdge with fn equal(self, other) {
  physical_equal(self, other)
}

///|
priv struct MrtreeEdgeData {
  mut source : MrtreeNode
  mut target : MrtreeNode
  labels : Array[MrtreeLabel]
  bend_points : @core.KVectorChain
  mut origin : @graph.ElkEdge?
}

///|
fn set_mrtree_edge_data(edge : MrtreeEdge, data : MrtreeEdgeData) -> Unit {
  edge.data = data
}

///|
pub fn new_mrtree_edge(source : MrtreeNode, target : MrtreeNode) -> MrtreeEdge {
  let edge : MrtreeEdge = {
    data: {
      source,
      target,
      labels: [],
      bend_points: @core.new_kvector_chain(),
      origin: None,
    },
  }
  let source_data = source.data
  source_data.outgoing_edges.push(edge)
  set_mrtree_node_data(source, source_data)
  let target_data = target.data
  target_data.incoming_edges.push(edge)
  set_mrtree_node_data(target, target_data)
  let graph = source_data.graph
  let graph_data = graph.data
  graph_data.edges.push(edge)
  set_mrtree_graph_data(graph, graph_data)
  edge
}

///|
pub fn mrtree_edge_set_origin(
  edge : MrtreeEdge,
  origin : @graph.ElkEdge?,
) -> Unit {
  let edge_data = edge.data
  edge_data.origin = origin
  set_mrtree_edge_data(edge, edge_data)
}

///|
pub fn mrtree_edge_origin(edge : MrtreeEdge) -> @graph.ElkEdge? {
  edge.data.origin
}

///|
pub fn mrtree_edge_source(edge : MrtreeEdge) -> MrtreeNode {
  edge.data.source
}

///|
pub fn mrtree_edge_set_source(edge : MrtreeEdge, source : MrtreeNode) -> Unit {
  let edge_data = edge.data
  if edge_data.source != source {
    mrtree_node_remove_outgoing_edge(edge_data.source, edge)
    mrtree_node_add_outgoing_edge_unique(source, edge)
    edge_data.source = source
    set_mrtree_edge_data(edge, edge_data)
  }
}

///|
pub fn mrtree_edge_target(edge : MrtreeEdge) -> MrtreeNode {
  edge.data.target
}

///|
pub fn mrtree_edge_set_target(edge : MrtreeEdge, target : MrtreeNode) -> Unit {
  let edge_data = edge.data
  if edge_data.target != target {
    mrtree_node_remove_incoming_edge(edge_data.target, edge)
    mrtree_node_add_incoming_edge_unique(target, edge)
    edge_data.target = target
    set_mrtree_edge_data(edge, edge_data)
  }
}

///|
pub fn mrtree_edge_labels(edge : MrtreeEdge) -> Array[MrtreeLabel] {
  edge.data.labels
}

///|
pub fn mrtree_edge_bend_points(edge : MrtreeEdge) -> @core.KVectorChain {
  edge.data.bend_points
}

///|
pub fn mrtree_edge_to_string(edge : MrtreeEdge) -> String {
  let edge_data = edge.data
  "\{mrtree_node_to_string(edge_data.source)}->\{mrtree_node_to_string(edge_data.target)}"
}
