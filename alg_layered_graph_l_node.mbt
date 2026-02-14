///|
let lnode_next_handle_ref : Ref[Int] = Ref::new(0)

///|
fn lnode_next_handle() -> Int {
  let handle = lnode_next_handle_ref.val
  lnode_next_handle_ref.val = handle + 1
  handle
}

///|
fn lnode_internal_handle(node : LNode) -> Int {
  node.node_handle
}

///|
fn lnode_port_side_equals(left : PortSide, right : PortSide) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (SideUndefined, SideUndefined) => true
    _ => false
  }
}

///|
fn lnode_clone_int_int_map(source : Map[Int, Int]) -> Map[Int, Int] {
  let copied : Map[Int, Int] = {}
  for entry in source.to_array() {
    copied[entry.0] = entry.1
  }
  copied
}

///|
pub enum NodeType {
  Normal
  LongEdge
  ExternalPort
  NorthSouthPort
  LabelNode
  BreakingPoint
  Placeholder
  NonshiftingPlaceholder
}

///|
pub fn node_type_values() -> Array[NodeType] {
  [
    NodeType::Normal,
    NodeType::LongEdge,
    NodeType::ExternalPort,
    NodeType::NorthSouthPort,
    NodeType::LabelNode,
    NodeType::BreakingPoint,
    NodeType::Placeholder,
    NodeType::NonshiftingPlaceholder,
  ]
}

///|
pub struct LNode {
  shape : LShape
  node_handle : Int
  mut graph : LGraph?
  mut layer : Layer?
  mut node_type : NodeType
  ports : Array[LPort]
  labels : Array[LLabel]
  mut nested_graph : LGraph?
  margin : LMargin
  padding : LPadding
  int_properties : Map[String, Int]
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  kvector_properties : Map[String, KVector]
  string_properties : Map[String, String]
  port_side_properties : Map[String, PortSide]
  node_properties : Map[String, LNode]
  node_array_properties : Map[String, Array[LNode]]
  int_int_map_properties : Map[String, Map[Int, Int]]
  port_properties : Map[String, LPort]
  edge_properties : Map[String, LEdge]
  self_loop_holder_properties : Map[String, SelfLoopHolder]
}

///|
pub fn new_l_node(graph? : LGraph? = None) -> LNode {
  {
    shape: new_l_shape(),
    node_handle: lnode_next_handle(),
    graph,
    layer: None,
    node_type: NodeType::Normal,
    ports: [],
    labels: [],
    nested_graph: None,
    margin: new_l_margin(),
    padding: new_l_padding(),
    int_properties: {},
    bool_properties: {},
    double_properties: {},
    kvector_properties: {},
    string_properties: {},
    port_side_properties: {},
    node_properties: {},
    node_array_properties: {},
    int_int_map_properties: {},
    port_properties: {},
    edge_properties: {},
    self_loop_holder_properties: {},
  }
}

///|
pub fn LNode::get_handle(self : LNode) -> Int {
  self.node_handle
}

///|
pub fn LNode::get_id(self : LNode) -> Int {
  self.shape.get_id()
}

///|
pub fn LNode::set_id(self : LNode, id : Int) -> Unit {
  self.shape.set_id(id)
}

///|
pub fn LNode::get_position(self : LNode) -> KVector {
  self.shape.get_position()
}

///|
pub fn LNode::get_size(self : LNode) -> KVector {
  self.shape.get_size()
}

///|
pub fn LNode::get_designation(self : LNode) -> String? {
  self.shape.get_designation()
}

///|
pub fn LNode::get_layer(self : LNode) -> Layer? {
  self.layer
}

///|
fn lnode_remove_from_layer(layer : Layer, node : LNode) -> Unit {
  let nodes = layer.get_nodes()
  for i in 0..<nodes.length() {
    if lnode_internal_handle(nodes[i]) == lnode_internal_handle(node) {
      ignore(nodes.remove(i))
      return
    }
  }
}

