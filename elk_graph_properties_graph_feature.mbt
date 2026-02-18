///|
pub enum GraphFeature {
  SelfLoops
  InsideSelfLoops
  MultiEdges
  EdgeLabels
  Ports
  Compound
  Clusters
  Disconnected
}

///|
pub fn GraphFeature::get_description(self : GraphFeature) -> String {
  match self {
    SelfLoops => "Edges connecting a node with itself."
    InsideSelfLoops => "Self-loops routed through a node instead of around it."
    MultiEdges => "Multiple edges with the same source and target node."
    EdgeLabels => "Labels that are associated with edges."
    Ports => "Edges are connected to nodes over ports."
    Compound =>
      "Edges that connect nodes from different hierarchy levelsand are incident to compound nodes."
    Clusters =>
      "Edges that connect nodes from different clusters, but not the cluster parent nodes."
    Disconnected => "Multiple connected components."
  }
}

///|
pub fn GraphFeature::to_string(self : GraphFeature) -> String {
  match self {
    SelfLoops => "SELF_LOOPS"
    InsideSelfLoops => "INSIDE_SELF_LOOPS"
    MultiEdges => "MULTI_EDGES"
    EdgeLabels => "EDGE_LABELS"
    Ports => "PORTS"
    Compound => "COMPOUND"
    Clusters => "CLUSTERS"
    Disconnected => "DISCONNECTED"
  }
}

///|
pub fn graph_feature_values() -> Array[GraphFeature] {
  [
    SelfLoops,
    InsideSelfLoops,
    MultiEdges,
    EdgeLabels,
    Ports,
    Compound,
    Clusters,
    Disconnected,
  ]
}
