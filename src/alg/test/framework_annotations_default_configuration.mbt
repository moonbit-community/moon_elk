///|
pub struct DefaultConfiguration {
  edges : Bool
  nodes : Bool
  ports : Bool
  edge_labels : Bool
}

///|
pub fn new_default_configuration(
  edges? : Bool = true,
  nodes? : Bool = true,
  ports? : Bool = true,
  edge_labels? : Bool = false,
) -> DefaultConfiguration {
  { edges, nodes, ports, edge_labels }
}

///|
pub fn DefaultConfiguration::edges_enabled(self : DefaultConfiguration) -> Bool {
  self.edges
}

///|
pub fn DefaultConfiguration::nodes_enabled(self : DefaultConfiguration) -> Bool {
  self.nodes
}

///|
pub fn DefaultConfiguration::ports_enabled(self : DefaultConfiguration) -> Bool {
  self.ports
}

///|
pub fn DefaultConfiguration::edge_labels_enabled(
  self : DefaultConfiguration,
) -> Bool {
  self.edge_labels
}
