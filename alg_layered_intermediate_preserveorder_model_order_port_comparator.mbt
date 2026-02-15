///|
fn model_order_port_side_equals(left : PortSide, right : PortSide) -> Bool {
  match (left, right) {
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    (SideUndefined, SideUndefined) => true
    _ => false
  }
}

///|
fn model_order_port_side_ordinal(side : PortSide) -> Int {
  match side {
    North => 0
    East => 1
    South => 2
    West => 3
    SideUndefined => 4
  }
}

///|
fn model_order_port_node_type_equals(left : NodeType, right : NodeType) -> Bool {
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
fn model_order_port_strategy_is_prefer_nodes(
  strategy : OrderingStrategy,
) -> Bool {
  match strategy {
    OrderingStrategy::PreferNodes => true
    _ => false
  }
}

///|
fn model_order_port_compare_int(left : Int, right : Int) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn model_order_port_node_handle(node : LNode) -> Int {
  lnode_internal_handle(node)
}

///|
fn model_order_port_contains(values : Array[Int], value : Int) -> Bool {
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}

///|
fn model_order_port_add_unique(values : Array[Int], value : Int) -> Unit {
  if model_order_port_contains(values, value) {
    return
  }
  values.push(value)
}

///|
fn model_order_port_add_all_unique(
  target : Array[Int],
  source : Array[Int],
) -> Unit {
  for value in source {
    model_order_port_add_unique(target, value)
  }
}

///|
fn model_order_port_associations_for(
  associations : Map[Int, Array[Int]],
  port_handle : Int,
) -> Array[Int] {
  match associations.get(port_handle) {
    Some(values) => values
    None => {
      associations[port_handle] = []
      match associations.get(port_handle) {
        Some(values) => values
        None => abort("association map entry initialization failed")
      }
    }
  }
}

///|
fn model_order_port_require_node(port : LPort?) -> LNode {
  match port {
    Some(value) =>
      match value.get_node() {
        Some(node) => node
        None => abort("port has no owner node")
      }
    None => abort("missing port")
  }
}

///|
fn model_order_port_require_source(edge : LEdge?) -> LPort {
  match edge {
    Some(value) =>
      match value.get_source() {
        Some(port) => port
        None => abort("edge has no source")
      }
    None => abort("missing edge")
  }
}

///|
fn model_order_port_require_target(edge : LEdge?) -> LPort {
  match edge {
    Some(value) =>
      match value.get_target() {
        Some(port) => port
        None => abort("edge has no target")
      }
    None => abort("missing edge")
  }
}

///|
fn model_order_port_edges_connected(port : LPort) -> Bool {
  !port.get_incoming_edges().is_empty() || !port.get_outgoing_edges().is_empty()
}

///|
pub struct ModelOrderPortComparator {
  target_node_model_order : Map[Int, Int]
  has_target_node_model_order : Bool
  port_model_order : Bool
  previous_layer : Array[LNode]
  graph : LGraph
  strategy : OrderingStrategy
  mut bigger_than : Map[Int, Array[Int]]
  mut smaller_than : Map[Int, Array[Int]]
}

///|
pub fn new_model_order_port_comparator_from_layer(
  graph : LGraph,
  previous_layer : Layer,
  strategy : OrderingStrategy,
  target_node_model_order : Map[Int, Int],
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order,
    has_target_node_model_order: true,
    port_model_order,
    previous_layer: previous_layer.get_nodes().copy(),
    graph,
    strategy,
    bigger_than: {},
    smaller_than: {},
  }
}

///|
pub fn new_model_order_port_comparator(
  graph : LGraph,
  previous_layer : Array[LNode],
  strategy : OrderingStrategy,
  target_node_model_order : Map[Int, Int],
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order,
    has_target_node_model_order: true,
    port_model_order,
    previous_layer,
    graph,
    strategy,
    bigger_than: {},
    smaller_than: {},
  }
}

///|
pub fn new_model_order_port_comparator_without_target_node_model_order(
  graph : LGraph,
  previous_layer : Array[LNode],
  strategy : OrderingStrategy,
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order: {},
    has_target_node_model_order: false,
    port_model_order,
    previous_layer,
    graph,
    strategy,
    bigger_than: {},
    smaller_than: {},
  }
}

