///|
fn cross_hierarchy_edge_require_source_port(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(port) => port
    None => abort("edge has no source port")
  }
}

///|
fn cross_hierarchy_edge_require_target_port(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(port) => port
    None => abort("edge has no target port")
  }
}

///|
fn cross_hierarchy_edge_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(node) => node
    None => abort("port has no owner node")
  }
}

///|
fn cross_hierarchy_edge_port_type_to_string(port_type : PortType) -> String {
  match port_type {
    Input => "INPUT"
    Output => "OUTPUT"
    Undefined => "UNDEFINED"
  }
}

///|
fn cross_hierarchy_edge_resolve_external_port_origin(port : LPort) -> LPort {
  let node = cross_hierarchy_edge_require_port_node(port)
  match node.get_type() {
    NodeType::ExternalPort => ()
    _ => return port
  }

  match node.get_property_l_port(internal_properties_origin_l_port) {
    Some(origin_port) => origin_port
    None => port
  }
}

///|
pub struct CrossHierarchyEdge {
  new_edge : LEdge
  graph : LGraph
  port_type : PortType
}

///|
pub fn new_cross_hierarchy_edge(
  new_edge : LEdge,
  graph : LGraph,
  port_type : PortType,
) -> CrossHierarchyEdge {
  { new_edge, graph, port_type }
}

///|
pub fn CrossHierarchyEdge::to_string(self : CrossHierarchyEdge) -> String {
  cross_hierarchy_edge_port_type_to_string(self.port_type) +
  ":" +
  self.new_edge.to_string()
}

///|
pub fn CrossHierarchyEdge::get_edge(self : CrossHierarchyEdge) -> LEdge {
  self.new_edge
}

///|
pub fn CrossHierarchyEdge::get_graph(self : CrossHierarchyEdge) -> LGraph {
  self.graph
}

///|
pub fn CrossHierarchyEdge::get_type(self : CrossHierarchyEdge) -> PortType {
  self.port_type
}

///|
pub fn CrossHierarchyEdge::get_actual_source(
  self : CrossHierarchyEdge,
) -> LPort {
  let source = cross_hierarchy_edge_require_source_port(self.new_edge)
  cross_hierarchy_edge_resolve_external_port_origin(source)
}

///|
pub fn CrossHierarchyEdge::get_actual_target(
  self : CrossHierarchyEdge,
) -> LPort {
  let target = cross_hierarchy_edge_require_target_port(self.new_edge)
  cross_hierarchy_edge_resolve_external_port_origin(target)
}
