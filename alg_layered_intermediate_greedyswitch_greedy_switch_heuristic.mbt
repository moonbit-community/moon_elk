///|
fn GreedySwitchHeuristic::greedy_switch_heuristic_switch_decider(
  self : GreedySwitchHeuristic,
) -> SwitchDecider {
  match self.switch_decider {
    Some(decider) => decider
    None => abort("greedy switch heuristic is not initialized")
  }
}

///|
fn greedy_switch_heuristic_is_one_sided(
  greedy_switch_type : GreedySwitchType,
) -> Bool {
  match greedy_switch_type {
    GreedySwitchType::OneSided => true
    _ => false
  }
}

///|
pub struct GreedySwitchHeuristic {
  greedy_switch_type : GreedySwitchType
  mut current_node_order : Array[Array[LNode]]
  mut switch_decider : SwitchDecider?
  mut port_positions : Array[Int]
  graph_data : GraphInfoHolder
  mut n_ports : Int
}

///|
pub fn new_greedy_switch_heuristic(
  greedy_switch_type : GreedySwitchType,
  graph_data : GraphInfoHolder,
) -> GreedySwitchHeuristic {
  {
    greedy_switch_type,
    current_node_order: [],
    switch_decider: None,
    port_positions: [],
    graph_data,
    n_ports: 0,
  }
}

