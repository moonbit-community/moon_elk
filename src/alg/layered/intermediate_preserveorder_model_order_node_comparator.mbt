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
fn model_order_node_layer_id(node : LNode) -> Int {
  match node.get_layer() {
    Some(layer) => layer.get_id()
    None => 0
  }
}

///|
fn model_order_node_type_equals(left : NodeType, right : NodeType) -> Bool {
  match (left, right) {
    (NodeType::Normal, NodeType::Normal) => true
    (NodeType::LongEdge, NodeType::LongEdge) => true
    (NodeType::ExternalPort, NodeType::ExternalPort) => true
    (NodeType::NorthSouthPort, NodeType::NorthSouthPort) => true
    (NodeType::LabelNode, NodeType::LabelNode) => true
    (NodeType::BreakingPoint, NodeType::BreakingPoint) => true
    (NodeType::Placeholder, NodeType::Placeholder) => true
    (NodeType::NonshiftingPlaceholder, NodeType::NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn model_order_node_strategy_is_prefer_edges(
  strategy : OrderingStrategy,
) -> Bool {
  match strategy {
    OrderingStrategy::PreferEdges => true
    _ => false
  }
}

///|
fn model_order_node_port_node(port : LPort?) -> LNode? {
  match port {
    Some(value) => value.get_node()
    None => None
  }
}

///|
fn model_order_node_first_source_port_connected_to_previous_layer(
  node : LNode,
) -> LPort? {
  let node_layer_id = model_order_node_layer_id(node)
  for port in node.get_ports() {
    if !port.get_incoming_edges().is_empty() {
      let source = match port.get_incoming_edges()[0].get_source() {
        Some(value) => value
        None => continue
      }
      let source_node = match source.get_node() {
        Some(value) => value
        None => continue
      }
      if model_order_node_layer_id(source_node) == node_layer_id - 1 {
        return Some(source)
      }
    }
  }
  None
}

///|
fn model_order_node_get_first_incoming_port_of_node(node : LNode) -> LPort? {
  for port in node.get_ports() {
    if !port.get_incoming_edges().is_empty() {
      return Some(port)
    }
  }
  None
}

///|
fn model_order_node_get_first_incoming_source_port_of_node(
  node : LNode,
) -> LPort? {
  let incoming_port = model_order_node_get_first_incoming_port_of_node(node)
  match incoming_port {
    Some(port) =>
      match port.get_incoming_edges()[0].get_source() {
        Some(source) => Some(source)
        None => None
      }
    None => None
  }
}

///|
fn model_order_node_get_first_outgoing_port_of_node(node : LNode) -> LPort? {
  for port in node.get_ports() {
    if !port.get_outgoing_edges().is_empty() {
      return Some(port)
    }
  }
  None
}

///|
fn model_order_node_get_first_outgoing_target_port_of_node(
  node : LNode,
) -> LPort? {
  let outgoing_port = model_order_node_get_first_outgoing_port_of_node(node)
  match outgoing_port {
    Some(port) =>
      match port.get_outgoing_edges()[0].get_target() {
        Some(target) => Some(target)
        None => None
      }
    None => None
  }
}

///|
fn model_order_node_require_max_model_order_nodes(graph : LGraph) -> Int {
  graph.get_property_int(internal_properties_max_model_order_nodes)
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
      let edge = port.get_incoming_edges()[0]
      return edge.get_property_int(internal_properties_model_order)
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
fn ModelOrderNodeComparator::handle_helper_dummy_nodes(
  self : ModelOrderNodeComparator,
  n1 : LNode,
  n2 : LNode,
) -> Int {
  if model_order_node_type_equals(n1.get_type(), NodeType::LongEdge) &&
    model_order_node_type_equals(n2.get_type(), NodeType::Normal) {
    let dummy_node_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n1,
    )
    let dummy_node_target_port = model_order_node_get_first_outgoing_target_port_of_node(
      n1,
    )
    let dummy_node_source_node = model_order_node_port_node(
      dummy_node_source_port,
    )
    let dummy_node_target_node = model_order_node_port_node(
      dummy_node_target_port,
    )
    if dummy_node_source_node is None || dummy_node_target_node is None {
      return 0
    }
    let dummy_node_source_node = match dummy_node_source_node {
      Some(value) => value
      None => return 0
    }
    let dummy_node_target_node = match dummy_node_target_node {
      Some(value) => value
      None => return 0
    }
    let dummy_layer_id = model_order_node_layer_id(n1)

    if model_order_node_layer_id(dummy_node_source_node) != dummy_layer_id &&
      model_order_node_layer_id(dummy_node_target_node) != dummy_layer_id {
      return 0
    }

    if lnode_internal_handle(dummy_node_source_node) ==
      lnode_internal_handle(n2) {
      self.update_bigger_and_smaller_associations(n1, n2)
      return 1
    } else {
      if lnode_internal_handle(dummy_node_target_node) ==
        lnode_internal_handle(n2) {
        self.update_bigger_and_smaller_associations(n1, n2)
        return 1
      }
      return self.compare(dummy_node_source_node, n2)
    }
  } else if model_order_node_type_equals(n1.get_type(), NodeType::Normal) &&
    model_order_node_type_equals(n2.get_type(), NodeType::LongEdge) {
    let dummy_node_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n2,
    )
    let dummy_node_target_port = model_order_node_get_first_outgoing_target_port_of_node(
      n2,
    )
    let dummy_node_source_node = model_order_node_port_node(
      dummy_node_source_port,
    )
    let dummy_node_target_node = model_order_node_port_node(
      dummy_node_target_port,
    )
    if dummy_node_source_node is None || dummy_node_target_node is None {
      return 0
    }
    let dummy_node_source_node = match dummy_node_source_node {
      Some(value) => value
      None => return 0
    }
    let dummy_node_target_node = match dummy_node_target_node {
      Some(value) => value
      None => return 0
    }
    let dummy_layer_id = model_order_node_layer_id(n1)

    if model_order_node_layer_id(dummy_node_source_node) != dummy_layer_id &&
      model_order_node_layer_id(dummy_node_target_node) != dummy_layer_id {
      return 0
    }

    if lnode_internal_handle(dummy_node_source_node) ==
      lnode_internal_handle(n1) {
      self.update_bigger_and_smaller_associations(n2, n1)
      return -1
    } else {
      if lnode_internal_handle(dummy_node_target_node) ==
        lnode_internal_handle(n1) {
        self.update_bigger_and_smaller_associations(n2, n1)
        return -1
      }
      return self.compare(n1, dummy_node_source_node)
    }
  } else if model_order_node_type_equals(n1.get_type(), NodeType::LongEdge) &&
    model_order_node_type_equals(n2.get_type(), NodeType::LongEdge) {
    let n1_dummy_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n1,
    )
    let n1_dummy_target_port = model_order_node_get_first_outgoing_target_port_of_node(
      n1,
    )
    let n1_dummy_source_node = model_order_node_port_node(n1_dummy_source_port)
    let n1_dummy_target_node = model_order_node_port_node(n1_dummy_target_port)
    if n1_dummy_source_node is None || n1_dummy_target_node is None {
      return 0
    }
    let n1_dummy_source_node = match n1_dummy_source_node {
      Some(value) => value
      None => return 0
    }
    let n1_dummy_target_node = match n1_dummy_target_node {
      Some(value) => value
      None => return 0
    }
    let n1_layer_id = model_order_node_layer_id(n1)
    let mut n1_source_feedback_node = false
    let mut n1_target_feedback_node = false

    let n2_dummy_source_port = model_order_node_get_first_incoming_source_port_of_node(
      n2,
    )
    let n2_dummy_target_port = model_order_node_get_first_outgoing_target_port_of_node(
      n2,
    )
    let n2_dummy_source_node = model_order_node_port_node(n2_dummy_source_port)
    let n2_dummy_target_node = model_order_node_port_node(n2_dummy_target_port)
    if n2_dummy_source_node is None || n2_dummy_target_node is None {
      return 0
    }
    let n2_dummy_source_node = match n2_dummy_source_node {
      Some(value) => value
      None => return 0
    }
    let n2_dummy_target_node = match n2_dummy_target_node {
      Some(value) => value
      None => return 0
    }
    let n2_layer_id = model_order_node_layer_id(n2)
    let mut n2_source_feedback_node = false
    let mut n2_target_feedback_node = false

    let mut n1_reference_node = n1
    let mut n2_reference_node = n2

    if model_order_node_layer_id(n1_dummy_source_node) == n1_layer_id {
      n1_source_feedback_node = true
      n1_reference_node = n1_dummy_source_node
    } else if model_order_node_layer_id(n1_dummy_target_node) == n1_layer_id {
      n1_target_feedback_node = true
      n1_reference_node = n1_dummy_target_node
    }

    if model_order_node_layer_id(n2_dummy_source_node) == n2_layer_id {
      n2_source_feedback_node = true
      n2_reference_node = n2_dummy_source_node
    } else if model_order_node_layer_id(n2_dummy_target_node) == n2_layer_id {
      n2_target_feedback_node = true
      n2_reference_node = n2_dummy_target_node
    }

    if lnode_internal_handle(n1_reference_node) ==
      lnode_internal_handle(n2_reference_node) {
      if self.before_ports {
        if n1_source_feedback_node && n2_source_feedback_node {
          let n1_dummy_source_port = match n1_dummy_source_port {
            Some(value) => value
            None => return 0
          }
          let n2_dummy_source_port = match n2_dummy_source_port {
            Some(value) => value
            None => return 0
          }
          let return_value = new_model_order_port_comparator_without_target_node_model_order(
            self.graph,
            self.previous_layer,
            self.ordering_strategy,
            n2_target_feedback_node,
          ).compare(n1_dummy_source_port, n2_dummy_source_port)
          if return_value > 0 {
            self.update_bigger_and_smaller_associations(n2, n1)
            return 1
          } else {
            self.update_bigger_and_smaller_associations(n1, n2)
            return -1
          }
        } else if n1_source_feedback_node && n2_target_feedback_node {
          self.update_bigger_and_smaller_associations(n2, n1)
          return 1
        } else if n1_target_feedback_node && n2_source_feedback_node {
          self.update_bigger_and_smaller_associations(n1, n2)
          return -1
        } else if n1_target_feedback_node && n2_target_feedback_node {
          return 0
        }
      } else {
        let n1_dummy_source_port = match n1_dummy_source_port {
          Some(value) => value
          None => return 0
        }
        let n2_dummy_source_port = match n2_dummy_source_port {
          Some(value) => value
          None => return 0
        }
        for port in n1_reference_node.get_ports() {
          if lport_internal_handle(n1_dummy_source_port) ==
            lport_internal_handle(port) {
            self.update_bigger_and_smaller_associations(n2, n1)
            return -1
          } else if lport_internal_handle(n2_dummy_source_port) ==
            lport_internal_handle(port) {
            self.update_bigger_and_smaller_associations(n1, n2)
            return 1
          }
        }
      }
    }

    return self.compare(n1_reference_node, n2_reference_node)
  } else {
    0
  }
}

///|
pub fn ModelOrderNodeComparator::compare(
  self : ModelOrderNodeComparator,
  n1 : LNode,
  n2 : LNode,
) -> Int {
  let n1_handle = lnode_internal_handle(n1)
  let n2_handle = lnode_internal_handle(n2)

  if self.bigger_than.get(n1_handle) is None {
    self.bigger_than[n1_handle] = []
  } else {
    let n1_bigger = model_order_node_associations_get(
      self.bigger_than,
      n1_handle,
    )
    if model_order_node_contains(n1_bigger, n2_handle) {
      return 1
    }
  }
  if self.bigger_than.get(n2_handle) is None {
    self.bigger_than[n2_handle] = []
  } else {
    let n2_bigger = model_order_node_associations_get(
      self.bigger_than,
      n2_handle,
    )
    if model_order_node_contains(n2_bigger, n1_handle) {
      return -1
    }
  }
  if self.smaller_than.get(n1_handle) is None {
    self.smaller_than[n1_handle] = []
  } else {
    let n1_smaller = model_order_node_associations_get(
      self.smaller_than,
      n1_handle,
    )
    if model_order_node_contains(n1_smaller, n2_handle) {
      return -1
    }
  }
  if self.smaller_than.get(n2_handle) is None {
    self.smaller_than[n2_handle] = []
  } else {
    let n2_bigger = model_order_node_associations_get(
      self.bigger_than,
      n2_handle,
    )
    if model_order_node_contains(n2_bigger, n1_handle) {
      return 1
    }
  }

  if model_order_node_strategy_is_prefer_edges(self.ordering_strategy) ||
    !n1.has_property_int(internal_properties_model_order) ||
    !n2.has_property_int(internal_properties_model_order) {
    let p1_source_port = model_order_node_first_source_port_connected_to_previous_layer(
      n1,
    )
    let p2_source_port = model_order_node_first_source_port_connected_to_previous_layer(
      n2,
    )

    match (p1_source_port, p2_source_port) {
      (Some(source1), Some(source2)) => {
        let p1_node = model_order_node_port_node(Some(source1))
        let p2_node = model_order_node_port_node(Some(source2))
        if p1_node is None || p2_node is None {
          let n1_edge_order = self.get_model_order_from_connected_edges(n1)
          let n2_edge_order = self.get_model_order_from_connected_edges(n2)
          if n1_edge_order > n2_edge_order {
            self.update_bigger_and_smaller_associations(n1, n2)
            return 1
          } else {
            self.update_bigger_and_smaller_associations(n2, n1)
            return -1
          }
        }
        let p1_node = match p1_node {
          Some(value) => value
          None => return -1
        }
        let p2_node = match p2_node {
          Some(value) => value
          None => return -1
        }

        if lnode_internal_handle(p1_node) == lnode_internal_handle(p2_node) {
          for port in p1_node.get_ports() {
            if lport_internal_handle(port) == lport_internal_handle(source1) {
              self.update_bigger_and_smaller_associations(n2, n1)
              return -1
            } else if lport_internal_handle(port) ==
              lport_internal_handle(source2) {
              self.update_bigger_and_smaller_associations(n1, n2)
              return 1
            }
          }

          let n1_edge_order = self.get_model_order_from_connected_edges(n1)
          let n2_edge_order = self.get_model_order_from_connected_edges(n2)
          if n1_edge_order > n2_edge_order {
            self.update_bigger_and_smaller_associations(n1, n2)
            return 1
          } else {
            self.update_bigger_and_smaller_associations(n2, n1)
            return -1
          }
        }

        for previous_node in self.previous_layer {
          if lnode_internal_handle(previous_node) ==
            lnode_internal_handle(p1_node) {
            self.update_bigger_and_smaller_associations(n2, n1)
            return -1
          } else if lnode_internal_handle(previous_node) ==
            lnode_internal_handle(p2_node) {
            self.update_bigger_and_smaller_associations(n1, n2)
            return 1
          }
        }
      }
      _ => ()
    }

    if (p1_source_port is Some(_) && p2_source_port is None) ||
      (p1_source_port is None && p2_source_port is Some(_)) {
      let compared_with_long_edge_feedback = self.handle_helper_dummy_nodes(
        n1, n2,
      )
      if compared_with_long_edge_feedback != 0 {
        if compared_with_long_edge_feedback > 0 {
          self.update_bigger_and_smaller_associations(n1, n2)
        } else {
          self.update_bigger_and_smaller_associations(n2, n1)
        }
        return compared_with_long_edge_feedback
      }

      if !n1.has_property_int(internal_properties_model_order) ||
        !n2.has_property_int(internal_properties_model_order) {
        let n1_model_order = self.get_model_order_from_connected_edges(n1)
        let n2_model_order = self.get_model_order_from_connected_edges(n2)
        if n1_model_order > n2_model_order {
          self.update_bigger_and_smaller_associations(n1, n2)
          return 1
        } else {
          self.update_bigger_and_smaller_associations(n2, n1)
          return -1
        }
      }
    }

    if p1_source_port is None && p2_source_port is None {
      let compared_with_long_edge_feedback = self.handle_helper_dummy_nodes(
        n1, n2,
      )
      if compared_with_long_edge_feedback != 0 {
        if compared_with_long_edge_feedback > 0 {
          self.update_bigger_and_smaller_associations(n1, n2)
        } else {
          self.update_bigger_and_smaller_associations(n2, n1)
        }
        return compared_with_long_edge_feedback
      }
    }
  }

  if n1.has_property_int(internal_properties_model_order) &&
    n2.has_property_int(internal_properties_model_order) {
    let n1_model_order = cm_group_model_order_calculate_model_order_or_group_model_order(
      n1,
      n2,
      self.graph,
      model_order_node_require_max_model_order_nodes(self.graph),
    )
    let n2_model_order = cm_group_model_order_calculate_model_order_or_group_model_order(
      n2,
      n1,
      self.graph,
      model_order_node_require_max_model_order_nodes(self.graph),
    )
    if n1_model_order > n2_model_order {
      self.update_bigger_and_smaller_associations(n1, n2)
      1
    } else {
      self.update_bigger_and_smaller_associations(n2, n1)
      -1
    }
  } else {
    self.update_bigger_and_smaller_associations(n2, n1)
    -1
  }
}

///|
pub fn ModelOrderNodeComparator::clear_transitive_ordering(
  self : ModelOrderNodeComparator,
) -> Unit {
  self.bigger_than = {}
  self.smaller_than = {}
}