///|
fn lnode_add_to_layer(layer : Layer, node : LNode) -> Unit {
  let nodes = layer.get_nodes()
  for existing in nodes {
    if lnode_internal_handle(existing) == lnode_internal_handle(node) {
      return
    }
  }
  nodes.push(node)
}

///|
pub fn LNode::set_layer(self : LNode, new_layer : Layer?) -> Unit {
  match self.layer {
    Some(old_layer) => lnode_remove_from_layer(old_layer, self)
    None => ()
  }

  self.layer = new_layer

  match new_layer {
    Some(layer) => lnode_add_to_layer(layer, self)
    None => ()
  }
}

///|
pub fn LNode::get_graph(self : LNode) -> LGraph {
  match self.graph {
    Some(graph) => graph
    None =>
      match self.layer {
        Some(layer) => layer.get_graph()
        None => abort("LNode is not attached to a graph")
      }
  }
}

///|
pub fn LNode::set_graph(self : LNode, new_graph : LGraph?) -> Unit {
  self.graph = new_graph
}

///|
pub fn LNode::get_type(self : LNode) -> NodeType {
  self.node_type
}

///|
pub fn LNode::set_type(self : LNode, node_type : NodeType) -> Unit {
  self.node_type = node_type
}

///|
pub fn LNode::get_ports(self : LNode) -> Array[LPort] {
  self.ports
}

///|
pub fn LNode::get_ports_by_type(
  self : LNode,
  port_type : PortType,
) -> Array[LPort] {
  let result = []
  match port_type {
    Input =>
      for port in self.ports {
        if !port.get_incoming_edges().is_empty() {
          result.push(port)
        }
      }
    Output =>
      for port in self.ports {
        if !port.get_outgoing_edges().is_empty() {
          result.push(port)
        }
      }
    Undefined => ()
  }
  result
}

///|
pub fn LNode::get_ports_by_side(self : LNode, side : PortSide) -> Array[LPort] {
  let result = []
  for port in self.ports {
    if lnode_port_side_equals(port.get_side(), side) {
      result.push(port)
    }
  }
  result
}

///|
pub fn LNode::get_port_side_view(self : LNode, side : PortSide) -> Array[LPort] {
  self.get_ports_by_side(side)
}

///|
pub fn LNode::get_ports_by_type_and_side(
  self : LNode,
  port_type : PortType,
  side : PortSide,
) -> Array[LPort] {
  let ports_on_side = self.get_ports_by_side(side)
  let result = []
  match port_type {
    Input =>
      for port in ports_on_side {
        if !port.get_incoming_edges().is_empty() {
          result.push(port)
        }
      }
    Output =>
      for port in ports_on_side {
        if !port.get_outgoing_edges().is_empty() {
          result.push(port)
        }
      }
    Undefined => ()
  }
  result
}

///|
pub fn LNode::add_port(self : LNode, port : LPort) -> Unit {
  for existing in self.ports {
    if lport_internal_handle(existing) == lport_internal_handle(port) {
      return
    }
  }
  self.ports.push(port)
}

///|
pub fn LNode::remove_port(self : LNode, port : LPort) -> Unit {
  for i in 0..<self.ports.length() {
    if lport_internal_handle(self.ports[i]) == lport_internal_handle(port) {
      ignore(self.ports.remove(i))
      return
    }
  }
}

///|
pub fn LNode::get_labels(self : LNode) -> Array[LLabel] {
  self.labels
}

///|
pub fn LNode::get_margin(self : LNode) -> LMargin {
  self.margin
}

///|
pub fn LNode::get_padding(self : LNode) -> LPadding {
  self.padding
}

///|
pub fn LNode::get_nested_graph(self : LNode) -> LGraph? {
  self.nested_graph
}

///|
pub fn LNode::set_nested_graph(self : LNode, graph : LGraph?) -> Unit {
  self.nested_graph = graph
}

