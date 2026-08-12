///|
let ledge_next_handle_ref : Ref[Int] = Ref(0)

///|
fn ledge_next_handle() -> Int {
  let handle = ledge_next_handle_ref.val
  ledge_next_handle_ref.val = handle + 1
  handle
}

///|
pub fn ledge_internal_handle(edge : LEdge) -> Int {
  edge.edge_handle
}

///|
pub(all) suberror LEdgeException {
  IllegalArgumentException(String)
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
fn[T] ledge_raise_illegal_argument(message : String) -> T raise LEdgeException {
  raise IllegalArgumentException(message)
}

///|
fn[T] ledge_raise_illegal_state(message : String) -> T raise LEdgeException {
  raise IllegalStateException(message)
}

///|
pub struct LEdge {
  graph_element : LGraphElement
  edge_handle : Int
  bend_points : @core.KVectorChain
  mut source : LPort?
  mut target : LPort?
  labels : Array[LLabel]
  priv mut int_properties : Map[@graph.PropertyId, Int]?
  priv mut double_properties : Map[@graph.PropertyId, Double]?
  priv mut kvector_properties : Map[@graph.PropertyId, @core.KVector]?
  priv mut kvector_chain_properties : Map[@graph.PropertyId, @core.KVectorChain]?
  priv mut bool_properties : Map[@graph.PropertyId, Bool]?
  priv mut l_edge_array_properties : Map[@graph.PropertyId, Array[LEdge]]?
  priv mut port_properties : Map[@graph.PropertyId, LPort]?
  priv mut edge_properties : Map[@graph.PropertyId, LEdge]?
  priv mut l_graph_properties : Map[@graph.PropertyId, LGraph]?
}

///|
pub fn new_l_edge() -> LEdge {
  {
    graph_element: new_l_graph_element(),
    edge_handle: ledge_next_handle(),
    bend_points: @core.new_kvector_chain(),
    source: None,
    target: None,
    labels: [],
    int_properties: None,
    double_properties: None,
    kvector_properties: None,
    kvector_chain_properties: None,
    bool_properties: None,
    l_edge_array_properties: None,
    port_properties: None,
    edge_properties: None,
    l_graph_properties: None,
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
pub fn LEdge::reverse(
  self : LEdge,
  layered_graph : LGraph,
  adapt_ports : Bool,
) -> Unit {
  let old_source = self.get_source().unwrap()
  let old_target = self.get_target().unwrap()

  self.set_source(None)
  self.set_target(None)

  if adapt_ports &&
    old_target.get_property_bool(internal_properties_input_collect) {
    let source_node = old_target.get_node().unwrap()
    self.set_source(
      Some(provide_collector_port(layered_graph, source_node, Output, East)),
    )
  } else {
    self.set_source(Some(old_target))
  }

  if adapt_ports &&
    old_source.get_property_bool(internal_properties_output_collect) {
    let target_node = old_source.get_node().unwrap()
    self.set_target(
      Some(provide_collector_port(layered_graph, target_node, Input, West)),
    )
  } else {
    self.set_target(Some(old_source))
  }

  for label in self.labels {
    let label_placement = label.get_property_string(@core.edge_labels_placement)
    if label_placement == "TAIL" {
      label.set_property_string(@core.edge_labels_placement, "HEAD")
    } else if label_placement == "HEAD" {
      label.set_property_string(@core.edge_labels_placement, "TAIL")
    }
  }

  self.set_property_bool(
    internal_properties_reversed,
    !self.get_property_bool(internal_properties_reversed),
  )

  let reversed_bend_points = @core.kvector_chain_reverse(self.bend_points)
  self.bend_points.clear()
  self.bend_points.add_all(reversed_bend_points.to_array())
}

///|
pub fn LEdge::get_bend_points(self : LEdge) -> @core.KVectorChain {
  self.bend_points
}

///|
pub fn LEdge::get_labels(self : LEdge) -> Array[LLabel] {
  self.labels
}

///|
pub fn LEdge::copy_properties(self : LEdge, source : LEdge) -> Unit {
  self.int_properties = layered_property_bag_copy(
    source.int_properties,
    layered_property_identity,
  )
  self.double_properties = layered_property_bag_copy(
    source.double_properties,
    layered_property_identity,
  )
  self.kvector_properties = layered_property_bag_copy(
    source.kvector_properties,
    value => value.clone(),
  )
  self.kvector_chain_properties = layered_property_bag_copy(
    source.kvector_chain_properties,
    value => @core.new_kvector_chain_copy(value),
  )
  self.bool_properties = layered_property_bag_copy(
    source.bool_properties,
    layered_property_identity,
  )
  self.l_edge_array_properties = layered_property_bag_copy(
    source.l_edge_array_properties,
    value => value.copy(),
  )
  self.port_properties = layered_property_bag_copy(
    source.port_properties,
    layered_property_identity,
  )
  self.edge_properties = layered_property_bag_copy(
    source.edge_properties,
    layered_property_identity,
  )
  self.l_graph_properties = layered_property_bag_copy(
    source.l_graph_properties,
    layered_property_identity,
  )
}

///|
pub fn LEdge::get_other_port(
  self : LEdge,
  port : LPort,
) -> LPort raise LEdgeException {
  match (self.source, self.target) {
    (Some(source), Some(target)) =>
      if lport_internal_handle(port) == lport_internal_handle(source) {
        target
      } else if lport_internal_handle(port) == lport_internal_handle(target) {
        source
      } else {
        ledge_raise_illegal_argument(
          "'port' must be either the source port or target port of the edge.",
        )
      }
    _ => ledge_raise_illegal_state("edge is not fully connected")
  }
}

///|
pub fn LEdge::get_other_node(
  self : LEdge,
  node : LNode,
) -> LNode raise LEdgeException {
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
            ledge_raise_illegal_argument(
              "'node' must either be the source node or target node of the edge.",
            )
          }
        _ =>
          ledge_raise_illegal_state("edge is not connected to concrete nodes")
      }
    _ => ledge_raise_illegal_state("edge is not fully connected")
  }
}

