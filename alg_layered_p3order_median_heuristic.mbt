///|
let median_heuristic_double_min_value : Double = @double.min_value

///|
fn median_heuristic_weight_compare(left : LNode, right : LNode) -> Int {
  if !left.has_property_double(internal_properties_weight) {
    return 1
  }
  if !right.has_property_double(internal_properties_weight) {
    return -1
  }

  let left_weight = left.get_property_double(internal_properties_weight)
  let right_weight = right.get_property_double(internal_properties_weight)
  if left_weight < right_weight {
    -1
  } else if left_weight > right_weight {
    1
  } else {
    0
  }
}

///|
fn median_heuristic_sort_by_weight(nodes : Array[LNode]) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let node = nodes[i]
    let mut j = i
    while j > 0 && median_heuristic_weight_compare(node, nodes[j - 1]) < 0 {
      nodes[j] = nodes[j - 1]
      j = j - 1
    }
    nodes[j] = node
    i = i + 1
  }
}

///|
fn median_heuristic_node_layer_id(node : LNode?) -> Int? {
  match node {
    Some(n) =>
      match n.get_layer() {
        Some(layer) => Some(layer.get_id())
        None => None
      }
    None => None
  }
}

///|
fn median_heuristic_edge_source_node(edge : LEdge) -> LNode? {
  match edge.get_source() {
    Some(port) => port.get_node()
    None => None
  }
}

///|
fn median_heuristic_edge_target_node(edge : LEdge) -> LNode? {
  match edge.get_target() {
    Some(port) => port.get_node()
    None => None
  }
}

///|
pub struct MedianHeuristic {
  random : @random.Rand
}

///|
pub fn new_median_heuristic(random : @random.Rand) -> MedianHeuristic {
  { random, }
}

///|
pub fn MedianHeuristic::always_improves(self : MedianHeuristic) -> Bool {
  ignore(self)
  false
}

///|
pub fn MedianHeuristic::set_first_layer_order(
  self : MedianHeuristic,
  order : Array[Array[LNode]],
  forward_sweep : Bool,
) -> Bool {
  if order.length() == 0 {
    return false
  }

  let first_index = if forward_sweep {
    0
  } else {
    @cmp.maximum(0, order.length() - 1)
  }
  let first_layer = order[first_index].copy()

  for node in first_layer {
    node.set_property_double(internal_properties_weight, self.random.double())
  }

  median_heuristic_sort_by_weight(first_layer)

  let mut index = 0
  for node in first_layer {
    order[first_index][index] = node
    index = index + 1
    node.set_property_double(internal_properties_weight, index.to_double())
  }

  false
}

///|
pub fn MedianHeuristic::minimize_crossings(
  self : MedianHeuristic,
  order : Array[Array[LNode]],
  free_layer_index : Int,
  forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool {
  ignore(is_first_sweep)
  if free_layer_index < 0 || free_layer_index >= order.length() {
    return false
  }

  let free_layer = order[free_layer_index].copy()
  let reference_layer = if forward_sweep {
    free_layer_index - 1
  } else {
    free_layer_index + 1
  }
  self.calculate_medians(free_layer, reference_layer)
  median_heuristic_sort_by_weight(free_layer)

  let mut index = 0
  for node in free_layer {
    order[free_layer_index][index] = node
    index = index + 1
  }

  false
}

///|
fn MedianHeuristic::calculate_medians(
  self : MedianHeuristic,
  nodes : Array[LNode],
  reference_layer : Int,
) -> Unit {
  ignore(self)
  let mut min_weight = median_heuristic_double_min_value
  let mut max_weight = @double.max_value
  let to_revisit = []

  for node in nodes {
    let connected_nodes = []

    for edge in node.get_incoming_edges() {
      let target = median_heuristic_edge_target_node(edge)
      if median_heuristic_node_layer_id(target) == Some(reference_layer) {
        match target {
          Some(target_node) => connected_nodes.push(target_node)
          None => ()
        }
      }

      let source = median_heuristic_edge_source_node(edge)
      if median_heuristic_node_layer_id(source) == Some(reference_layer) {
        match source {
          Some(source_node) => connected_nodes.push(source_node)
          None => ()
        }
      }
    }

    for edge in node.get_outgoing_edges() {
      let target = median_heuristic_edge_target_node(edge)
      if median_heuristic_node_layer_id(target) == Some(reference_layer) {
        match target {
          Some(target_node) => connected_nodes.push(target_node)
          None => ()
        }
      }

      let source = median_heuristic_edge_source_node(edge)
      if median_heuristic_node_layer_id(source) == Some(reference_layer) {
        match source {
          Some(source_node) => connected_nodes.push(source_node)
          None => ()
        }
      }
    }

    if connected_nodes.is_empty() {
      to_revisit.push(node)
    } else {
      median_heuristic_sort_by_weight(connected_nodes)
      let new_weight = connected_nodes[connected_nodes.length() / 2].get_property_double(
        internal_properties_weight,
      )
      node.set_property_double(internal_properties_weight, new_weight)
      min_weight = @cmp.minimum(min_weight, new_weight)
      max_weight = @cmp.maximum(max_weight, new_weight)
    }
  }

  let average_weight = (max_weight + min_weight) / 2.0
  for node in to_revisit {
    node.set_property_double(internal_properties_weight, average_weight)
  }
}

///|
pub fn MedianHeuristic::is_deterministic(self : MedianHeuristic) -> Bool {
  ignore(self)
  true
}

///|
pub fn MedianHeuristic::as_i_crossing_minimization_heuristic(
  self : MedianHeuristic,
) -> ICrossingMinimizationHeuristic {
  new_i_crossing_minimization_heuristic(
    () => self.always_improves(),
    (order, forward_sweep) => self.set_first_layer_order(order, forward_sweep),
    (order, free_layer_index, forward_sweep, is_first_sweep) => {
      self.minimize_crossings(
        order, free_layer_index, forward_sweep, is_first_sweep,
      )
    },
    () => self.is_deterministic(),
  )
}