///|
pub fn LNode::get_connected_edges(self : LNode) -> Array[LEdge] {
  let result = []
  for port in self.ports {
    for edge in port.get_incoming_edges() {
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
    for edge in port.get_outgoing_edges() {
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
  }
  result
}

///|
pub fn LNode::get_incoming_edges(self : LNode) -> Array[LEdge] {
  let result = []
  for port in self.ports {
    for edge in port.get_incoming_edges() {
      result.push(edge)
    }
  }
  result
}

///|
pub fn LNode::get_outgoing_edges(self : LNode) -> Array[LEdge] {
  let result = []
  for port in self.ports {
    for edge in port.get_outgoing_edges() {
      result.push(edge)
    }
  }
  result
}

///|
pub fn LNode::set_property_int(
  self : LNode,
  property : IProperty[Int],
  value : Int,
) -> Unit {
  self.int_properties[property.get_id()] = value
}

///|
pub fn LNode::get_property_int(self : LNode, property : IProperty[Int]) -> Int {
  match self.int_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LNode::set_property_bool(
  self : LNode,
  property : IProperty[Bool],
  value : Bool,
) -> Unit {
  self.bool_properties[property.get_id()] = value
}

///|
pub fn LNode::set_property_double(
  self : LNode,
  property : IProperty[Double],
  value : Double,
) -> Unit {
  self.double_properties[property.get_id()] = value
}

///|
pub fn LNode::set_property_kvector(
  self : LNode,
  property : IProperty[KVector],
  value : KVector,
) -> Unit {
  self.kvector_properties[property.get_id()] = value.clone()
}

///|
pub fn LNode::set_property_string(
  self : LNode,
  property : IProperty[String],
  value : String,
) -> Unit {
  self.string_properties[property.get_id()] = value
}

///|
pub fn LNode::get_property_bool(
  self : LNode,
  property : IProperty[Bool],
) -> Bool {
  match self.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LNode::get_property_double(
  self : LNode,
  property : IProperty[Double],
) -> Double {
  match self.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LNode::get_property_kvector(
  self : LNode,
  property : IProperty[KVector],
) -> KVector {
  match self.kvector_properties.get(property.get_id()) {
    Some(value) => value.clone()
    None => property.get_default().clone()
  }
}

///|
pub fn LNode::get_property_string(
  self : LNode,
  property : IProperty[String],
) -> String {
  match self.string_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LNode::set_property_port_side(
  self : LNode,
  property : IProperty[PortSide],
  value : PortSide,
) -> Unit {
  self.port_side_properties[property.get_id()] = value
}

///|
pub fn LNode::get_property_port_side(
  self : LNode,
  property : IProperty[PortSide],
) -> PortSide {
  match self.port_side_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn LNode::has_property_int(self : LNode, property : IProperty[Int]) -> Bool {
  self.int_properties.contains(property.get_id())
}

///|
pub fn LNode::has_property_bool(
  self : LNode,
  property : IProperty[Bool],
) -> Bool {
  self.bool_properties.contains(property.get_id())
}

///|
pub fn LNode::has_property_double(
  self : LNode,
  property : IProperty[Double],
) -> Bool {
  self.double_properties.contains(property.get_id())
}

///|
pub fn LNode::has_property_kvector(
  self : LNode,
  property : IProperty[KVector],
) -> Bool {
  self.kvector_properties.contains(property.get_id())
}

///|
pub fn LNode::has_property_string(
  self : LNode,
  property : IProperty[String],
) -> Bool {
  self.string_properties.contains(property.get_id())
}

///|
pub fn LNode::has_property_port_side(
  self : LNode,
  property : IProperty[PortSide],
) -> Bool {
  self.port_side_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_l_node(
  self : LNode,
  property : IProperty[LNode?],
  value : LNode?,
) -> Unit {
  match value {
    Some(node) => self.node_properties[property.get_id()] = node
    None => ignore(self.node_properties.remove(property.get_id()))
  }
}

///|
pub fn LNode::get_property_l_node(
  self : LNode,
  property : IProperty[LNode?],
) -> LNode? {
  match self.node_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LNode::has_property_l_node(
  self : LNode,
  property : IProperty[LNode?],
) -> Bool {
  self.node_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_l_node_array(
  self : LNode,
  property : IProperty[Array[LNode]],
  value : Array[LNode],
) -> Unit {
  self.node_array_properties[property.get_id()] = value.copy()
}

///|
pub fn LNode::get_property_l_node_array(
  self : LNode,
  property : IProperty[Array[LNode]],
) -> Array[LNode] {
  match self.node_array_properties.get(property.get_id()) {
    Some(value) => value.copy()
    None => property.get_default().copy()
  }
}

///|
pub fn LNode::has_property_l_node_array(
  self : LNode,
  property : IProperty[Array[LNode]],
) -> Bool {
  self.node_array_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_int_int_map(
  self : LNode,
  property : IProperty[Map[Int, Int]],
  value : Map[Int, Int],
) -> Unit {
  self.int_int_map_properties[property.get_id()] = lnode_clone_int_int_map(
    value,
  )
}

///|
pub fn LNode::get_property_int_int_map(
  self : LNode,
  property : IProperty[Map[Int, Int]],
) -> Map[Int, Int] {
  match self.int_int_map_properties.get(property.get_id()) {
    Some(value) => value
    None => {
      let created = lnode_clone_int_int_map(property.get_default())
      self.int_int_map_properties[property.get_id()] = created
      created
    }
  }
}

///|
pub fn LNode::has_property_int_int_map(
  self : LNode,
  property : IProperty[Map[Int, Int]],
) -> Bool {
  self.int_int_map_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_l_port(
  self : LNode,
  property : IProperty[LPort?],
  value : LPort?,
) -> Unit {
  match value {
    Some(port) => self.port_properties[property.get_id()] = port
    None => ignore(self.port_properties.remove(property.get_id()))
  }
}

///|
pub fn LNode::get_property_l_port(
  self : LNode,
  property : IProperty[LPort?],
) -> LPort? {
  match self.port_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LNode::has_property_l_port(
  self : LNode,
  property : IProperty[LPort?],
) -> Bool {
  self.port_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_l_edge(
  self : LNode,
  property : IProperty[LEdge?],
  value : LEdge?,
) -> Unit {
  match value {
    Some(edge) => self.edge_properties[property.get_id()] = edge
    None => ignore(self.edge_properties.remove(property.get_id()))
  }
}

///|
pub fn LNode::get_property_l_edge(
  self : LNode,
  property : IProperty[LEdge?],
) -> LEdge? {
  match self.edge_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LNode::has_property_l_edge(
  self : LNode,
  property : IProperty[LEdge?],
) -> Bool {
  self.edge_properties.contains(property.get_id())
}

///|
pub fn LNode::set_property_self_loop_holder(
  self : LNode,
  property : IProperty[SelfLoopHolder?],
  value : SelfLoopHolder?,
) -> Unit {
  match value {
    Some(holder) => self.self_loop_holder_properties[property.get_id()] = holder
    None => ignore(self.self_loop_holder_properties.remove(property.get_id()))
  }
}

///|
pub fn LNode::get_property_self_loop_holder(
  self : LNode,
  property : IProperty[SelfLoopHolder?],
) -> SelfLoopHolder? {
  match self.self_loop_holder_properties.get(property.get_id()) {
    Some(value) => Some(value)
    None => property.get_default()
  }
}

///|
pub fn LNode::has_property_self_loop_holder(
  self : LNode,
  property : IProperty[SelfLoopHolder?],
) -> Bool {
  self.self_loop_holder_properties.contains(property.get_id())
}

///|
pub fn LNode::to_string(self : LNode) -> String {
  match self.get_designation() {
    Some(designation) => "n_" + designation
    None => "node"
  }
}
