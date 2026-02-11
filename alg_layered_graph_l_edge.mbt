///|
let ledge_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn ledge_next_handle() -> Int {
  let handle = ledge_next_handle_ref.val
  ledge_next_handle_ref.val = handle + 1
  handle
}

///|
fn ledge_internal_handle(edge : LEdge) -> Int {
  edge.edge_handle
}

///|
pub struct LEdge {
  graph_element : LGraphElement
  edge_handle : Int
  bend_points : KVectorChain
  mut source : LPort?
  mut target : LPort?
  labels : Array[LLabel]
  bool_properties : Map[String, Bool]
}

///|
pub fn new_l_edge() -> LEdge {
  {
    graph_element: new_l_graph_element(),
    edge_handle: ledge_next_handle(),
    bend_points: new_kvector_chain(),
    source: None,
    target: None,
    labels: [],
    bool_properties: {},
  }
}

///|
pub fn LEdge::get_handle(self : LEdge) -> Int {
  self.edge_handle
}

///|
pub fn LEdge::get_id(self : LEdge) -> Int {
  self.graph_element.get_id()
}

///|
pub fn LEdge::set_id(self : LEdge, id : Int) -> Unit {
  self.graph_element.set_id(id)
}

///|
pub fn LEdge::set_origin_identifier(self : LEdge, identifier : String?) -> Unit {
  self.graph_element.set_origin_identifier(identifier)
}

///|
pub fn LEdge::get_source(self : LEdge) -> LPort? {
  self.source
}

///|
pub fn LEdge::set_source(self : LEdge, source : LPort?) -> Unit {
  match self.source {
    Some(old_source) => old_source.remove_outgoing_edge(self)
    None => ()
  }

  self.source = source

  match source {
    Some(new_source) => new_source.add_outgoing_edge(self)
    None => ()
  }
}

///|
pub fn LEdge::get_target(self : LEdge) -> LPort? {
  self.target
}

///|
pub fn LEdge::set_target(self : LEdge, target : LPort?) -> Unit {
  match self.target {
    Some(old_target) => old_target.remove_incoming_edge(self)
    None => ()
  }

  self.target = target

  match target {
    Some(new_target) => new_target.add_incoming_edge(self)
    None => ()
  }
}

///|
pub fn LEdge::is_self_loop(self : LEdge) -> Bool {
  match (self.source, self.target) {
    (Some(source), Some(target)) =>
      match (source.get_node(), target.get_node()) {
        (Some(source_node), Some(target_node)) =>
          lnode_internal_handle(source_node) ==
          lnode_internal_handle(target_node)
        _ => false
      }
    _ => false
  }
}

///|
pub fn LEdge::is_in_layer_edge(self : LEdge) -> Bool {
  if self.is_self_loop() {
    return false
  }
  match (self.source, self.target) {
    (Some(source), Some(target)) =>
      match (source.get_node(), target.get_node()) {
        (Some(source_node), Some(target_node)) =>
          match (source_node.get_layer(), target_node.get_layer()) {
            (Some(source_layer), Some(target_layer)) =>
              layer_internal_handle(source_layer) ==
              layer_internal_handle(target_layer)
            _ => false
          }
        _ => false
      }
    _ => false
  }
}

///|
pub fn LEdge::get_bend_points(self : LEdge) -> KVectorChain {
  self.bend_points
}

///|
pub fn LEdge::get_labels(self : LEdge) -> Array[LLabel] {
  self.labels
}

///|
pub fn LEdge::get_other_port(self : LEdge, port : LPort) -> LPort {
  match (self.source, self.target) {
    (Some(source), Some(target)) =>
      if lport_internal_handle(port) == lport_internal_handle(source) {
        target
      } else if lport_internal_handle(port) == lport_internal_handle(target) {
        source
      } else {
        abort("'port' must be either source or target of the edge")
      }
    _ => abort("edge is not fully connected")
  }
}

///|
pub fn LEdge::get_other_node(self : LEdge, node : LNode) -> LNode {
  match (self.source, self.target) {
    (Some(source), Some(target)) =>
      match (source.get_node(), target.get_node()) {
        (Some(source_node), Some(target_node)) =>
          if lnode_internal_handle(node) == lnode_internal_handle(source_node) {
            target_node
          } else if lnode_internal_handle(node) ==
            lnode_internal_handle(target_node) {
            source_node
          } else {
            abort("'node' must be either source or target node of the edge")
          }
        _ => abort("edge is not connected to concrete nodes")
      }
    _ => abort("edge is not fully connected")
  }
}

///|
pub fn LEdge::set_property_bool(
  self : LEdge,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LEdge::get_property_bool(
  self : LEdge,
  property : IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LEdge::get_designation(self : LEdge) -> String? {
  if !self.labels.is_empty() && self.labels[0].get_text().length() > 0 {
    Some(self.labels[0].get_text())
  } else {
    self.graph_element.get_designation()
  }
}

///|
pub fn LEdge::to_string(self : LEdge) -> String {
  let result = "e_" +
    (match self.get_designation() {
      Some(designation) => designation
      None => ""
    })
  result
}
