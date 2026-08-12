///|
/// Concrete label snapshot consumed by the node-spacing kernel.
pub(all) struct NodeSpacingLabel {
  size : @core.KVector
  mut position : @core.KVector
  edge_placement : String
  has_node_placement : Bool
  node_placement : Array[String]
}

///|
/// Concrete edge snapshot. Node spacing only needs the edge labels.
pub(all) struct NodeSpacingEdge {
  labels : Array[NodeSpacingLabel]
}

///|
/// Concrete port snapshot consumed and mutated by the pure kernel.
pub(all) struct NodeSpacingPort {
  source_index : Int
  size : @core.KVector
  mut position : @core.KVector
  side : @core.PortSide
  labels : Array[NodeSpacingLabel]
  incoming_edges : Array[NodeSpacingEdge]
  outgoing_edges : Array[NodeSpacingEdge]
  has_compound_connections : Bool
  has_border_offset : Bool
  border_offset : Double
  has_ratio_or_position : Bool
  ratio_or_position : Double
  sort_index : Int?
  mut volatile_id : Int
}

///|
/// All node properties read by node spacing, parsed once at the model seam.
pub(all) struct NodeSpacingNode {
  source_index : Int
  mut size : @core.KVector
  position : @core.KVector
  labels : Array[NodeSpacingLabel]
  ports : Array[NodeSpacingPort]
  incoming_edges : Array[NodeSpacingEdge]
  outgoing_edges : Array[NodeSpacingEdge]
  sort_ports : Bool
  compound_node : Bool
  graph_fixed_size : Bool
  topdown_layout : Bool
  inside_self_loops_activate : Bool
  size_constraints : Array[String]
  size_options : Array[String]
  port_constraints : String
  port_labels_placement : Array[String]
  port_labels_treat_as_group : Bool
  node_labels_placement : Array[String]
  node_labels_padding : String
  spacing_label_node : Double
  spacing_label_label : Double
  spacing_port_port : Double
  spacing_label_port_horizontal : Double
  spacing_label_port_vertical : Double
  spacing_ports_surrounding : String
  alignment_default : String
  alignment_north : String?
  alignment_south : String?
  alignment_east : String?
  alignment_west : String?
  minimum_size : String
  mut padding : @core.ElkPadding
  mut margin : @core.ElkMargin
}

///|
/// Self-contained input for one node-spacing invocation.
///
/// No graph handles, property descriptors, callbacks, or trait objects cross
/// this seam. Model-specific adapters only construct and apply this value.
pub(all) struct NodeSpacingInput {
  direction : String
  spacing_label_node : Double
  nodes : Array[NodeSpacingNode]
}

///|
pub(all) struct NodeSpacingPortOutput {
  source_index : Int
  position : @core.KVector
  volatile_id : Int
  label_positions : Array[@core.KVector]
}

///|
pub(all) struct NodeSpacingNodeOutput {
  source_index : Int
  size : @core.KVector
  padding : @core.ElkPadding
  margin : @core.ElkMargin
  port_order : Array[Int]
  ports : Array[NodeSpacingPortOutput]
  label_positions : Array[@core.KVector]
}

///|
/// Explicit mutations produced by the pure node-spacing kernel.
pub(all) struct NodeSpacingOutput {
  nodes : Array[NodeSpacingNodeOutput]
}

///|
pub fn NodeSpacingInput::output(self : NodeSpacingInput) -> NodeSpacingOutput {
  let nodes = []
  for node in self.nodes {
    let ports = []
    for port in node.ports {
      ports.push({
        source_index: port.source_index,
        position: port.position.clone(),
        volatile_id: port.volatile_id,
        label_positions: [
          for label in port.labels => label.position.clone()
        ],
      })
    }
    nodes.push({
      source_index: node.source_index,
      size: node.size.clone(),
      padding: @core.new_elk_padding_copy(node.padding),
      margin: @core.new_elk_margin_copy(node.margin),
      port_order: [
        for port in node.ports => port.source_index
      ],
      ports,
      label_positions: [
        for label in node.labels => label.position.clone()
      ],
    })
  }
  { nodes, }
}

///|
fn NodeSpacingNode::get_size(self : NodeSpacingNode) -> @core.KVector {
  self.size
}

///|
fn NodeSpacingNode::set_size(
  self : NodeSpacingNode,
  size : @core.KVector,
) -> Unit {
  self.size = size
}

///|
fn NodeSpacingNode::get_position(self : NodeSpacingNode) -> @core.KVector {
  self.position
}

///|
fn NodeSpacingNode::get_labels(
  self : NodeSpacingNode,
) -> Array[NodeSpacingLabel] {
  self.labels
}

