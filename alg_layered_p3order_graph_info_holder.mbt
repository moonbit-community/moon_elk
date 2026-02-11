///|
fn graph_info_count_ports(node_order : Array[Array[LNode]]) -> Int {
  let mut count = 0
  for layer in node_order {
    for node in layer {
      count = count + node.get_ports().length()
    }
  }
  count
}

///|
fn graph_info_parent_layer_id(parent : LNode) -> Int {
  match parent.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("parent node is not assigned to a layer")
  }
}

///|
pub struct GraphInfoHolder {
  mut current_node_order_ref : Array[Array[LNode]]
  mut port_positions_ref : Array[Int]
  mut use_bottom_up : Bool
  mut parent_ref : LNode?
  mut parent_graph_data_ref : GraphInfoHolder?
}

///|
pub fn new_graph_info_holder(
  current_node_order : Array[Array[LNode]],
  parent? : LNode? = None,
  parent_graph_data? : GraphInfoHolder? = None,
  dont_sweep_into? : Bool = false,
  port_positions? : Array[Int] = [],
) -> GraphInfoHolder {
  let actual_port_positions = if port_positions.length() == 0 {
    Array::make(graph_info_count_ports(current_node_order), 0)
  } else {
    port_positions
  }
  {
    current_node_order_ref: current_node_order,
    port_positions_ref: actual_port_positions,
    use_bottom_up: dont_sweep_into,
    parent_ref: parent,
    parent_graph_data_ref: parent_graph_data,
  }
}

///|
pub fn GraphInfoHolder::dont_sweep_into(self : GraphInfoHolder) -> Bool {
  self.use_bottom_up
}

///|
pub fn GraphInfoHolder::set_dont_sweep_into(
  self : GraphInfoHolder,
  dont_sweep_into : Bool,
) -> Unit {
  self.use_bottom_up = dont_sweep_into
}

///|
pub fn GraphInfoHolder::current_node_order(
  self : GraphInfoHolder,
) -> Array[Array[LNode]] {
  self.current_node_order_ref
}

///|
pub fn GraphInfoHolder::set_current_node_order(
  self : GraphInfoHolder,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.current_node_order_ref = node_order
}

///|
pub fn GraphInfoHolder::port_positions(self : GraphInfoHolder) -> Array[Int] {
  self.port_positions_ref
}

///|
pub fn GraphInfoHolder::set_port_positions(
  self : GraphInfoHolder,
  port_positions : Array[Int],
) -> Unit {
  self.port_positions_ref = port_positions
}

///|
pub fn GraphInfoHolder::parent(self : GraphInfoHolder) -> LNode {
  match self.parent_ref {
    Some(parent) => parent
    None => abort("graph info holder has no parent node")
  }
}

///|
pub fn GraphInfoHolder::set_parent(
  self : GraphInfoHolder,
  parent : LNode?,
) -> Unit {
  self.parent_ref = parent
}

///|
pub fn GraphInfoHolder::has_parent(self : GraphInfoHolder) -> Bool {
  match self.parent_ref {
    Some(_) => true
    None => false
  }
}

///|
pub fn GraphInfoHolder::parent_graph_data(
  self : GraphInfoHolder,
) -> GraphInfoHolder {
  match self.parent_graph_data_ref {
    Some(parent_graph_data) => parent_graph_data
    None => abort("graph info holder has no parent graph data")
  }
}

///|
pub fn GraphInfoHolder::set_parent_graph_data(
  self : GraphInfoHolder,
  parent_graph_data : GraphInfoHolder?,
) -> Unit {
  self.parent_graph_data_ref = parent_graph_data
}

///|
pub fn GraphInfoHolder::parent_layer_id(self : GraphInfoHolder) -> Int {
  graph_info_parent_layer_id(self.parent())
}
