///|
fn node_relative_calculate_port_ranks(
  distributor : AbstractBarycenterPortDistributor,
  node : LNode,
  rank_sum : Double,
  port_type : PortType,
) -> Double {
  let port_ranks = distributor.get_port_ranks()
  match port_type {
    PortType::Input => {
      let mut input_count = 0
      let mut north_input_count = 0
      for port in node.get_ports() {
        if !port.get_incoming_edges().is_empty() {
          input_count = input_count + 1
          if lnode_port_side_equals(port.get_side(), PortSide::North) {
            north_input_count = north_input_count + 1
          }
        }
      }

      let incr = 1.0 / (input_count + 1).to_double()
      let mut north_pos = rank_sum + north_input_count.to_double() * incr
      let mut rest_pos = rank_sum + 1.0 - incr
      for port in node.get_ports_by_type(PortType::Input) {
        if lnode_port_side_equals(port.get_side(), PortSide::North) {
          port_ranks[port.get_id()] = north_pos
          north_pos = north_pos - incr
        } else {
          port_ranks[port.get_id()] = rest_pos
          rest_pos = rest_pos - incr
        }
      }

      1.0
    }
    PortType::Output => {
      let mut output_count = 0
      for port in node.get_ports() {
        if !port.get_outgoing_edges().is_empty() {
          output_count = output_count + 1
        }
      }

      let incr = 1.0 / (output_count + 1).to_double()
      let mut pos = rank_sum + incr
      for port in node.get_ports_by_type(PortType::Output) {
        port_ranks[port.get_id()] = pos
        pos += incr
      }

      1.0
    }
    PortType::Undefined => abort("Port type is undefined")
  }
}

///|
pub struct NodeRelativePortDistributor {
  distributor : AbstractBarycenterPortDistributor
}

///|
pub fn new_node_relative_port_distributor(
  num_layers : Int,
) -> NodeRelativePortDistributor {
  {
    distributor: new_abstract_barycenter_port_distributor(
      num_layers, node_relative_calculate_port_ranks,
    ),
  }
}

///|
pub fn NodeRelativePortDistributor::get_port_ranks(
  self : NodeRelativePortDistributor,
) -> Array[Double] {
  self.distributor.get_port_ranks()
}

///|
pub fn NodeRelativePortDistributor::distribute_ports_while_sweeping(
  self : NodeRelativePortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  self.distributor.distribute_ports_while_sweeping(
    node_order, current_index, is_forward_sweep,
  )
}

///|
pub fn NodeRelativePortDistributor::calculate_port_ranks(
  self : NodeRelativePortDistributor,
  layer : Array[LNode],
  port_type : PortType,
) -> Unit {
  self.distributor.calculate_port_ranks(layer, port_type)
}

///|
pub fn NodeRelativePortDistributor::init_at_layer_level(
  self : NodeRelativePortDistributor,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_layer_level(l, node_order)
}

///|
pub fn NodeRelativePortDistributor::init_at_node_level(
  self : NodeRelativePortDistributor,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_node_level(l, n, node_order)
}

///|
pub fn NodeRelativePortDistributor::init_at_port_level(
  self : NodeRelativePortDistributor,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_port_level(l, n, p, node_order)
}

///|
pub fn NodeRelativePortDistributor::init_after_traversal(
  self : NodeRelativePortDistributor,
) -> Unit {
  self.distributor.init_after_traversal()
}

///|
pub fn NodeRelativePortDistributor::as_i_sweep_port_distributor(
  self : NodeRelativePortDistributor,
) -> ISweepPortDistributor {
  new_i_sweep_port_distributor(
    (order, free_layer_index, is_forward_sweep) => {
      self.distribute_ports_while_sweeping(
        order, free_layer_index, is_forward_sweep,
      )
    },
    init_at_layer_level=(l, node_order) => {
      self.init_at_layer_level(l, node_order)
    },
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
    init_at_port_level=(l, n, p, node_order) => {
      self.init_at_port_level(l, n, p, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}

///|
pub fn NodeRelativePortDistributor::as_initializable(
  self : NodeRelativePortDistributor,
) -> IInitializable {
  self.as_i_sweep_port_distributor().as_initializable()
}