///|
fn NodeSpacingNode::get_ports(self : NodeSpacingNode) -> Array[NodeSpacingPort] {
  self.ports
}

///|
fn NodeSpacingNode::get_incoming_edges(
  self : NodeSpacingNode,
) -> Array[NodeSpacingEdge] {
  self.incoming_edges
}

///|
fn NodeSpacingNode::get_outgoing_edges(
  self : NodeSpacingNode,
) -> Array[NodeSpacingEdge] {
  self.outgoing_edges
}

///|
fn nodespacing_side_rank(side : @core.PortSide) -> Int {
  match side {
    SideUndefined => 0
    North => 1
    East => 2
    South => 3
    West => 4
  }
}

///|
fn nodespacing_compare_double(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn nodespacing_compare_ports(
  left : NodeSpacingPort,
  right : NodeSpacingPort,
) -> Int raise {
  let side_difference = nodespacing_side_rank(left.side) -
    nodespacing_side_rank(right.side)
  if side_difference != 0 {
    return side_difference
  }
  if (left.sort_index, right.sort_index) is (Some(left), Some(right)) {
    let index_difference = left - right
    if index_difference != 0 {
      return index_difference
    }
  }
  match left.side {
    North => nodespacing_compare_double(left.position.x, right.position.x)
    East => nodespacing_compare_double(left.position.y, right.position.y)
    South => nodespacing_compare_double(right.position.x, left.position.x)
    West => nodespacing_compare_double(right.position.y, left.position.y)
    SideUndefined => {
      @core.layout_runtime_raise_unsupported_configuration(
        "Port side is undefined",
      )
      0
    }
  }
}

///|
fn NodeSpacingNode::sort_port_list(self : NodeSpacingNode) -> Unit raise {
  if !self.sort_ports {
    return
  }
  for index in 1..<self.ports.length() {
    let current = self.ports[index]
    let mut insertion = index
    while insertion > 0 &&
          nodespacing_compare_ports(self.ports[insertion - 1], current) > 0 {
      self.ports[insertion] = self.ports[insertion - 1]
      insertion -= 1
    }
    self.ports[insertion] = current
  }
}

///|
fn NodeSpacingNode::is_compound_node(self : NodeSpacingNode) -> Bool {
  self.compound_node
}

///|
fn NodeSpacingNode::set_padding(
  self : NodeSpacingNode,
  padding : @core.ElkPadding,
) -> Unit {
  self.padding = @core.new_elk_padding_copy(padding)
}

///|
fn NodeSpacingNode::get_margin(self : NodeSpacingNode) -> @core.ElkMargin {
  self.margin
}

///|
fn NodeSpacingNode::set_margin(
  self : NodeSpacingNode,
  margin : @core.ElkMargin,
) -> Unit {
  self.margin = @core.new_elk_margin_copy(margin)
}

///|
fn NodeSpacingPort::get_size(self : NodeSpacingPort) -> @core.KVector {
  self.size
}

///|
fn NodeSpacingPort::get_position(self : NodeSpacingPort) -> @core.KVector {
  self.position
}

///|
fn NodeSpacingPort::set_position(
  self : NodeSpacingPort,
  position : @core.KVector,
) -> Unit {
  self.position = position
}

///|
fn NodeSpacingPort::set_volatile_id(self : NodeSpacingPort, id : Int) -> Unit {
  self.volatile_id = id
}

///|
fn NodeSpacingPort::get_side(self : NodeSpacingPort) -> @core.PortSide {
  self.side
}

///|
fn NodeSpacingPort::get_labels(
  self : NodeSpacingPort,
) -> Array[NodeSpacingLabel] {
  self.labels
}

///|
fn NodeSpacingPort::get_incoming_edges(
  self : NodeSpacingPort,
) -> Array[NodeSpacingEdge] {
  self.incoming_edges
}

///|
fn NodeSpacingPort::get_outgoing_edges(
  self : NodeSpacingPort,
) -> Array[NodeSpacingEdge] {
  self.outgoing_edges
}

///|
fn NodeSpacingPort::has_compound_connections(self : NodeSpacingPort) -> Bool {
  self.has_compound_connections
}

///|
fn NodeSpacingLabel::get_size(self : NodeSpacingLabel) -> @core.KVector {
  self.size
}

///|
fn NodeSpacingLabel::get_position(self : NodeSpacingLabel) -> @core.KVector {
  self.position
}

///|
fn NodeSpacingLabel::set_position(
  self : NodeSpacingLabel,
  position : @core.KVector,
) -> Unit {
  self.position = position
}

///|
fn NodeSpacingEdge::get_labels(
  self : NodeSpacingEdge,
) -> Array[NodeSpacingLabel] {
  self.labels
}
