///|
impl @nodespacing.NodeSpacingGraph for LGraphAdapter with fn get_property_bool(
  self,
  property,
) {
  self.get_property_bool(property)
}

///|
impl @nodespacing.NodeSpacingGraph for LGraphAdapter with fn get_property_double(
  self,
  property,
) {
  self.get_property_double(property)
}

///|
impl @nodespacing.NodeSpacingGraph for LGraphAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl @nodespacing.NodeSpacingGraph for LGraphAdapter with fn get_nodes(self) {
  // Layerless graphs are used while a layered graph is still being prepared;
  // preserve the old node-spacing entry point's traversal semantics here.
  let nodes : Array[LNodeAdapter] = if self.element.get_layers().is_empty() {
    let adapters = []
    for node in self.element.get_layerless_nodes() {
      if node.get_type() is Normal && (self.node_filter)(node) {
        adapters.push(
          new_l_node_adapter(
            Some(self),
            node,
            self.transparent_north_south_edges,
          ),
        )
      }
    }
    self.node_adapters = Some(adapters)
    adapters
  } else {
    self.get_nodes()
  }
  nodes.map(node => node as &@nodespacing.NodeSpacingNode)
}

///|
impl @nodespacing.NodeSpacingGraph for LGraphAdapter with fn cleanup(self) {
  self.cleanup()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn set_size(self, size) {
  self.set_size(size)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_property_bool(
  self,
  property,
) {
  self.get_property_bool(property)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn has_property_string(
  self,
  property,
) {
  self.has_property_string(property)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_property_string_array(
  self,
  property,
) {
  self.get_property_string_array(property)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_graph(self) {
  match self.get_graph() {
    Some(graph) => Some(graph as &@nodespacing.NodeSpacingGraph)
    None => None
  }
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_labels(self) {
  let labels : Array[LLabelAdapter] = self.get_labels()
  labels.map(label => label as &@nodespacing.NodeSpacingLabel)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_ports(self) {
  let ports : Array[LPortAdapter] = self.get_ports()
  ports.map(port => port as &@nodespacing.NodeSpacingPort)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_incoming_edges(
  self,
) {
  let edges : Array[LEdgeAdapter] = self.get_incoming_edges()
  edges.map(edge => edge as &@nodespacing.NodeSpacingEdge)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_outgoing_edges(
  self,
) {
  let edges : Array[LEdgeAdapter] = self.get_outgoing_edges()
  edges.map(edge => edge as &@nodespacing.NodeSpacingEdge)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn sort_port_list(self) {
  self.sort_port_list()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn is_compound_node(
  self,
) {
  self.is_compound_node()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn set_padding(
  self,
  padding,
) {
  self.set_padding(padding)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_margin(self) {
  self.get_margin()
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn set_margin(
  self,
  margin,
) {
  self.set_margin(margin)
}

///|
impl @nodespacing.NodeSpacingNode for LNodeAdapter with fn get_individual_spacing(
  self,
  property,
) {
  layered_spacings_get_individual_or_default(self.get_node(), property)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn set_position(
  self,
  position,
) {
  self.set_position(position)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_property_double(
  self,
  property,
) {
  self.get_property_double(property)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn has_property_double(
  self,
  property,
) {
  self.has_property_double(property)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn set_volatile_id(
  self,
  id,
) {
  self.set_volatile_id(id)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_side(self) {
  self.get_side()
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_labels(self) {
  let labels : Array[LLabelAdapter] = self.get_labels()
  labels.map(label => label as &@nodespacing.NodeSpacingLabel)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_incoming_edges(
  self,
) {
  let edges : Array[LEdgeAdapter] = self.get_incoming_edges()
  edges.map(edge => edge as &@nodespacing.NodeSpacingEdge)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn get_outgoing_edges(
  self,
) {
  let edges : Array[LEdgeAdapter] = self.get_outgoing_edges()
  edges.map(edge => edge as &@nodespacing.NodeSpacingEdge)
}

///|
impl @nodespacing.NodeSpacingPort for LPortAdapter with fn has_compound_connections(
  self,
) {
  self.has_compound_connections()
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn get_size(self) {
  self.get_size()
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn get_position(self) {
  self.get_position()
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn set_position(
  self,
  position,
) {
  self.set_position(position)
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn get_property_string(
  self,
  property,
) {
  self.get_property_string(property)
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn get_property_string_array(
  self,
  property,
) {
  self.get_property_string_array(property)
}

///|
impl @nodespacing.NodeSpacingLabel for LLabelAdapter with fn has_property_string_array(
  self,
  property,
) {
  self.has_property_string_array(property)
}

///|
impl @nodespacing.NodeSpacingEdge for LEdgeAdapter with fn get_labels(self) {
  let labels : Array[LLabelAdapter] = self.get_labels()
  labels.map(label => label as &@nodespacing.NodeSpacingLabel)
}
