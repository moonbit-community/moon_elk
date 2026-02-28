///|
fn model_order_barycenter_contains(values : Array[Int], value : Int) -> Bool {
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}

///|
fn model_order_barycenter_add_unique(values : Array[Int], value : Int) -> Unit {
  if model_order_barycenter_contains(values, value) {
    return
  }
  values.push(value)
}

///|
fn model_order_barycenter_add_all_unique(
  target : Array[Int],
  source : Array[Int],
) -> Unit {
  for value in source {
    model_order_barycenter_add_unique(target, value)
  }
}

///|
fn model_order_barycenter_associations_for(
  associations : Map[Int, Array[Int]],
  node_handle : Int,
) -> Array[Int] {
  match associations.get(node_handle) {
    Some(values) => values
    None => {
      associations[node_handle] = []
      match associations.get(node_handle) {
        Some(values) => values
        None => {
          @core.layout_runtime_report_unsupported_configuration(
            "association map entry initialization failed",
          )
          []
        }
      }
    }
  }
}

///|
fn model_order_barycenter_compare_int(left : Int, right : Int) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
pub struct ModelOrderBarycenterHeuristic {
  base : BarycenterHeuristic
  mut bigger_than : Map[Int, Array[Int]]
  mut smaller_than : Map[Int, Array[Int]]
}

///|
pub fn new_model_order_barycenter_heuristic(
  constraint_resolver : ForsterConstraintResolver,
  random : MockRandom,
  port_distributor : AbstractBarycenterPortDistributor,
  graph : Array[Array[LNode]],
) -> ModelOrderBarycenterHeuristic {
  {
    base: new_barycenter_heuristic(
      constraint_resolver, random, port_distributor, graph,
    ),
    bigger_than: {},
    smaller_than: {},
  }
}

///|
pub fn ModelOrderBarycenterHeuristic::clear_transitive_ordering(
  self : ModelOrderBarycenterHeuristic,
) -> Unit {
  self.bigger_than = {}
  self.smaller_than = {}
}

///|
fn ModelOrderBarycenterHeuristic::compare_based_on_transitive_dependencies(
  self : ModelOrderBarycenterHeuristic,
  first : LNode,
  second : LNode,
) -> Int {
  let first_handle = lnode_internal_handle(first)
  let second_handle = lnode_internal_handle(second)

  let first_bigger_than = model_order_barycenter_associations_for(
    self.bigger_than,
    first_handle,
  )
  if model_order_barycenter_contains(first_bigger_than, second_handle) {
    return 1
  }
  let second_bigger_than = model_order_barycenter_associations_for(
    self.bigger_than,
    second_handle,
  )
  if model_order_barycenter_contains(second_bigger_than, first_handle) {
    return -1
  }

  let first_smaller_than = model_order_barycenter_associations_for(
    self.smaller_than,
    first_handle,
  )
  if model_order_barycenter_contains(first_smaller_than, second_handle) {
    return -1
  }
  let second_smaller_than = model_order_barycenter_associations_for(
    self.smaller_than,
    second_handle,
  )
  if model_order_barycenter_contains(second_smaller_than, first_handle) {
    return 1
  }

  0
}

///|
fn ModelOrderBarycenterHeuristic::update_bigger_and_smaller_associations(
  self : ModelOrderBarycenterHeuristic,
  bigger : LNode,
  smaller : LNode,
) -> Unit {
  let bigger_handle = lnode_internal_handle(bigger)
  let smaller_handle = lnode_internal_handle(smaller)

  let bigger_node_bigger_than = model_order_barycenter_associations_for(
    self.bigger_than,
    bigger_handle,
  )
  let smaller_node_bigger_than = model_order_barycenter_associations_for(
    self.bigger_than,
    smaller_handle,
  )
  let bigger_node_smaller_than = model_order_barycenter_associations_for(
    self.smaller_than,
    bigger_handle,
  )
  let smaller_node_smaller_than = model_order_barycenter_associations_for(
    self.smaller_than,
    smaller_handle,
  )

  model_order_barycenter_add_unique(bigger_node_bigger_than, smaller_handle)
  model_order_barycenter_add_unique(smaller_node_smaller_than, bigger_handle)

  for very_small in smaller_node_bigger_than {
    model_order_barycenter_add_unique(bigger_node_bigger_than, very_small)
    let very_small_smaller_than = model_order_barycenter_associations_for(
      self.smaller_than,
      very_small,
    )
    model_order_barycenter_add_unique(very_small_smaller_than, bigger_handle)
    model_order_barycenter_add_all_unique(
      very_small_smaller_than, bigger_node_smaller_than,
    )
  }

  for very_big in bigger_node_smaller_than {
    model_order_barycenter_add_unique(smaller_node_smaller_than, very_big)
    let very_big_bigger_than = model_order_barycenter_associations_for(
      self.bigger_than,
      very_big,
    )
    model_order_barycenter_add_unique(very_big_bigger_than, smaller_handle)
    model_order_barycenter_add_all_unique(
      very_big_bigger_than, smaller_node_bigger_than,
    )
  }
}

