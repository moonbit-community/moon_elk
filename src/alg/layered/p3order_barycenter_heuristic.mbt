///|
let barycenter_heuristic_random_amount : Double = 0.07

///|
fn barycenter_predecessor_ports(port : LPort) -> Array[LPort] {
  let predecessor_ports = []
  for edge in port.get_incoming_edges() {
    match edge.get_source() {
      Some(source) => predecessor_ports.push(source)
      None => ()
    }
  }
  predecessor_ports
}

///|
fn barycenter_successor_ports(port : LPort) -> Array[LPort] {
  let successor_ports = []
  for edge in port.get_outgoing_edges() {
    match edge.get_target() {
      Some(target) => successor_ports.push(target)
      None => ()
    }
  }
  successor_ports
}

///|
fn barycenter_same_layer(left : LNode, right : LNode) -> Bool {
  match (left.get_layer(), right.get_layer()) {
    (Some(left_layer), Some(right_layer)) =>
      layer_internal_handle(left_layer) == layer_internal_handle(right_layer)
    _ => false
  }
}

///|
fn barycenter_is_same_node(left : LNode, right : LNode) -> Bool {
  lnode_internal_handle(left) == lnode_internal_handle(right)
}

///|
fn barycenter_compare_doubles(left : Double, right : Double) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn barycenter_sort_nodes(
  nodes : Array[LNode],
  compare : (LNode, LNode) -> Int,
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let node = nodes[i]
    let mut j = i
    while j > 0 && compare(nodes[j - 1], node) > 0 {
      nodes[j] = nodes[j - 1]
      j = j - 1
    }
    nodes[j] = node
    i = i + 1
  }
}

///|
fn barycenter_change_index(direction : Bool) -> Int {
  if direction {
    1
  } else {
    -1
  }
}

///|
fn barycenter_port_type_for(direction : Bool) -> PortType {
  if direction {
    PortType::Output
  } else {
    PortType::Input
  }
}

///|
fn barycenter_start_index(direction : Bool, length : Int) -> Int {
  if direction {
    0
  } else {
    @cmp.maximum(0, length - 1)
  }
}

///|
fn barycenter_is_first_layer(
  node_order : Array[Array[LNode]],
  current_index : Int,
  forward_sweep : Bool,
) -> Bool {
  current_index == barycenter_start_index(forward_sweep, node_order.length())
}

///|
pub struct BarycenterHeuristic {
  mut port_ranks : Array[Double]
  random : MockRandom
  constraint_resolver : ForsterConstraintResolver
  mut barycenter_state : Array[Array[BarycenterState?]]
  port_distributor : AbstractBarycenterPortDistributor
}

///|
pub fn new_barycenter_heuristic(
  constraint_resolver : ForsterConstraintResolver,
  random : MockRandom,
  port_distributor : AbstractBarycenterPortDistributor,
  graph : Array[Array[LNode]],
) -> BarycenterHeuristic {
  ignore(graph)
  {
    port_ranks: [],
    random,
    constraint_resolver,
    barycenter_state: [],
    port_distributor,
  }
}

///|
fn BarycenterHeuristic::state_of(
  self : BarycenterHeuristic,
  node : LNode,
) -> BarycenterState {
  let layer_id = match node.get_layer() {
    Some(layer) => layer.get_id()
    None => abort("node has no layer")
  }
  let node_id = node.get_id()
  match self.barycenter_state[layer_id][node_id] {
    Some(state) => state
    None => abort("barycenter state is not initialized")
  }
}

///|
fn BarycenterHeuristic::randomize_barycenters(
  self : BarycenterHeuristic,
  nodes : Array[LNode],
) -> Unit {
  for node in nodes {
    let state = self.state_of(node)
    let barycenter = self.random.next_double()
    state.barycenter = Some(barycenter)
    state.summed_weight = barycenter
    state.degree = 1
  }
}

