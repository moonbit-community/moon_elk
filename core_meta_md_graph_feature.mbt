///|
pub enum CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureSelfLoops
  CoreMetaMdGraphFeatureInsideSelfLoops
  CoreMetaMdGraphFeatureMultiEdges
  CoreMetaMdGraphFeatureEdgeLabels
  CoreMetaMdGraphFeaturePorts
  CoreMetaMdGraphFeatureCompound
  CoreMetaMdGraphFeatureClusters
  CoreMetaMdGraphFeatureDisconnected
}

///|
pub fn core_meta_md_graph_feature_self_loops() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureSelfLoops
}

///|
pub fn core_meta_md_graph_feature_inside_self_loops() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureInsideSelfLoops
}

///|
pub fn core_meta_md_graph_feature_multi_edges() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureMultiEdges
}

///|
pub fn core_meta_md_graph_feature_edge_labels() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureEdgeLabels
}

///|
pub fn core_meta_md_graph_feature_ports() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeaturePorts
}

///|
pub fn core_meta_md_graph_feature_compound() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureCompound
}

///|
pub fn core_meta_md_graph_feature_clusters() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureClusters
}

///|
pub fn core_meta_md_graph_feature_disconnected() -> CoreMetaMdGraphFeature {
  CoreMetaMdGraphFeatureDisconnected
}

///|
pub fn core_meta_md_graph_feature_value(
  feature : CoreMetaMdGraphFeature,
) -> Int {
  match feature {
    CoreMetaMdGraphFeatureSelfLoops => 0
    CoreMetaMdGraphFeatureInsideSelfLoops => 1
    CoreMetaMdGraphFeatureMultiEdges => 2
    CoreMetaMdGraphFeatureEdgeLabels => 3
    CoreMetaMdGraphFeaturePorts => 4
    CoreMetaMdGraphFeatureCompound => 5
    CoreMetaMdGraphFeatureClusters => 6
    CoreMetaMdGraphFeatureDisconnected => 7
  }
}

///|
pub fn core_meta_md_graph_feature_name(
  feature : CoreMetaMdGraphFeature,
) -> String {
  match feature {
    CoreMetaMdGraphFeatureSelfLoops => "self_loops"
    CoreMetaMdGraphFeatureInsideSelfLoops => "inside_self_loops"
    CoreMetaMdGraphFeatureMultiEdges => "multi_edges"
    CoreMetaMdGraphFeatureEdgeLabels => "edge_labels"
    CoreMetaMdGraphFeaturePorts => "ports"
    CoreMetaMdGraphFeatureCompound => "compound"
    CoreMetaMdGraphFeatureClusters => "clusters"
    CoreMetaMdGraphFeatureDisconnected => "disconnected"
  }
}

///|
pub fn core_meta_md_graph_feature_literal(
  feature : CoreMetaMdGraphFeature,
) -> String {
  core_meta_md_graph_feature_name(feature)
}

///|
pub fn core_meta_md_graph_feature_from_string(
  literal : String,
) -> CoreMetaMdGraphFeature? {
  if literal == "self_loops" {
    Some(CoreMetaMdGraphFeatureSelfLoops)
  } else if literal == "inside_self_loops" {
    Some(CoreMetaMdGraphFeatureInsideSelfLoops)
  } else if literal == "multi_edges" {
    Some(CoreMetaMdGraphFeatureMultiEdges)
  } else if literal == "edge_labels" {
    Some(CoreMetaMdGraphFeatureEdgeLabels)
  } else if literal == "ports" {
    Some(CoreMetaMdGraphFeaturePorts)
  } else if literal == "compound" {
    Some(CoreMetaMdGraphFeatureCompound)
  } else if literal == "clusters" {
    Some(CoreMetaMdGraphFeatureClusters)
  } else if literal == "disconnected" {
    Some(CoreMetaMdGraphFeatureDisconnected)
  } else {
    None
  }
}

///|
pub fn core_meta_md_graph_feature_from_name(
  name : String,
) -> CoreMetaMdGraphFeature? {
  core_meta_md_graph_feature_from_string(name)
}

///|
pub fn core_meta_md_graph_feature_from_int(
  value : Int,
) -> CoreMetaMdGraphFeature? {
  if value == 0 {
    Some(CoreMetaMdGraphFeatureSelfLoops)
  } else if value == 1 {
    Some(CoreMetaMdGraphFeatureInsideSelfLoops)
  } else if value == 2 {
    Some(CoreMetaMdGraphFeatureMultiEdges)
  } else if value == 3 {
    Some(CoreMetaMdGraphFeatureEdgeLabels)
  } else if value == 4 {
    Some(CoreMetaMdGraphFeaturePorts)
  } else if value == 5 {
    Some(CoreMetaMdGraphFeatureCompound)
  } else if value == 6 {
    Some(CoreMetaMdGraphFeatureClusters)
  } else if value == 7 {
    Some(CoreMetaMdGraphFeatureDisconnected)
  } else {
    None
  }
}

///|
pub fn core_meta_md_graph_feature_to_string(
  feature : CoreMetaMdGraphFeature,
) -> String {
  core_meta_md_graph_feature_literal(feature)
}