///|
fn ModelOrderBarycenterHeuristic::compare_based_on_barycenter(
  self : ModelOrderBarycenterHeuristic,
  first : LNode,
  second : LNode,
) -> Int {
  let first_state = self.base.state_of(first)
  let second_state = self.base.state_of(second)

  match (first_state.barycenter, second_state.barycenter) {
    (Some(first_value), Some(second_value)) => {
      let value = barycenter_compare_doubles(first_value, second_value)
      if value < 0 {
        self.update_bigger_and_smaller_associations(first, second)
      } else if value > 0 {
        self.update_bigger_and_smaller_associations(second, first)
      }
      value
    }
    (Some(_), None) => {
      self.update_bigger_and_smaller_associations(first, second)
      -1
    }
    (None, Some(_)) => {
      self.update_bigger_and_smaller_associations(second, first)
      1
    }
    _ => 0
  }
}

///|
fn ModelOrderBarycenterHeuristic::compare_nodes(
  self : ModelOrderBarycenterHeuristic,
  first : LNode,
  second : LNode,
) -> Int {
  let transitive_comparison = self.compare_based_on_transitive_dependencies(
    first, second,
  )
  if transitive_comparison != 0 {
    return transitive_comparison
  }

  if first.has_property_int(internal_properties_model_order) &&
    second.has_property_int(internal_properties_model_order) {
    let value = model_order_barycenter_compare_int(
      first.get_property_int(internal_properties_model_order),
      second.get_property_int(internal_properties_model_order),
    )
    if value < 0 {
      self.update_bigger_and_smaller_associations(first, second)
      return value
    } else if value > 0 {
      self.update_bigger_and_smaller_associations(second, first)
      return value
    }
  }

  self.compare_based_on_barycenter(first, second)
}

///|
pub fn model_order_barycenter_heuristic_insertion_sort(
  layer : Array[LNode],
  comparator : (LNode, LNode) -> Int,
  barycenter_heuristic : ModelOrderBarycenterHeuristic,
) -> Unit {
  let mut i = 1
  while i < layer.length() {
    let current = layer[i]
    let mut j = i
    while j > 0 && comparator(layer[j - 1], current) > 0 {
      layer[j] = layer[j - 1]
      j -= 1
    }
    layer[j] = current
    i += 1
  }
  barycenter_heuristic.clear_transitive_ordering()
}

///|
pub fn ModelOrderBarycenterHeuristic::minimize_crossings_layer(
  self : ModelOrderBarycenterHeuristic,
  layer : Array[LNode],
  pre_ordered : Bool,
  randomize : Bool,
  forward : Bool,
) -> Unit {
  if randomize {
    self.base.randomize_barycenters(layer)
  } else {
    self.base.calculate_barycenters(layer, forward)
    self.base.fill_in_unknown_barycenters(layer, pre_ordered)
  }

  if layer.length() > 1 {
    let force_model_order = layer[0]
      .get_graph()
      .get_property_bool(
        layered_options_crossing_minimization_force_node_model_order,
      )
    if force_model_order {
      model_order_barycenter_heuristic_insertion_sort(
        layer,
        (first, second) => self.compare_nodes(first, second),
        self,
      )
    } else {
      barycenter_sort_nodes(layer, (first, second) => {
        self.compare_nodes(first, second)
      })
    }

    if !force_model_order {
      self.base.constraint_resolver.process_constraints(layer)
    }
  }
}

///|
pub fn ModelOrderBarycenterHeuristic::set_first_layer_order(
  self : ModelOrderBarycenterHeuristic,
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
pub fn ModelOrderBarycenterHeuristic::minimize_crossings(
  self : ModelOrderBarycenterHeuristic,
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
    self.base.port_distributor.calculate_port_ranks(
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
pub fn ModelOrderBarycenterHeuristic::always_improves(
  self : ModelOrderBarycenterHeuristic,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn ModelOrderBarycenterHeuristic::is_deterministic(
  self : ModelOrderBarycenterHeuristic,
) -> Bool {
  ignore(self)
  false
}

///|
pub fn ModelOrderBarycenterHeuristic::init_after_traversal(
  self : ModelOrderBarycenterHeuristic,
) -> Unit {
  self.base.init_after_traversal()
}

///|
pub fn ModelOrderBarycenterHeuristic::init_at_layer_level(
  self : ModelOrderBarycenterHeuristic,
  l : Int,
  node_order : Array[Array[LNode]],
) -> Unit {
  self.base.init_at_layer_level(l, node_order)
}

///|
pub fn ModelOrderBarycenterHeuristic::as_i_crossing_minimization_heuristic(
  self : ModelOrderBarycenterHeuristic,
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
