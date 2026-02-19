///|
fn greedy_port_distributor_is_order_fixed(node : LNode) -> Bool {
  let port_constraints_value = if node.has_property_string(
      @core.port_constraints,
    ) {
    node.get_property_string(@core.port_constraints)
  } else {
    @core.port_constraints.get_default()
  }
  abstract_barycenter_port_constraints_from_string(port_constraints_value).is_order_fixed()
}

///|
fn greedy_port_distributor_reverse_ports(ports : Array[LPort]) -> Array[LPort] {
  let reversed = []
  let mut i = ports.length()
  while i > 0 {
    i = i - 1
    reversed.push(ports[i])
  }
  reversed
}

///|
fn greedy_port_distributor_to_node_array(graph : LGraph) -> Array[Array[LNode]] {
  let result = []
  for layer in graph.get_layers() {
    result.push(layer.get_nodes())
  }
  result
}

///|
fn greedy_port_distributor_crossings_counter(
  distributor : GreedyPortDistributor,
) -> CrossingsCounter {
  match distributor.crossings_counter {
    Some(counter) => counter
    None => abort("greedy port distributor is not initialized")
  }
}

///|
fn greedy_port_distributor_hierarchical_counter(
  distributor : GreedyPortDistributor,
) -> BetweenLayerEdgeTwoNodeCrossingsCounter {
  match distributor.hierarchical_crossings_counter {
    Some(counter) => counter
    None => abort("hierarchical crossing counter is not initialized")
  }
}

///|
fn greedy_port_distributor_swap_ports_on_node(
  node : LNode,
  top_port : LPort,
  bottom_port : LPort,
) -> Unit {
  let node_ports = node.get_ports()
  let mut top_index = -1
  let mut bottom_index = -1
  for i in 0..<node_ports.length() {
    let handle = lport_internal_handle(node_ports[i])
    if handle == lport_internal_handle(top_port) {
      top_index = i
    } else if handle == lport_internal_handle(bottom_port) {
      bottom_index = i
    }
  }

  if top_index >= 0 && bottom_index >= 0 {
    let tmp = node_ports[top_index]
    node_ports[top_index] = node_ports[bottom_index]
    node_ports[bottom_index] = tmp
  }
}

///|
pub struct GreedyPortDistributor {
  mut crossings_counter : CrossingsCounter?
  mut n_ports : Int
  mut port_pos : Array[Int]
  mut hierarchical_crossings_counter : BetweenLayerEdgeTwoNodeCrossingsCounter?
}

///|
pub fn new_greedy_port_distributor() -> GreedyPortDistributor {
  {
    crossings_counter: None,
    n_ports: 0,
    port_pos: [],
    hierarchical_crossings_counter: None,
  }
}

///|
fn GreedyPortDistributor::init_for_layers(
  self : GreedyPortDistributor,
  left_layer : Array[LNode],
  right_layer : Array[LNode],
) -> Unit {
  let counter = greedy_port_distributor_crossings_counter(self)
  counter.init_for_counting_between(left_layer, right_layer)
}

