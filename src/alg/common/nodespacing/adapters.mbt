///|
/// The graph operations required by the shared node-spacing kernel.
///
/// This trait is deliberately limited to the coarse graph boundary. Concrete
/// ELK and layered graph models keep their own storage and expose only the
/// operations the kernel needs.
#internal(nodespacing)
pub(open) trait NodeSpacingGraph {
  fn get_property_bool(Self, @graph.IProperty[Bool]) -> Bool
  fn get_property_double(Self, @graph.IProperty[Double]) -> Double
  fn get_property_string(Self, @graph.IProperty[String]) -> String
  fn get_nodes(Self) -> Array[&NodeSpacingNode]
  fn cleanup(Self) -> Unit
}

///|
/// The node operations required by the shared node-spacing kernel.
#internal(nodespacing)
pub(open) trait NodeSpacingNode {
  fn get_size(Self) -> @core.KVector
  fn set_size(Self, @core.KVector) -> Unit
  fn get_position(Self) -> @core.KVector
  fn get_property_bool(Self, @graph.IProperty[Bool]) -> Bool
  fn get_property_string(Self, @graph.IProperty[String]) -> String
  fn has_property_string(Self, @graph.IProperty[String]) -> Bool
  fn get_property_string_array(Self, @graph.IProperty[Array[String]]) -> Array[
    String,
  ]
  fn get_graph(Self) -> &NodeSpacingGraph?
  fn get_labels(Self) -> Array[&NodeSpacingLabel]
  fn get_ports(Self) -> Array[&NodeSpacingPort]
  fn get_incoming_edges(Self) -> Array[&NodeSpacingEdge]
  fn get_outgoing_edges(Self) -> Array[&NodeSpacingEdge]
  fn sort_port_list(Self) -> Unit
  fn is_compound_node(Self) -> Bool
  fn set_padding(Self, @core.ElkPadding) -> Unit
  fn get_margin(Self) -> @core.ElkMargin
  fn set_margin(Self, @core.ElkMargin) -> Unit
  fn get_individual_spacing(Self, @graph.IProperty[Double]) -> Double
}

///|
/// The port operations required by the shared node-spacing kernel.
#internal(nodespacing)
pub(open) trait NodeSpacingPort {
  fn get_size(Self) -> @core.KVector
  fn get_position(Self) -> @core.KVector
  fn set_position(Self, @core.KVector) -> Unit
  fn get_property_double(Self, @graph.IProperty[Double]) -> Double
  fn has_property_double(Self, @graph.IProperty[Double]) -> Bool
  fn set_volatile_id(Self, Int) -> Unit
  fn get_side(Self) -> @core.PortSide
  fn get_labels(Self) -> Array[&NodeSpacingLabel]
  fn get_incoming_edges(Self) -> Array[&NodeSpacingEdge]
  fn get_outgoing_edges(Self) -> Array[&NodeSpacingEdge]
  fn has_compound_connections(Self) -> Bool
}

///|
/// The label operations required by the shared node-spacing kernel.
#internal(nodespacing)
pub(open) trait NodeSpacingLabel {
  fn get_size(Self) -> @core.KVector
  fn get_position(Self) -> @core.KVector
  fn set_position(Self, @core.KVector) -> Unit
  fn get_property_string(Self, @graph.IProperty[String]) -> String
  fn get_property_string_array(Self, @graph.IProperty[Array[String]]) -> Array[
    String,
  ]
  fn has_property_string_array(Self, @graph.IProperty[Array[String]]) -> Bool
}

///|
/// The edge operations required by the shared node-spacing kernel.
#internal(nodespacing)
pub(open) trait NodeSpacingEdge {
  fn get_labels(Self) -> Array[&NodeSpacingLabel]
}

///|
impl NodeSpacingGraph for @core.ElkGraphAdapter with fn get_property_bool(
  self,
  property,
) {
  self.get_property_bool(property)
}