///|
pub fn LEdge::set_property_bool(
  self : LEdge,
  property : @graph.IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties = Some(
    layered_property_bag_set(
      self.bool_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LEdge::set_property_int(
  self : LEdge,
  property : @graph.IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties = Some(
    layered_property_bag_set(
      self.int_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LEdge::set_property_double(
  self : LEdge,
  property : @graph.IProperty[Double],
  value : Double,
) -> Unit {
  self.double_properties = Some(
    layered_property_bag_set(
      self.double_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LEdge::set_property_kvector(
  self : LEdge,
  property : @graph.IProperty[@core.KVector],
  value : @core.KVector,
) -> Unit {
  self.kvector_properties = Some(
    layered_property_bag_set(
      self.kvector_properties,
      property.get_property_id(),
      value.clone(),
    ),
  )
}

///|
pub fn LEdge::get_property_int(
  self : LEdge,
  property : @graph.IProperty[Int],
) -> Int {
  match
    layered_property_bag_get(self.int_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LEdge::get_property_double(
  self : LEdge,
  property : @graph.IProperty[Double],
) -> Double {
  match
    layered_property_bag_get(self.double_properties, property.get_property_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LEdge::get_property_kvector(
  self : LEdge,
  property : @graph.IProperty[@core.KVector],
) -> @core.KVector {
  match
    layered_property_bag_get(
      self.kvector_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.clone()
    None => property.get_default().clone()
  }
}

///|
pub fn LEdge::has_property_int(
  self : LEdge,
  property : @graph.IProperty[Int],
) -> Bool {
  layered_property_bag_has(self.int_properties, property.get_property_id())
}

///|
pub fn LEdge::has_property_double(
  self : LEdge,
  property : @graph.IProperty[Double],
) -> Bool {
  layered_property_bag_has(self.double_properties, property.get_property_id())
}

///|
pub fn LEdge::has_property_kvector(
  self : LEdge,
  property : @graph.IProperty[@core.KVector],
) -> Bool {
  layered_property_bag_has(self.kvector_properties, property.get_property_id())
}

///|
pub fn LEdge::set_property_kvector_chain(
  self : LEdge,
  property : @graph.IProperty[@core.KVectorChain],
  value : @core.KVectorChain,
) -> Unit {
  self.kvector_chain_properties = Some(
    layered_property_bag_set(
      self.kvector_chain_properties,
      property.get_property_id(),
      value,
    ),
  )
}

///|
pub fn LEdge::get_property_kvector_chain(
  self : LEdge,
  property : @graph.IProperty[@core.KVectorChain],
) -> @core.KVectorChain {
  match
    layered_property_bag_get(
      self.kvector_chain_properties,
      property.get_property_id(),
    ) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LEdge::has_property_kvector_chain(
  self : LEdge,
  property : @graph.IProperty[@core.KVectorChain],
) -> Bool {
  layered_property_bag_has(
    self.kvector_chain_properties,
    property.get_property_id(),
  )
}

///|
pub fn LEdge::clear_property_kvector_chain(
  self : LEdge,
  property : @graph.IProperty[@core.KVectorChain],
) -> Unit {
  self.kvector_chain_properties = layered_property_bag_remove(
    self.kvector_chain_properties,
    property.get_property_id(),
  )
}

///|
pub fn LEdge::set_property_l_edge_array(
  self : LEdge,
  property : @graph.IProperty[Array[LEdge]],
  value : Array[LEdge],
) -> Unit {
  self.l_edge_array_properties = Some(
    layered_property_bag_set(
      self.l_edge_array_properties,
      property.get_property_id(),
      value.copy(),
    ),
  )
}

///|
pub fn LEdge::get_property_l_edge_array(
  self : LEdge,
  property : @graph.IProperty[Array[LEdge]],
) -> Array[LEdge] {
  match
    layered_property_bag_get(
      self.l_edge_array_properties,
      property.get_property_id(),
    ) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LEdge::has_property_l_edge_array(
  self : LEdge,
  property : @graph.IProperty[Array[LEdge]],
) -> Bool {
  layered_property_bag_has(
    self.l_edge_array_properties,
    property.get_property_id(),
  )
}

///|
pub fn LEdge::set_property_l_port(
  self : LEdge,
  property : @graph.IProperty[LPort?],
  value : LPort?,
) -> Unit {
  match value {
    Some(port) =>
      self.port_properties = Some(
        layered_property_bag_set(
          self.port_properties,
          property.get_property_id(),
          port,
        ),
      )
    None =>
      self.port_properties = layered_property_bag_remove(
        self.port_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LEdge::get_property_l_port(
  self : LEdge,
  property : @graph.IProperty[LPort?],
) -> LPort? {
  match
    layered_property_bag_get(self.port_properties, property.get_property_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LEdge::has_property_l_port(
  self : LEdge,
  property : @graph.IProperty[LPort?],
) -> Bool {
  layered_property_bag_has(self.port_properties, property.get_property_id())
}

///|
pub fn LEdge::set_property_l_edge(
  self : LEdge,
  property : @graph.IProperty[LEdge?],
  value : LEdge?,
) -> Unit {
  match value {
    Some(edge) =>
      self.edge_properties = Some(
        layered_property_bag_set(
          self.edge_properties,
          property.get_property_id(),
          edge,
        ),
      )
    None =>
      self.edge_properties = layered_property_bag_remove(
        self.edge_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LEdge::get_property_l_edge(
  self : LEdge,
  property : @graph.IProperty[LEdge?],
) -> LEdge? {
  match
    layered_property_bag_get(self.edge_properties, property.get_property_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LEdge::has_property_l_edge(
  self : LEdge,
  property : @graph.IProperty[LEdge?],
) -> Bool {
  layered_property_bag_has(self.edge_properties, property.get_property_id())
}

///|
pub fn LEdge::set_property_l_graph(
  self : LEdge,
  property : @graph.IProperty[LGraph?],
  value : LGraph?,
) -> Unit {
  match value {
    Some(graph) =>
      self.l_graph_properties = Some(
        layered_property_bag_set(
          self.l_graph_properties,
          property.get_property_id(),
          graph,
        ),
      )
    None =>
      self.l_graph_properties = layered_property_bag_remove(
        self.l_graph_properties,
        property.get_property_id(),
      )
  }
}

///|
pub fn LEdge::get_property_l_graph(
  self : LEdge,
  property : @graph.IProperty[LGraph?],
) -> LGraph? {
  match
    layered_property_bag_get(
      self.l_graph_properties,
      property.get_property_id(),
    ) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LEdge::has_property_l_graph(
  self : LEdge,
  property : @graph.IProperty[LGraph?],
) -> Bool {
  layered_property_bag_has(self.l_graph_properties, property.get_property_id())
}

///|
pub fn LEdge::get_property_bool(
  self : LEdge,
  property : @graph.IProperty[Bool],
) -> Bool {
  match
    layered_property_bag_get(self.bool_properties, property.get_property_id()) {
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
