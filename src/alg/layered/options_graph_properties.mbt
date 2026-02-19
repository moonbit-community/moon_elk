///|
pub enum GraphProperties {
  Comments
  ExternalPorts
  Hyperedges
  Hypernodes
  NonFreePorts
  NorthSouthPorts
  SelfLoops
  CenterLabels
  EndLabels
  Partitions
}

///|
pub fn graph_properties_values() -> Array[GraphProperties] {
  [
    Comments,
    ExternalPorts,
    Hyperedges,
    Hypernodes,
    NonFreePorts,
    NorthSouthPorts,
    SelfLoops,
    CenterLabels,
    EndLabels,
    Partitions,
  ]
}

///|
pub fn graph_properties_to_string(property : GraphProperties) -> String {
  match property {
    Comments => "COMMENTS"
    ExternalPorts => "EXTERNAL_PORTS"
    Hyperedges => "HYPEREDGES"
    Hypernodes => "HYPERNODES"
    NonFreePorts => "NON_FREE_PORTS"
    NorthSouthPorts => "NORTH_SOUTH_PORTS"
    SelfLoops => "SELF_LOOPS"
    CenterLabels => "CENTER_LABELS"
    EndLabels => "END_LABELS"
    Partitions => "PARTITIONS"
  }
}
