///|
pub struct IProperty[T] {
  id : String
  default_value : T
  clone_required : Bool
  clone_default_fn : ((T) -> T?)?
}

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

///|
pub fn[T] new_property(id : String, default_value : T) -> IProperty[T] {
  { id, default_value, clone_required: false, clone_default_fn: None }
}

///|
pub fn[T] new_property_cloneable(
  id : String,
  default_value : T,
  clone_default_fn : (T) -> T?,
) -> IProperty[T] {
  {
    id,
    default_value,
    clone_required: true,
    clone_default_fn: Some(clone_default_fn),
  }
}

///|
pub fn[T] new_property_cloneable_without_clone(
  id : String,
  default_value : T,
) -> IProperty[T] {
  { id, default_value, clone_required: true, clone_default_fn: None }
}

///|
pub fn[T] IProperty::get_id(self : IProperty[T]) -> String {
  self.id
}

///|
pub fn[T] IProperty::get_default(self : IProperty[T]) -> T {
  if self.clone_required {
    match self.clone_default_fn {
      Some(clone_default) =>
        match clone_default(self.default_value) {
          Some(cloned) => cloned
          None => abort("Couldn't clone property")
        }
      None => abort("Couldn't clone property")
    }
  } else {
    self.default_value
  }
}