///|
impl NodeSpacingGraph for @core.ElkGraphAdapter with fn get_property_double(
  self,
  property,
) {
  self.get_property_double(property)
}

///|
impl NodeSpacingGraph for @core.ElkGraphAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl NodeSpacingGraph for @core.ElkGraphAdapter with fn get_nodes(self) {
  let nodes : Array[@core.ElkNodeAdapter] = self.get_nodes()
  nodes.map(node => node as &NodeSpacingNode)
}

///|
impl NodeSpacingGraph for @core.ElkGraphAdapter with fn cleanup(self) {
  // Node adapters retain their parent graph adapter, so discard the temporary
  // cache after each kernel invocation to break that ownership cycle.
  self.child_nodes = None
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn set_size(self, size) {
  self.set_size(size)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_property_bool(
  self,
  property,
) {
  self.get_property_bool(property)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn has_property_string(
  self,
  property,
) {
  self.has_property_string(property)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_property_string_array(
  self,
  property,
) {
  self.get_property_string_array(property)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_graph(self) {
  match self.get_graph() {
    Some(graph) => Some(graph as &NodeSpacingGraph)
    None => None
  }
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_labels(self) {
  let labels : Array[@core.ElkLabelAdapter] = self.get_labels()
  labels.map(label => label as &NodeSpacingLabel)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_ports(self) {
  let ports : Array[@core.ElkPortAdapter] = self.get_ports()
  ports.map(port => port as &NodeSpacingPort)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_incoming_edges(self) {
  let edges : Array[@core.ElkEdgeAdapter] = self.get_incoming_edges()
  edges.map(edge => edge as &NodeSpacingEdge)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_outgoing_edges(self) {
  let edges : Array[@core.ElkEdgeAdapter] = self.get_outgoing_edges()
  edges.map(edge => edge as &NodeSpacingEdge)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn sort_port_list(self) {
  self.sort_port_list()
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn is_compound_node(self) {
  self.is_compound_node()
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn set_padding(self, padding) {
  self.set_padding(padding)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_margin(self) {
  self.get_margin()
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn set_margin(self, margin) {
  self.set_margin(margin)
}

///|
impl NodeSpacingNode for @core.ElkNodeAdapter with fn get_individual_spacing(
  self,
  property,
) {
  @core.individual_spacings_get_individual_or_inherited(
    self.get_node(),
    property,
  )
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn set_position(
  self,
  position,
) {
  self.set_position(position)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_property_double(
  self,
  property,
) {
  self.get_property_double(property)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn has_property_double(
  self,
  property,
) {
  self.has_property_double(property)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn set_volatile_id(self, id) {
  self.set_volatile_id(id)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_side(self) {
  self.get_side()
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_labels(self) {
  let labels : Array[@core.ElkLabelAdapter] = self.get_labels()
  labels.map(label => label as &NodeSpacingLabel)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_incoming_edges(self) {
  let edges : Array[@core.ElkEdgeAdapter] = self.get_incoming_edges()
  edges.map(edge => edge as &NodeSpacingEdge)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn get_outgoing_edges(self) {
  let edges : Array[@core.ElkEdgeAdapter] = self.get_outgoing_edges()
  edges.map(edge => edge as &NodeSpacingEdge)
}

///|
impl NodeSpacingPort for @core.ElkPortAdapter with fn has_compound_connections(
  self,
) {
  self.has_compound_connections()
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn set_position(
  self,
  position,
) {
  self.set_position(position)
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn get_property_string_array(
  self,
  property,
) {
  self.get_property_string_array(property)
}

///|
impl NodeSpacingLabel for @core.ElkLabelAdapter with fn has_property_string_array(
  self,
  property,
) {
  self.has_property_string_array(property)
}

///|
impl NodeSpacingEdge for @core.ElkEdgeAdapter with fn get_labels(self) {
  let labels : Array[@core.ElkLabelAdapter] = self.get_labels()
  labels.map(label => label as &NodeSpacingLabel)
}