///|
fn GreedyPortDistributor::initialize(
  self : GreedyPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Unit {
  if is_forward_sweep && current_index > 0 {
    self.init_for_layers(
      node_order[current_index - 1],
      node_order[current_index],
    )
  } else if !is_forward_sweep && current_index < node_order.length() - 1 {
    self.init_for_layers(
      node_order[current_index],
      node_order[current_index + 1],
    )
  } else {
    let counter = greedy_port_distributor_crossings_counter(self)
    ignore(
      counter.init_port_positions_for_in_layer_crossings(
        node_order[current_index],
        if is_forward_sweep {
          @core.PortSide::West
        } else {
          @core.PortSide::East
        },
      ),
    )
  }
}

///|
fn GreedyPortDistributor::switching_decreases_crossings(
  self : GreedyPortDistributor,
  upper_port : LPort,
  lower_port : LPort,
  use_hierarchical_crosscounter : Bool,
) -> Bool {
  let counter = greedy_port_distributor_crossings_counter(self)
  let original_and_switched = counter.count_crossings_between_ports_in_both_orders(
    upper_port, lower_port,
  )
  let mut upper_lower_crossings = match original_and_switched.get_first() {
    Some(value) => value
    None => 0
  }
  let mut lower_upper_crossings = match original_and_switched.get_second() {
    Some(value) => value
    None => 0
  }

  if use_hierarchical_crosscounter {
    let upper_node = upper_port.get_property_l_node(
      internal_properties_port_dummy,
    )
    let lower_node = lower_port.get_property_l_node(
      internal_properties_port_dummy,
    )
    match (upper_node, lower_node) {
      (Some(upper), Some(lower)) => {
        let hierarchical_counter = greedy_port_distributor_hierarchical_counter(
          self,
        )
        hierarchical_counter.count_both_side_crossings(upper, lower)
        upper_lower_crossings = upper_lower_crossings +
          hierarchical_counter.get_upper_lower_crossings()
        lower_upper_crossings = lower_upper_crossings +
          hierarchical_counter.get_lower_upper_crossings()
      }
      _ => ()
    }
  }

  upper_lower_crossings > lower_upper_crossings
}

///|
fn GreedyPortDistributor::switch_ports(
  self : GreedyPortDistributor,
  ports : Array[LPort],
  node : LNode,
  top_port : Int,
  bottom_port : Int,
) -> Unit {
  let counter = greedy_port_distributor_crossings_counter(self)
  counter.switch_ports(ports[top_port], ports[bottom_port])

  let lower = ports[bottom_port]
  ports[bottom_port] = ports[top_port]
  ports[top_port] = lower
  greedy_port_distributor_swap_ports_on_node(
    node,
    ports[top_port],
    ports[bottom_port],
  )
}

///|
fn GreedyPortDistributor::distribute_ports_on_node(
  self : GreedyPortDistributor,
  node : LNode,
  side : @core.PortSide,
  use_hierarchical_crosscounter : Bool,
) -> Bool {
  let ports = if lnode_port_side_equals(side, @core.PortSide::South) ||
    lnode_port_side_equals(side, @core.PortSide::West) {
    greedy_port_distributor_reverse_ports(node.get_port_side_view(side))
  } else {
    node.get_port_side_view(side)
  }

  let mut improved = false
  let mut continue_switching = true
  while continue_switching {
    continue_switching = false
    if ports.length() > 1 {
      for i in 0..<(ports.length() - 1) {
        let upper_port = ports[i]
        let lower_port = ports[i + 1]
        if self.switching_decreases_crossings(
            upper_port, lower_port, use_hierarchical_crosscounter,
          ) {
          improved = true
          self.switch_ports(ports, node, i, i + 1)
          continue_switching = true
        }
      }
    }
  }

  improved
}

///|
fn GreedyPortDistributor::distribute_ports_in_layer(
  self : GreedyPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  let side = if is_forward_sweep {
    @core.PortSide::West
  } else {
    @core.PortSide::East
  }
  let mut improved = false

  for node in node_order[current_index] {
    if greedy_port_distributor_is_order_fixed(node) {
      continue
    }

    let nested_graph = node.get_nested_graph()
    let has_nested_graph = match nested_graph {
      Some(_) => true
      None => false
    }
    let use_hierarchical_crosscounter = !node
      .get_port_side_view(side)
      .is_empty() &&
      has_nested_graph
    if use_hierarchical_crosscounter {
      match nested_graph {
        Some(inner) => {
          let inner_graph = greedy_port_distributor_to_node_array(inner)
          self.hierarchical_crossings_counter = Some(
            new_between_layer_edge_two_node_crossings_counter(
              inner_graph,
              if is_forward_sweep {
                0
              } else {
                inner_graph.length() - 1
              },
            ),
          )
        }
        None => ()
      }
    }

    improved = self.distribute_ports_on_node(
        node, side, use_hierarchical_crosscounter,
      ) ||
      improved
  }

  improved
}

///|
pub fn GreedyPortDistributor::distribute_ports_while_sweeping(
  self : GreedyPortDistributor,
  node_order : Array[Array[LNode]],
  current_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  self.initialize(node_order, current_index, is_forward_sweep)
  self.distribute_ports_in_layer(node_order, current_index, is_forward_sweep)
}

///|
pub fn GreedyPortDistributor::init_at_node_level(
  self : GreedyPortDistributor,
  l : Int,
  n : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  let node = node_order[l][n]
  self.n_ports = self.n_ports + node.get_ports().length()
}

///|
pub fn GreedyPortDistributor::init_after_traversal(
  self : GreedyPortDistributor,
) -> Unit {
  self.port_pos = Array::make(self.n_ports, 0)
  self.crossings_counter = Some(new_crossings_counter(self.port_pos))
}

///|
pub fn GreedyPortDistributor::as_i_sweep_port_distributor(
  self : GreedyPortDistributor,
) -> ISweepPortDistributor {
  new_i_sweep_port_distributor(
    (node_order, current_index, is_forward_sweep) => {
      self.distribute_ports_while_sweeping(
        node_order, current_index, is_forward_sweep,
      )
    },
    init_at_node_level=(l, n, node_order) => {
      self.init_at_node_level(l, n, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}

///|
pub fn GreedyPortDistributor::as_initializable(
  self : GreedyPortDistributor,
) -> IInitializable {
  self.as_i_sweep_port_distributor().as_initializable()
}