///|
fn BarycenterHeuristic::fill_in_unknown_barycenters(
  self : BarycenterHeuristic,
  nodes : Array[LNode],
  pre_ordered : Bool,
) -> Unit {
  if pre_ordered {
    let mut last_value = -1.0
    let mut index = 0
    while index < nodes.length() {
      let node = nodes[index]
      match self.state_of(node).barycenter {
        Some(value) => last_value = value
        None => {
          let mut next_value = last_value + 1.0
          let mut next_index = index + 1
          while next_index < nodes.length() {
            match self.state_of(nodes[next_index]).barycenter {
              Some(value) => {
                next_value = value
                break
              }
              None => ()
            }
            next_index = next_index + 1
          }

          let value = (last_value + next_value) / 2.0
          let state = self.state_of(node)
          state.barycenter = Some(value)
          state.summed_weight = value
          state.degree = 1
          last_value = value
        }
      }
      index = index + 1
    }
  } else {
    let mut max_barycenter = 0.0
    for node in nodes {
      match self.state_of(node).barycenter {
        Some(value) => max_barycenter = @cmp.maximum(max_barycenter, value)
        None => ()
      }
    }

    max_barycenter = max_barycenter + 2.0
    for node in nodes {
      let state = self.state_of(node)
      match state.barycenter {
        Some(_) => ()
        None => {
          let value = self.random.next_float().to_double() * max_barycenter -
            1.0
          state.barycenter = Some(value)
          state.summed_weight = value
          state.degree = 1
        }
      }
    }
  }
}

///|
fn BarycenterHeuristic::calculate_barycenters(
  self : BarycenterHeuristic,
  nodes : Array[LNode],
  forward : Bool,
) -> Unit {
  for node in nodes {
    self.state_of(node).visited = false
  }

  for node in nodes {
    self.calculate_barycenter(node, forward)
  }
}

///|
fn BarycenterHeuristic::calculate_barycenter(
  self : BarycenterHeuristic,
  node : LNode,
  forward : Bool,
) -> Unit {
  let state = self.state_of(node)
  if state.visited {
    return
  } else {
    state.visited = true
  }

  state.degree = 0
  state.summed_weight = 0.0
  state.barycenter = None

  for free_port in node.get_ports() {
    let fixed_ports = if forward {
      barycenter_predecessor_ports(free_port)
    } else {
      barycenter_successor_ports(free_port)
    }
    for fixed_port in fixed_ports {
      let fixed_node = match fixed_port.get_node() {
        Some(node) => node
        None => continue
      }

      if barycenter_same_layer(fixed_node, node) {
        if !barycenter_is_same_node(fixed_node, node) {
          self.calculate_barycenter(fixed_node, forward)
          let fixed_state = self.state_of(fixed_node)
          state.degree = state.degree + fixed_state.degree
          state.summed_weight = state.summed_weight + fixed_state.summed_weight
        }
      } else {
        let fixed_port_id = fixed_port.get_id()
        state.summed_weight = state.summed_weight +
          self.port_ranks[fixed_port_id]
        state.degree = state.degree + 1
      }
    }
  }

  if node.has_property_l_node_array(internal_properties_barycenter_associates) {
    for
      associate in node.get_property_l_node_array(
        internal_properties_barycenter_associates,
      ) {
      if barycenter_same_layer(node, associate) {
        self.calculate_barycenter(associate, forward)
        let associate_state = self.state_of(associate)
        state.degree = state.degree + associate_state.degree
        state.summed_weight = state.summed_weight +
          associate_state.summed_weight
      }
    }
  }

  if state.degree > 0 {
    state.summed_weight = state.summed_weight +
      self.random.next_float().to_double() * barycenter_heuristic_random_amount -
      barycenter_heuristic_random_amount / 2.0
    state.barycenter = Some(state.summed_weight / state.degree.to_double())
  }
}