///|
fn ModelOrderPortComparator::update_bigger_and_smaller_associations(
  self : ModelOrderPortComparator,
  bigger_original : LPort,
  smaller_original : LPort,
  reverse_order : Int,
) -> Unit {
  let bigger = if reverse_order < 0 {
    smaller_original
  } else {
    bigger_original
  }
  let smaller = if reverse_order < 0 {
    bigger_original
  } else {
    smaller_original
  }

  let bigger_handle = lport_internal_handle(bigger)
  let smaller_handle = lport_internal_handle(smaller)

  let bigger_port_bigger_than = model_order_port_associations_for(
    self.bigger_than,
    bigger_handle,
  )
  let smaller_port_bigger_than = model_order_port_associations_for(
    self.bigger_than,
    smaller_handle,
  )
  let bigger_port_smaller_than = model_order_port_associations_for(
    self.smaller_than,
    bigger_handle,
  )
  let smaller_port_smaller_than = model_order_port_associations_for(
    self.smaller_than,
    smaller_handle,
  )

  model_order_port_add_unique(smaller_port_smaller_than, bigger_handle)
  model_order_port_add_unique(bigger_port_bigger_than, smaller_handle)

  for very_small in smaller_port_bigger_than {
    model_order_port_add_unique(bigger_port_bigger_than, very_small)
    let very_small_smaller_than = model_order_port_associations_for(
      self.smaller_than,
      very_small,
    )
    model_order_port_add_unique(very_small_smaller_than, bigger_handle)
    model_order_port_add_all_unique(
      very_small_smaller_than, bigger_port_smaller_than,
    )
  }

  for very_big in bigger_port_smaller_than {
    model_order_port_add_unique(smaller_port_smaller_than, very_big)
    let very_big_bigger_than = model_order_port_associations_for(
      self.bigger_than,
      very_big,
    )
    model_order_port_add_unique(very_big_bigger_than, smaller_handle)
    model_order_port_add_all_unique(
      very_big_bigger_than, smaller_port_bigger_than,
    )
  }
}

///|
fn ModelOrderPortComparator::check_reference_layer(
  self : ModelOrderPortComparator,
  layer : Array[LNode],
  p1_node : LNode,
  p2_node : LNode,
) -> Int {
  for node in layer {
    if lnode_internal_handle(node) == lnode_internal_handle(p1_node) {
      return -1
    } else if lnode_internal_handle(node) == lnode_internal_handle(p2_node) {
      return 1
    }
  }
  0
}

///|
pub fn ModelOrderPortComparator::check_port_model_order(
  self : ModelOrderPortComparator,
  p1 : LPort,
  p2 : LPort,
) -> Int {
  let number_of_ports = match p1.get_node() {
    Some(owner) => owner.get_ports().length()
    None => 0
  }
  if p1.has_property_int(internal_properties_model_order) &&
    p2.has_property_int(internal_properties_model_order) {
    let p1_order = cm_group_model_order_calculate_model_order_or_group_model_order_port(
      p1,
      p2,
      self.graph,
      number_of_ports,
    )
    let p2_order = cm_group_model_order_calculate_model_order_or_group_model_order_port(
      p2,
      p1,
      self.graph,
      number_of_ports,
    )
    return model_order_port_compare_int(p1_order, p2_order)
  }
  0
}