///|
pub fn GreedySwitchHeuristic::minimize_crossings(
  self : GreedySwitchHeuristic,
  order : Array[Array[LNode]],
  free_layer_index : Int,
  forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool {
  ignore(is_first_sweep)
  self.set_up(order, free_layer_index, forward_sweep)
  self.continue_switching_until_no_improvement_in_layer(free_layer_index)
}

///|
pub fn GreedySwitchHeuristic::set_first_layer_order(
  self : GreedySwitchHeuristic,
  current_order : Array[Array[LNode]],
  is_forward_sweep : Bool,
) -> Bool {
  let start_index = self.start_index(is_forward_sweep, current_order.length())
  self.set_up(current_order, start_index, is_forward_sweep)
  self.sweep_downward_in_layer(start_index)
}

///|
fn GreedySwitchHeuristic::set_up(
  self : GreedySwitchHeuristic,
  order : Array[Array[LNode]],
  free_layer_index : Int,
  forward_sweep : Bool,
) -> Unit {
  self.current_node_order = order
  let side = if forward_sweep {
    CrossingCountSide::West
  } else {
    CrossingCountSide::East
  }
  self.switch_decider = Some(
    self.get_new_switch_decider(free_layer_index, side),
  )
}

///|
fn GreedySwitchHeuristic::get_new_switch_decider(
  self : GreedySwitchHeuristic,
  free_layer_index : Int,
  side : CrossingCountSide,
) -> SwitchDecider {
  let crossing_matrix_filler = new_crossing_matrix_filler(
    self.greedy_switch_type,
    self.current_node_order,
    free_layer_index,
    side,
  )
  let one_sided = greedy_switch_heuristic_is_one_sided(self.greedy_switch_type)
  new_switch_decider(
    free_layer_index,
    self.current_node_order,
    crossing_matrix_filler,
    self.port_positions,
    self.graph_data,
    one_sided,
  )
}

///|
fn GreedySwitchHeuristic::continue_switching_until_no_improvement_in_layer(
  self : GreedySwitchHeuristic,
  free_layer_index : Int,
) -> Bool {
  let mut improved = false
  let mut continue_switching = true
  while continue_switching {
    continue_switching = self.sweep_downward_in_layer(free_layer_index)
    improved = improved || continue_switching
  }
  improved
}

///|
fn GreedySwitchHeuristic::sweep_downward_in_layer(
  self : GreedySwitchHeuristic,
  layer_index : Int,
) -> Bool {
  let mut continue_switching = false
  let length_of_free_layer = self.current_node_order[layer_index].length()
  if length_of_free_layer <= 1 {
    return false
  }
  for upper_node_index in 0..<(length_of_free_layer - 1) {
    let lower_node_index = upper_node_index + 1
    continue_switching = self.switch_if_improves(
        layer_index, upper_node_index, lower_node_index,
      ) ||
      continue_switching
  }
  continue_switching
}

///|
fn GreedySwitchHeuristic::switch_if_improves(
  self : GreedySwitchHeuristic,
  layer_index : Int,
  upper_node_index : Int,
  lower_node_index : Int,
) -> Bool {
  let decider = self.greedy_switch_heuristic_switch_decider()
  if decider.does_switch_reduce_crossings(upper_node_index, lower_node_index) {
    self.exchange_nodes(upper_node_index, lower_node_index, layer_index)
    true
  } else {
    false
  }
}

///|
fn GreedySwitchHeuristic::exchange_nodes(
  self : GreedySwitchHeuristic,
  index_one : Int,
  index_two : Int,
  layer_index : Int,
) -> Unit {
  let decider = self.greedy_switch_heuristic_switch_decider()
  decider.notify_of_switch(
    self.current_node_order[layer_index][index_one],
    self.current_node_order[layer_index][index_two],
  )
  let layer = self.current_node_order[layer_index]
  let temp = layer[index_two]
  layer[index_two] = layer[index_one]
  layer[index_one] = temp
}

///|
fn GreedySwitchHeuristic::start_index(
  self : GreedySwitchHeuristic,
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  ignore(self)
  if is_forward_sweep {
    0
  } else {
    length - 1
  }
}

///|
pub fn GreedySwitchHeuristic::always_improves(
  self : GreedySwitchHeuristic,
) -> Bool {
  !greedy_switch_heuristic_is_one_sided(self.greedy_switch_type)
}

///|
pub fn GreedySwitchHeuristic::is_deterministic(
  self : GreedySwitchHeuristic,
) -> Bool {
  true
}

///|
pub fn GreedySwitchHeuristic::init_at_port_level(
  self : GreedySwitchHeuristic,
  l : Int,
  n : Int,
  p : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(l)
  ignore(n)
  ignore(p)
  ignore(node_order)
  self.n_ports = self.n_ports + 1
}

///|
pub fn GreedySwitchHeuristic::init_at_layer_level(
  self : GreedySwitchHeuristic,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  ignore(self)
  if node_order[l].is_empty() {
    return
  }
  match node_order[l][0].get_layer() {
    Some(layer) => layer.set_id(l)
    None => ()
  }
}

///|
pub fn GreedySwitchHeuristic::init_after_traversal(
  self : GreedySwitchHeuristic,
) -> Unit {
  self.port_positions = Array::make(self.n_ports, 0)
}

///|
pub fn GreedySwitchHeuristic::as_i_crossing_minimization_heuristic(
  self : GreedySwitchHeuristic,
) -> ICrossingMinimizationHeuristic {
  new_i_crossing_minimization_heuristic(
    () => self.always_improves(),
    (node_order, is_forward_sweep) => {
      self.set_first_layer_order(node_order, is_forward_sweep)
    },
    (order, free_layer_index, forward_sweep, is_first_sweep) => {
      self.minimize_crossings(
        order, free_layer_index, forward_sweep, is_first_sweep,
      )
    },
    () => self.is_deterministic(),
    init_at_layer_level=(l, node_order) => {
      self.init_at_layer_level(l, node_order)
    },
    init_at_port_level=(l, n, p, node_order) => {
      self.init_at_port_level(l, n, p, node_order)
    },
    init_after_traversal=() => self.init_after_traversal(),
  )
}

///|
pub fn GreedySwitchHeuristic::as_initializable(
  self : GreedySwitchHeuristic,
) -> IInitializable {
  self.as_i_crossing_minimization_heuristic().as_initializable()
}