///|
fn BarycenterHeuristic::compare_nodes(
  self : BarycenterHeuristic,
  first : LNode,
  second : LNode,
) -> Int {
  let first_state = self.state_of(first)
  let second_state = self.state_of(second)
  match (first_state.barycenter, second_state.barycenter) {
    (Some(first_barycenter), Some(second_barycenter)) =>
      barycenter_compare_doubles(first_barycenter, second_barycenter)
    (Some(_), None) => -1
    (None, Some(_)) => 1
    _ => 0
  }
}

///|
pub fn BarycenterHeuristic::minimize_crossings_layer(
  self : BarycenterHeuristic,
  layer : Array[LNode],
  pre_ordered : Bool,
  randomize : Bool,
  forward : Bool,
) -> Unit {
  if randomize {
    self.randomize_barycenters(layer)
  } else {
    self.calculate_barycenters(layer, forward)
    self.fill_in_unknown_barycenters(layer, pre_ordered)
  }

  if layer.length() > 1 {
    barycenter_sort_nodes(layer, (left, right) => {
      self.compare_nodes(left, right)
    })
    self.constraint_resolver.process_constraints(layer)
  }
}

///|
pub fn BarycenterHeuristic::minimize_crossings(
  self : BarycenterHeuristic,
  order : Array[Array[LNode]],
  free_layer_index : Int,
  forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool {
  if order.is_empty() ||
    free_layer_index < 0 ||
    free_layer_index >= order.length() ||
    order[free_layer_index].is_empty() {
    return false
  }

  if !barycenter_is_first_layer(order, free_layer_index, forward_sweep) {
    let fixed_layer = order[free_layer_index -
      barycenter_change_index(forward_sweep)]
    self.port_distributor.calculate_port_ranks(
      fixed_layer,
      barycenter_port_type_for(forward_sweep),
    )
  }

  let first_node_in_layer = order[free_layer_index][0]
  let pre_ordered = if !is_first_sweep {
    true
  } else {
    match first_node_in_layer.get_type() {
      NodeType::ExternalPort => true
      _ => false
    }
  }

  let nodes = order[free_layer_index].copy()
  self.minimize_crossings_layer(nodes, pre_ordered, false, forward_sweep)
  for i in 0..<nodes.length() {
    order[free_layer_index][i] = nodes[i]
  }

  false
}

///|
pub fn BarycenterHeuristic::set_first_layer_order(
  self : BarycenterHeuristic,
  order : Array[Array[LNode]],
  is_forward_sweep : Bool,
) -> Bool {
  if order.is_empty() {
    return false
  }

  let start_index = barycenter_start_index(is_forward_sweep, order.length())
  if order[start_index].is_empty() {
    return false
  }

  let nodes = order[start_index].copy()
  self.minimize_crossings_layer(nodes, false, true, is_forward_sweep)
  for i in 0..<nodes.length() {
    order[start_index][i] = nodes[i]
  }

  false
}

///|
pub fn BarycenterHeuristic::always_improves(self : BarycenterHeuristic) -> Bool {
  ignore(self)
  false
}

///|
pub fn BarycenterHeuristic::is_deterministic(
  self : BarycenterHeuristic,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn BarycenterHeuristic::init_after_traversal(
  self : BarycenterHeuristic,
) -> Unit {
  self.barycenter_state = self.constraint_resolver.get_barycenter_states()
  self.port_ranks = self.port_distributor.get_port_ranks()
}

///|
pub fn BarycenterHeuristic::init_at_layer_level(
  self : BarycenterHeuristic,
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
pub fn BarycenterHeuristic::as_i_crossing_minimization_heuristic(
  self : BarycenterHeuristic,
) -> ICrossingMinimizationHeuristic {
  new_i_crossing_minimization_heuristic(
    () => self.always_improves(),
    (order, is_forward_sweep) => {
      self.set_first_layer_order(order, is_forward_sweep)
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
    init_after_traversal=() => self.init_after_traversal(),
  )
}
