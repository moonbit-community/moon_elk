///|
fn model_order_node_contains(values : Array[Int], value : Int) -> Bool {
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}

///|
fn model_order_node_add_unique(values : Array[Int], value : Int) -> Unit {
  if model_order_node_contains(values, value) {
    return
  }
  values.push(value)
}

///|
fn model_order_node_add_all_unique(
  target : Array[Int],
  source : Array[Int],
) -> Unit {
  for value in source {
    model_order_node_add_unique(target, value)
  }
}

///|
fn model_order_node_associations_get(
  associations : Map[Int, Array[Int]],
  node_handle : Int,
) -> Array[Int] {
  match associations.get(node_handle) {
    Some(values) => values
    None => {
      let values = []
      associations[node_handle] = values
      values
    }
  }
}

///|
fn model_order_node_get_first_incoming_source_port_of_node(
  node : LNode,
) -> LPort? {
  for port in node.get_ports() {
    if !port.get_incoming_edges().is_empty() {
      match port.get_incoming_edges()[0].get_source() {
        Some(source) => return Some(source)
        None => ()
      }
    }
  }
  None
}

///|
fn model_order_node_compare_int(left : Int, right : Int) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn model_order_node_update_compare_result(
  comparator : ModelOrderNodeComparator,
  n1 : LNode,
  n2 : LNode,
  n1_order : Int,
  n2_order : Int,
) -> Int {
  if n1_order > n2_order {
    comparator.update_bigger_and_smaller_associations(n1, n2)
  } else {
    comparator.update_bigger_and_smaller_associations(n2, n1)
  }
  model_order_node_compare_int(n1_order, n2_order)
}

///|
pub struct ModelOrderNodeComparator {
  previous_layer : Array[LNode]
  graph : LGraph
  ordering_strategy : OrderingStrategy
  group_order_strategy : GroupOrderStrategy
  mut bigger_than : Map[Int, Array[Int]]
  mut smaller_than : Map[Int, Array[Int]]
  long_edge_node_order : LongEdgeOrderingStrategy
  before_ports : Bool
}

///|
pub fn new_model_order_node_comparator_from_layer(
  graph : LGraph,
  previous_layer : Layer,
  ordering_strategy : OrderingStrategy,
  long_edge_ordering_strategy : LongEdgeOrderingStrategy,
  group_order_strategy : GroupOrderStrategy,
  before_ports : Bool,
) -> ModelOrderNodeComparator {
  {
    previous_layer: previous_layer.get_nodes().copy(),
    graph,
    ordering_strategy,
    group_order_strategy,
    bigger_than: {},
    smaller_than: {},
    long_edge_node_order: long_edge_ordering_strategy,
    before_ports,
  }
}

///|
pub fn new_model_order_node_comparator(
  graph : LGraph,
  previous_layer : Array[LNode],
  ordering_strategy : OrderingStrategy,
  long_edge_ordering_strategy : LongEdgeOrderingStrategy,
  group_order_strategy : GroupOrderStrategy,
  before_ports : Bool,
) -> ModelOrderNodeComparator {
  {
    previous_layer,
    graph,
    ordering_strategy,
    group_order_strategy,
    bigger_than: {},
    smaller_than: {},
    long_edge_node_order: long_edge_ordering_strategy,
    before_ports,
  }
}

///|
fn ModelOrderNodeComparator::get_model_order_from_connected_edges(
  self : ModelOrderNodeComparator,
  node : LNode,
) -> Int {
  for port in node.get_ports() {
    if !port.get_incoming_edges().is_empty() {
      return port.get_incoming_edges()[0].get_property_int(
        internal_properties_model_order,
      )
    }
  }
  self.long_edge_node_order.return_value()
}

