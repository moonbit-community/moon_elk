///|
fn layer_total_calculate_port_ranks(
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
          if lnode_port_side_equals(port.get_side(), @core.PortSide::North) {
            north_input_count = north_input_count + 1
          }
        }
      }

      let mut north_pos = rank_sum + north_input_count.to_double()
      let mut rest_pos = rank_sum + input_count.to_double()
      for port in node.get_ports_by_type(PortType::Input) {
        if lnode_port_side_equals(port.get_side(), @core.PortSide::North) {
          port_ranks[port.get_id()] = north_pos
          north_pos = north_pos - 1.0
        } else {
          port_ranks[port.get_id()] = rest_pos
          rest_pos = rest_pos - 1.0
        }
      }

      input_count.to_double()
    }
    PortType::Output => {
      let mut pos = 0
      for port in node.get_ports_by_type(PortType::Output) {
        pos = pos + 1
        port_ranks[port.get_id()] = rank_sum + pos.to_double()
      }
      pos.to_double()
    }
    PortType::Undefined => abort("Port type is undefined")
  }
}

///|
pub struct LayerTotalPortDistributor {
  distributor : AbstractBarycenterPortDistributor
}

///|
pub fn new_layer_total_port_distributor(
  num_layers : Int,
) -> LayerTotalPortDistributor {
  {
    distributor: new_abstract_barycenter_port_distributor(
      num_layers, layer_total_calculate_port_ranks,
    ),
  }
}

///|
pub fn LayerTotalPortDistributor::get_port_ranks(
  self : LayerTotalPortDistributor,
) -> Array[Double] {
  self.distributor.get_port_ranks()
}

///|
pub fn LayerTotalPortDistributor::distribute_ports_while_sweeping(
  self : LayerTotalPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  self.distributor.distribute_ports_while_sweeping(
    node_order, current_index, is_forward_sweep,
  )
}

///|
pub fn LayerTotalPortDistributor::calculate_port_ranks(
  self : LayerTotalPortDistributor,
  layer : Array[LNode],
  port_type : PortType,
) -> Unit {
  self.distributor.calculate_port_ranks(layer, port_type)
}

///|
pub fn LayerTotalPortDistributor::init_at_layer_level(
  self : LayerTotalPortDistributor,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_layer_level(l, node_order)
}

///|
pub fn LayerTotalPortDistributor::init_at_node_level(
  self : LayerTotalPortDistributor,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_node_level(l, n, node_order)
}

///|
pub fn LayerTotalPortDistributor::init_at_port_level(
  self : LayerTotalPortDistributor,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.distributor.init_at_port_level(l, n, p, node_order)
}

///|
pub fn LayerTotalPortDistributor::init_after_traversal(
  self : LayerTotalPortDistributor,
) -> Unit {
  self.distributor.init_after_traversal()
}

///|
pub fn LayerTotalPortDistributor::as_i_sweep_port_distributor(
  self : LayerTotalPortDistributor,
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
pub fn LayerTotalPortDistributor::as_initializable(
  self : LayerTotalPortDistributor,
) -> IInitializable {
  self.as_i_sweep_port_distributor().as_initializable()
}
