///|
let lport_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn lport_next_handle() -> Int {
  let handle = lport_next_handle_ref.val
  lport_next_handle_ref.val = handle + 1
  handle
}

///|
fn lport_internal_handle(port : LPort) -> Int {
  port.port_handle
}

///|
pub struct LPort {
  shape : LShape
  port_handle : Int
  mut owner : LNode?
  mut side : PortSide
  anchor : KVector
  mut explicitly_supplied_port_anchor : Bool
  margin : LMargin
  labels : Array[LLabel]
  incoming_edges : Array[LEdge]
  outgoing_edges : Array[LEdge]
  mut connected_to_external_nodes : Bool
  bool_properties : Map[String, Bool]
}

///|
pub fn new_l_port() -> LPort {
  {
    shape: new_l_shape(),
    port_handle: lport_next_handle(),
    owner: None,
    side: SideUndefined,
    anchor: new_kvector(),
    explicitly_supplied_port_anchor: false,
    margin: new_l_margin(),
    labels: [],
    incoming_edges: [],
    outgoing_edges: [],
    connected_to_external_nodes: true,
    bool_properties: {},
  }
}

///|
pub fn LPort::get_handle(self : LPort) -> Int {
  self.port_handle
}

///|
pub fn LPort::get_id(self : LPort) -> Int {
  self.shape.get_id()
}

///|
pub fn LPort::set_id(self : LPort, id : Int) -> Unit {
  self.shape.set_id(id)
}

///|
pub fn LPort::get_designation(self : LPort) -> String? {
  self.shape.get_designation()
}

///|
pub fn LPort::get_position(self : LPort) -> KVector {
  self.shape.get_position()
}

///|
pub fn LPort::get_size(self : LPort) -> KVector {
  self.shape.get_size()
}

///|
pub fn LPort::get_node(self : LPort) -> LNode? {
  self.owner
}

///|
pub fn LPort::set_node(self : LPort, node : LNode?) -> Unit {
  match self.owner {
    Some(old_owner) => old_owner.remove_port(self)
    None => ()
  }

  self.owner = node

  match node {
    Some(new_owner) => new_owner.add_port(self)
    None => ()
  }
}

///|
pub fn LPort::get_side(self : LPort) -> PortSide {
  self.side
}

///|
pub fn LPort::set_side(self : LPort, side : PortSide) -> Unit {
  self.side = side

  if self.is_explicitly_supplied_port_anchor() {
    return
  }

  match self.side {
    North => {
      self.anchor.x = self.get_size().x / 2.0
      self.anchor.y = 0.0
    }
    East => {
      self.anchor.x = self.get_size().x
      self.anchor.y = self.get_size().y / 2.0
    }
    South => {
      self.anchor.x = self.get_size().x / 2.0
      self.anchor.y = self.get_size().y
    }
    West => {
      self.anchor.x = 0.0
      self.anchor.y = self.get_size().y / 2.0
    }
    SideUndefined => ()
  }
}

///|
pub fn LPort::get_anchor(self : LPort) -> KVector {
  self.anchor
}

///|
pub fn LPort::is_explicitly_supplied_port_anchor(self : LPort) -> Bool {
  self.explicitly_supplied_port_anchor
}

///|
pub fn LPort::set_explicitly_supplied_port_anchor(
  self : LPort,
  fixed : Bool,
) -> Unit {
  self.explicitly_supplied_port_anchor = fixed
}

///|
pub fn LPort::get_absolute_anchor(self : LPort) -> KVector {
  match self.owner {
    Some(owner) =>
      owner.get_position().clone().add(self.get_position()).add(self.anchor)
    None => self.get_position().clone().add(self.anchor)
  }
}

///|
pub fn LPort::get_margin(self : LPort) -> LMargin {
  self.margin
}

///|
pub fn LPort::get_labels(self : LPort) -> Array[LLabel] {
  self.labels
}

///|
pub fn LPort::get_degree(self : LPort) -> Int {
  self.incoming_edges.length() + self.outgoing_edges.length()
}

///|
pub fn LPort::get_net_flow(self : LPort) -> Int {
  self.incoming_edges.length() - self.outgoing_edges.length()
}

///|
pub fn LPort::get_incoming_edges(self : LPort) -> Array[LEdge] {
  self.incoming_edges
}

///|
pub fn LPort::get_outgoing_edges(self : LPort) -> Array[LEdge] {
  self.outgoing_edges
}

///|
pub fn LPort::add_incoming_edge(self : LPort, edge : LEdge) -> Unit {
  for existing in self.incoming_edges {
    if ledge_internal_handle(existing) == ledge_internal_handle(edge) {
      return
    }
  }
  self.incoming_edges.push(edge)
}

///|
pub fn LPort::remove_incoming_edge(self : LPort, edge : LEdge) -> Unit {
  for i in 0..<self.incoming_edges.length() {
    if ledge_internal_handle(self.incoming_edges[i]) ==
      ledge_internal_handle(edge) {
      ignore(self.incoming_edges.remove(i))
      return
    }
  }
}

///|
pub fn LPort::add_outgoing_edge(self : LPort, edge : LEdge) -> Unit {
  for existing in self.outgoing_edges {
    if ledge_internal_handle(existing) == ledge_internal_handle(edge) {
      return
    }
  }
  self.outgoing_edges.push(edge)
}

///|
pub fn LPort::remove_outgoing_edge(self : LPort, edge : LEdge) -> Unit {
  for i in 0..<self.outgoing_edges.length() {
    if ledge_internal_handle(self.outgoing_edges[i]) ==
      ledge_internal_handle(edge) {
      ignore(self.outgoing_edges.remove(i))
      return
    }
  }
}

///|
pub fn LPort::get_connected_edges(self : LPort) -> Array[LEdge] {
  let result = []
  for edge in self.incoming_edges {
    result.push(edge)
  }
  for edge in self.outgoing_edges {
    let mut exists = false
    for existing in result {
      if ledge_internal_handle(existing) == ledge_internal_handle(edge) {
        exists = true
        break
      }
    }
    if !exists {
      result.push(edge)
    }
  }
  result
}

///|
pub fn LPort::is_connected_to_external_nodes(self : LPort) -> Bool {
  self.connected_to_external_nodes
}

///|
pub fn LPort::set_connected_to_external_nodes(
  self : LPort,
  connected : Bool,
) -> Unit {
  self.connected_to_external_nodes = connected
}

///|
pub fn LPort::get_connected_ports(self : LPort) -> Array[LPort] {
  let result = []

  for edge in self.incoming_edges {
    match edge.get_source() {
      Some(source) => {
        let mut exists = false
        for existing in result {
          if lport_internal_handle(existing) == lport_internal_handle(source) {
            exists = true
            break
          }
        }
        if !exists {
          result.push(source)
        }
      }
      None => ()
    }
  }

  for edge in self.outgoing_edges {
    match edge.get_target() {
      Some(target) => {
        let mut exists = false
        for existing in result {
          if lport_internal_handle(existing) == lport_internal_handle(target) {
            exists = true
            break
          }
        }
        if !exists {
          result.push(target)
        }
      }
      None => ()
    }
  }

  result
}

///|
pub fn LPort::set_property_bool(
  self : LPort,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LPort::get_property_bool(
  self : LPort,
  property : IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LPort::to_string(self : LPort) -> String {
  match self.get_designation() {
    Some(designation) => "p_" + designation
    None => "port"
  }
}