///|
fn ModelOrderNodeComparator::update_bigger_and_smaller_associations(
  self : ModelOrderNodeComparator,
  bigger : LNode,
  smaller : LNode,
) -> Unit {
  let bigger_handle = lnode_internal_handle(bigger)
  let smaller_handle = lnode_internal_handle(smaller)

  let bigger_node_bigger_than = model_order_node_associations_get(
    self.bigger_than,
    bigger_handle,
  )
  let smaller_node_bigger_than = model_order_node_associations_get(
    self.bigger_than,
    smaller_handle,
  )
  let bigger_node_smaller_than = model_order_node_associations_get(
    self.smaller_than,
    bigger_handle,
  )
  let smaller_node_smaller_than = model_order_node_associations_get(
    self.smaller_than,
    smaller_handle,
  )

  model_order_node_add_unique(bigger_node_bigger_than, smaller_handle)
  model_order_node_add_unique(smaller_node_smaller_than, bigger_handle)

  for very_small in smaller_node_bigger_than {
    model_order_node_add_unique(bigger_node_bigger_than, very_small)
    let very_small_smaller_than = model_order_node_associations_get(
      self.smaller_than,
      very_small,
    )
    model_order_node_add_unique(very_small_smaller_than, bigger_handle)
    model_order_node_add_all_unique(
      very_small_smaller_than, bigger_node_smaller_than,
    )
  }

  for very_big in bigger_node_smaller_than {
    model_order_node_add_unique(smaller_node_smaller_than, very_big)
    let very_big_bigger_than = model_order_node_associations_get(
      self.bigger_than,
      very_big,
    )
    model_order_node_add_unique(very_big_bigger_than, smaller_handle)
    model_order_node_add_all_unique(
      very_big_bigger_than, smaller_node_bigger_than,
    )
  }
}

///|
pub fn ModelOrderNodeComparator::compare(
  self : ModelOrderNodeComparator,
  n1 : LNode,
  n2 : LNode,
) -> Int {
  ignore(self.graph)
  ignore(self.group_order_strategy)
  ignore(self.before_ports)

  let n1_handle = lnode_internal_handle(n1)
  let n2_handle = lnode_internal_handle(n2)

  let n1_bigger = model_order_node_associations_get(self.bigger_than, n1_handle)
  if model_order_node_contains(n1_bigger, n2_handle) {
    return 1
  }
  let n2_bigger = model_order_node_associations_get(self.bigger_than, n2_handle)
  if model_order_node_contains(n2_bigger, n1_handle) {
    return -1
  }
  let n1_smaller = model_order_node_associations_get(
    self.smaller_than,
    n1_handle,
  )
  if model_order_node_contains(n1_smaller, n2_handle) {
    return -1
  }
  let n2_smaller = model_order_node_associations_get(
    self.smaller_than,
    n2_handle,
  )
  if model_order_node_contains(n2_smaller, n1_handle) {
    return 1
  }

  if self.ordering_strategy is OrderingStrategy::PreferEdges ||
    !n1.has_property_int(internal_properties_model_order) ||
    !n2.has_property_int(internal_properties_model_order) {
    let p1_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n1,
    )
    let p2_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n2,
    )

    if p1_source_port is Some(source1) && p2_source_port is Some(source2) {
      let p1_node = source1.get_node()
      let p2_node = source2.get_node()
      if p1_node is Some(left_node) && p2_node is Some(right_node) {
        if lnode_internal_handle(left_node) == lnode_internal_handle(right_node) {
          for port in left_node.get_ports() {
            if lport_internal_handle(port) == lport_internal_handle(source1) {
              self.update_bigger_and_smaller_associations(n2, n1)
              return -1
            } else if lport_internal_handle(port) ==
              lport_internal_handle(source2) {
              self.update_bigger_and_smaller_associations(n1, n2)
              return 1
            }
          }
          return model_order_node_update_compare_result(
            self,
            n1,
            n2,
            self.get_model_order_from_connected_edges(n1),
            self.get_model_order_from_connected_edges(n2),
          )
        }

        for previous_node in self.previous_layer {
          if lnode_internal_handle(previous_node) ==
            lnode_internal_handle(left_node) {
            self.update_bigger_and_smaller_associations(n2, n1)
            return -1
          } else if lnode_internal_handle(previous_node) ==
            lnode_internal_handle(right_node) {
            self.update_bigger_and_smaller_associations(n1, n2)
            return 1
          }
        }
      }
    }

    if !n1.has_property_int(internal_properties_model_order) ||
      !n2.has_property_int(internal_properties_model_order) {
      return model_order_node_update_compare_result(
        self,
        n1,
        n2,
        self.get_model_order_from_connected_edges(n1),
        self.get_model_order_from_connected_edges(n2),
      )
    }
  }

  return model_order_node_update_compare_result(
    self,
    n1,
    n2,
    n1.get_property_int(internal_properties_model_order),
    n2.get_property_int(internal_properties_model_order),
  )
}

///|
pub fn ModelOrderNodeComparator::clear_transitive_ordering(
  self : ModelOrderNodeComparator,
) -> Unit {
  self.bigger_than = {}
  self.smaller_than = {}
}