///|
pub fn ModelOrderPortComparator::compare(
  self : ModelOrderPortComparator,
  original_p1 : LPort,
  original_p2 : LPort,
) -> Int {
  let p1 = original_p1
  let p2 = original_p2

  let p1_handle = lport_internal_handle(p1)
  let p2_handle = lport_internal_handle(p2)

  let p1_bigger = model_order_port_associations_for(self.bigger_than, p1_handle)
  if model_order_port_contains(p1_bigger, p2_handle) {
    return 1
  }
  let p2_bigger = model_order_port_associations_for(self.bigger_than, p2_handle)
  if model_order_port_contains(p2_bigger, p1_handle) {
    return -1
  }
  let p1_smaller = model_order_port_associations_for(
    self.smaller_than,
    p1_handle,
  )
  if model_order_port_contains(p1_smaller, p2_handle) {
    return -1
  }
  let p2_smaller = model_order_port_associations_for(
    self.smaller_than,
    p2_handle,
  )
  if model_order_port_contains(p2_bigger, p1_handle) {
    return 1
  }

  if !model_order_port_side_equals(p1.get_side(), p2.get_side()) {
    let result = model_order_port_compare_int(
      model_order_port_side_ordinal(p1.get_side()),
      model_order_port_side_ordinal(p2.get_side()),
    )
    if result > 0 {
      self.update_bigger_and_smaller_associations(p1, p2, 1)
    } else {
      self.update_bigger_and_smaller_associations(p2, p1, 1)
    }
    return result
  }

  let mut reverse_order = 1

  if !p1.get_incoming_edges().is_empty() && !p2.get_incoming_edges().is_empty() {
    if (
        model_order_port_side_equals(p1.get_side(), West) &&
        model_order_port_side_equals(p2.get_side(), West)
      ) ||
      (
        model_order_port_side_equals(p1.get_side(), North) &&
        model_order_port_side_equals(p2.get_side(), North)
      ) ||
      (
        model_order_port_side_equals(p1.get_side(), South) &&
        model_order_port_side_equals(p2.get_side(), South)
      ) {
      reverse_order = -reverse_order
    }

    let p1_source_port = model_order_port_require_source(
      Some(p1.get_incoming_edges()[0]),
    )
    let p2_source_port = model_order_port_require_source(
      Some(p2.get_incoming_edges()[0]),
    )
    let p1_node = model_order_port_require_node(Some(p1_source_port))
    let p2_node = model_order_port_require_node(Some(p2_source_port))

    if lnode_internal_handle(p1_node) == lnode_internal_handle(p2_node) {
      for port in p1_node.get_ports() {
        if lport_internal_handle(p1_source_port) == lport_internal_handle(port) {
          self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
          return -reverse_order
        } else if lport_internal_handle(p2_source_port) ==
          lport_internal_handle(port) {
          self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
          return reverse_order
        }
      }
    }

    if (match p1_source_port.get_node() {
        Some(node) =>
          model_order_port_node_type_equals(node.get_type(), NodeType::LongEdge)
        None => false
      }) &&
      (match p2_source_port.get_node() {
        Some(node) =>
          model_order_port_node_type_equals(node.get_type(), NodeType::LongEdge)
        None => false
      }) {
      let p1_source_node = model_order_port_require_node(Some(p1_source_port))
      let p2_source_node = model_order_port_require_node(Some(p2_source_port))
      let p1_source_layer = match p1_source_node.get_layer() {
        Some(layer) => layer
        None => abort("source node missing layer")
      }
      let p2_source_layer = match p2_source_node.get_layer() {
        Some(layer) => layer
        None => abort("source node missing layer")
      }
      let p1_owner = model_order_port_require_node(Some(p1))
      let p1_owner_layer = match p1_owner.get_layer() {
        Some(layer) => layer
        None => abort("port owner missing layer")
      }

      if layer_internal_handle(p1_source_layer) ==
        layer_internal_handle(p2_source_layer) &&
        layer_internal_handle(p1_source_layer) ==
        layer_internal_handle(p1_owner_layer) {
        let in_previous_layer = self.check_reference_layer(
          p1_source_layer.get_nodes().copy(),
          p1_source_node,
          p2_source_node,
        )
        if in_previous_layer != 0 {
          if model_order_port_side_equals(p1.get_side(), East) &&
            model_order_port_side_equals(p2.get_side(), East) {
            reverse_order = -reverse_order
          }
          if in_previous_layer > 0 {
            self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
            return reverse_order
          } else {
            self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
            return -reverse_order
          }
        }
      }
    }

    let in_previous_layer = self.check_reference_layer(
      self.previous_layer,
      p1_node,
      p2_node,
    )
    if in_previous_layer != 0 {
      if in_previous_layer > 0 {
        self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
        return reverse_order
      } else {
        self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
        return -reverse_order
      }
    }

    if self.port_model_order {
      let result = self.check_port_model_order(p1, p2)
      if result != 0 {
        if result > 0 {
          self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
          return reverse_order
        } else {
          self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
          return -reverse_order
        }
      }
    }
  }

  if !p1.get_outgoing_edges().is_empty() && !p2.get_outgoing_edges().is_empty() {
    if (
        model_order_port_side_equals(p1.get_side(), West) &&
        model_order_port_side_equals(p2.get_side(), West)
      ) ||
      (
        model_order_port_side_equals(p1.get_side(), South) &&
        model_order_port_side_equals(p2.get_side(), South)
      ) {
      reverse_order = -reverse_order
    }

    let p1_target_node = p1.get_property_l_node(
      internal_properties_long_edge_target_node,
    )
    let p2_target_node = p2.get_property_l_node(
      internal_properties_long_edge_target_node,
    )

    match (p1_target_node, p2_target_node) {
      (Some(target1), Some(target2)) =>
        if model_order_port_strategy_is_prefer_nodes(self.strategy) &&
          target1.has_property_int(internal_properties_model_order) &&
          target2.has_property_int(internal_properties_model_order) {
          let p1_mo = cm_group_model_order_calculate_model_order_or_group_model_order(
            target1,
            target2,
            self.graph,
            self.graph.get_property_int(
              internal_properties_max_model_order_nodes,
            ),
          )
          let p2_mo = cm_group_model_order_calculate_model_order_or_group_model_order(
            target2,
            target1,
            self.graph,
            self.graph.get_property_int(
              internal_properties_max_model_order_nodes,
            ),
          )
          if p1_mo > p2_mo {
            self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
            return reverse_order
          } else {
            self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
            return -reverse_order
          }
        }
      _ => ()
    }

    if self.port_model_order {
      let result = self.check_port_model_order(p1, p2)
      if result != 0 {
        if result > 0 {
          self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
          return reverse_order
        } else {
          self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
          return -reverse_order
        }
      }
    }

    let mut p1_order = 0
    let mut p2_order = 0

    let p1_first_outgoing = p1.get_outgoing_edges()[0]
    let p2_first_outgoing = p2.get_outgoing_edges()[0]
    if p1_first_outgoing.has_property_int(internal_properties_model_order) {
      p1_order = cm_group_model_order_calculate_model_order_or_group_model_order_edge(
        p1_first_outgoing,
        p2_first_outgoing,
        self.graph,
        p1.get_outgoing_edges().length() + p1.get_incoming_edges().length(),
      )
    }
    if p2_first_outgoing.has_property_int(internal_properties_model_order) {
      p2_order = cm_group_model_order_calculate_model_order_or_group_model_order_edge(
        p2_first_outgoing,
        p1_first_outgoing,
        self.graph,
        p2.get_outgoing_edges().length() + p2.get_incoming_edges().length(),
      )
    }

    match (p1_target_node, p2_target_node) {
      (Some(target1), Some(target2)) =>
        if lnode_internal_handle(target1) == lnode_internal_handle(target2) {
          if p1_order > p2_order {
            self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
            return reverse_order
          } else {
            self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
            return -reverse_order
          }
        }
      _ => ()
    }

    if self.has_target_node_model_order {
      match p1_target_node {
        Some(target) => {
          let target_handle = model_order_port_node_handle(target)
          match self.target_node_model_order.get(target_handle) {
            Some(value) => p1_order = value
            None => ()
          }
        }
        None => ()
      }
      match p2_target_node {
        Some(target) => {
          let target_handle = model_order_port_node_handle(target)
          match self.target_node_model_order.get(target_handle) {
            Some(value) => p2_order = value
            None => ()
          }
        }
        None => ()
      }
    }

    if p1_order > p2_order {
      self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
      return reverse_order
    } else {
      self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
      return -reverse_order
    }
  }

  if !p1.get_incoming_edges().is_empty() && !p2.get_outgoing_edges().is_empty() {
    self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
    return 1
  } else if !p1.get_outgoing_edges().is_empty() &&
    !p2.get_incoming_edges().is_empty() {
    self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
    return -1
  } else if p1.has_property_int(internal_properties_model_order) &&
    p2.has_property_int(internal_properties_model_order) &&
    !model_order_port_edges_connected(p1) &&
    !model_order_port_edges_connected(p2) {
    let number_of_ports = match p1.get_node() {
      Some(node) => node.get_ports().length()
      None => 0
    }
    let p1_mo = cm_group_model_order_calculate_model_order_or_group_model_order_port(
      p1,
      p2,
      self.graph,
      number_of_ports,
    )
    let p2_mo = cm_group_model_order_calculate_model_order_or_group_model_order_port(
      p2,
      p1,
      self.graph,
      number_of_ports,
    )

    if (
        model_order_port_side_equals(p1.get_side(), West) &&
        model_order_port_side_equals(p2.get_side(), West)
      ) ||
      (
        model_order_port_side_equals(p1.get_side(), South) &&
        model_order_port_side_equals(p2.get_side(), South)
      ) {
      reverse_order = -reverse_order
    }

    if p1_mo > p2_mo {
      self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
      return reverse_order
    } else {
      self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
      return -reverse_order
    }
  } else {
    self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
    return -reverse_order
  }
}

///|
pub fn ModelOrderPortComparator::clear_transitive_ordering(
  self : ModelOrderPortComparator,
) -> Unit {
  self.bigger_than = {}
  self.smaller_than = {}
}
