///|
#derive(Debug, ToJson)
priv suberror ModelOrderPortComparatorException {
  ModelOrderPortComparatorException(String)
}

///|
fn[T] model_order_port_raise(
  message : String,
) -> T raise ModelOrderPortComparatorException {
  raise ModelOrderPortComparatorException(message)
}

///|
fn model_order_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
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
fn model_order_port_side_ordinal(side : @core.PortSide) -> Int32 {
  match side {
    North => 0
    East => 1
    South => 2
    West => 3
    SideUndefined => 4
  }
}

///|
fn model_order_port_node_type_equals(
  left : @runtime.NodeType,
  right : @runtime.NodeType,
) -> Bool {
  match (left, right) {
    (Normal, Normal) => true
    (LongEdge, LongEdge) => true
    (ExternalPort, ExternalPort) => true
    (NorthSouthPort, NorthSouthPort) => true
    (LabelNode, LabelNode) => true
    (BreakingPoint, BreakingPoint) => true
    (Placeholder, Placeholder) => true
    (NonshiftingPlaceholder, NonshiftingPlaceholder) => true
    _ => false
  }
}

///|
fn model_order_port_strategy_is_prefer_nodes(
  strategy : @options.OrderingStrategy,
) -> Bool {
  match strategy {
    PreferNodes => true
    _ => false
  }
}

///|
fn model_order_port_compare_int(left : Int32, right : Int32) -> Int32 {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn model_order_port_node_handle(node : @runtime.LNode) -> Int32 {
  @runtime.lnode_internal_handle(node)
}

///|
fn model_order_port_contains(values : Array[Int32], value : Int32) -> Bool {
  for candidate in values {
    if candidate == value {
      return true
    }
  }
  false
}

///|
fn model_order_port_add_unique(values : Array[Int32], value : Int32) -> Unit {
  if model_order_port_contains(values, value) {
    return
  }
  values.push(value)
}

///|
fn model_order_port_add_all_unique(
  target : Array[Int32],
  source : Array[Int32],
) -> Unit {
  for value in source {
    model_order_port_add_unique(target, value)
  }
}

///|
fn model_order_port_associations_for(
  associations : Map[Int32, Array[Int32]],
  port_handle : Int32,
) -> Array[Int32] {
  match associations.get(port_handle) {
    Some(values) => values
    None => {
      let values = []
      associations[port_handle] = values
      values
    }
  }
}

///|
fn model_order_port_require_node(
  port : @runtime.LPort?,
) -> @runtime.LNode raise ModelOrderPortComparatorException {
  match port {
    Some(value) =>
      match value.get_node() {
        Some(node) => node
        None => model_order_port_raise("port has no owner node")
      }
    None => model_order_port_raise("missing port")
  }
}

///|
fn model_order_port_require_source(
  edge : @runtime.LEdge?,
) -> @runtime.LPort raise ModelOrderPortComparatorException {
  match edge {
    Some(value) =>
      match value.get_source() {
        Some(port) => port
        None => model_order_port_raise("edge has no source")
      }
    None => model_order_port_raise("missing edge")
  }
}

///|
fn _model_order_port_require_target(
  edge : @runtime.LEdge?,
) -> @runtime.LPort raise ModelOrderPortComparatorException {
  match edge {
    Some(value) =>
      match value.get_target() {
        Some(port) => port
        None => model_order_port_raise("edge has no target")
      }
    None => model_order_port_raise("missing edge")
  }
}

///|
fn model_order_port_edges_connected(port : @runtime.LPort) -> Bool {
  !port.get_incoming_edges().is_empty() || !port.get_outgoing_edges().is_empty()
}

///|
fn model_order_port_require_max_model_order_nodes(
  graph : @runtime.LGraph,
) -> Int32 {
  graph.get_property_int(@runtime.internal_properties_max_model_order_nodes)
}

///|
pub struct ModelOrderPortComparator {
  target_node_model_order : Map[Int32, Int32]
  has_target_node_model_order : Bool
  port_model_order : Bool
  previous_layer : Array[@runtime.LNode]
  graph : @runtime.LGraph
  strategy : @options.OrderingStrategy
  mut bigger_than : Map[Int32, Array[Int32]]
  mut smaller_than : Map[Int32, Array[Int32]]
}

///|
pub fn new_model_order_port_comparator_from_layer(
  graph : @runtime.LGraph,
  previous_layer : @runtime.Layer,
  strategy : @options.OrderingStrategy,
  target_node_model_order : Map[Int32, Int32],
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order,
    has_target_node_model_order: true,
    port_model_order,
    previous_layer: previous_layer.get_nodes().copy(),
    graph,
    strategy,
    bigger_than: Map([]),
    smaller_than: Map([]),
  }
}

///|
pub fn new_model_order_port_comparator(
  graph : @runtime.LGraph,
  previous_layer : Array[@runtime.LNode],
  strategy : @options.OrderingStrategy,
  target_node_model_order : Map[Int32, Int32],
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order,
    has_target_node_model_order: true,
    port_model_order,
    previous_layer,
    graph,
    strategy,
    bigger_than: Map([]),
    smaller_than: Map([]),
  }
}

///|
pub fn new_model_order_port_comparator_without_target_node_model_order(
  graph : @runtime.LGraph,
  previous_layer : Array[@runtime.LNode],
  strategy : @options.OrderingStrategy,
  port_model_order : Bool,
) -> ModelOrderPortComparator {
  {
    target_node_model_order: Map([]),
    has_target_node_model_order: false,
    port_model_order,
    previous_layer,
    graph,
    strategy,
    bigger_than: Map([]),
    smaller_than: Map([]),
  }
}

///|
fn ModelOrderPortComparator::update_bigger_and_smaller_associations(
  self : ModelOrderPortComparator,
  bigger_original : @runtime.LPort,
  smaller_original : @runtime.LPort,
  reverse_order : Int32,
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

  let bigger_handle = @runtime.lport_internal_handle(bigger)
  let smaller_handle = @runtime.lport_internal_handle(smaller)

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
  _self : ModelOrderPortComparator,
  layer : Array[@runtime.LNode],
  p1_node : @runtime.LNode,
  p2_node : @runtime.LNode,
) -> Int32 {
  for node in layer {
    if @runtime.lnode_internal_handle(node) ==
      @runtime.lnode_internal_handle(p1_node) {
      return -1
    } else if @runtime.lnode_internal_handle(node) ==
      @runtime.lnode_internal_handle(p2_node) {
      return 1
    }
  }
  0
}

///|
pub fn ModelOrderPortComparator::check_port_model_order(
  self : ModelOrderPortComparator,
  p1 : @runtime.LPort,
  p2 : @runtime.LPort,
) -> Int32 {
  let number_of_ports = match p1.get_node() {
    Some(owner) => owner.get_ports().length()
    None => 0
  }
  if p1.has_property_int(@runtime.internal_properties_model_order) &&
    p2.has_property_int(@runtime.internal_properties_model_order) {
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
fn ModelOrderPortComparator::update_elk_0_9_1_compare_result(
  self : ModelOrderPortComparator,
  p1 : @runtime.LPort,
  p2 : @runtime.LPort,
  p1_order : Int32,
  p2_order : Int32,
) -> Int32 {
  if p1_order > p2_order {
    self.update_bigger_and_smaller_associations(p1, p2, 1)
  } else {
    self.update_bigger_and_smaller_associations(p2, p1, 1)
  }
  model_order_port_compare_int(p1_order, p2_order)
}

///|
/// `ModelOrderPortComparator.compare` of ELK 0.9.1.
fn ModelOrderPortComparator::compare_elk_0_9_1(
  self : ModelOrderPortComparator,
  original_p1 : @runtime.LPort,
  original_p2 : @runtime.LPort,
) -> Int32 raise ModelOrderPortComparatorException {
  let mut p1 = original_p1
  let mut p2 = original_p2

  if self.port_model_order &&
    model_order_port_side_equals(p1.get_side(), West) &&
    model_order_port_side_equals(p2.get_side(), West) {
    // WEST ports sort descending, all other sides ascending.
    p1 = original_p2
    p2 = original_p1
  }

  let p1_handle = @runtime.lport_internal_handle(p1)
  let p2_handle = @runtime.lport_internal_handle(p2)
  if model_order_port_contains(
      model_order_port_associations_for(self.bigger_than, p1_handle),
      p2_handle,
    ) {
    return 1
  }
  if model_order_port_contains(
      model_order_port_associations_for(self.bigger_than, p2_handle),
      p1_handle,
    ) {
    return -1
  }
  if model_order_port_contains(
      model_order_port_associations_for(self.smaller_than, p1_handle),
      p2_handle,
    ) {
    return -1
  }
  // ELK looks p1 up in `biggerThan.get(p2)` a second time here, which cannot
  // hold any more; only the entry for p2 is created.
  ignore(model_order_port_associations_for(self.smaller_than, p2_handle))

  // Sort ports by their sides: NORTH < EAST < SOUTH < WEST.
  if !model_order_port_side_equals(p1.get_side(), p2.get_side()) {
    let result = model_order_port_compare_int(
      model_order_port_side_ordinal(p1.get_side()),
      model_order_port_side_ordinal(p2.get_side()),
    )
    if result == -1 {
      self.update_bigger_and_smaller_associations(p2, p1, 1)
    } else {
      self.update_bigger_and_smaller_associations(p1, p2, 1)
    }
    return result
  }

  // Sort incoming edges by the order of the nodes they come from.
  if !p1.get_incoming_edges().is_empty() && !p2.get_incoming_edges().is_empty() {
    if self.port_model_order {
      let result = model_order_port_check_port_model_order_elk_0_9_1(p1, p2)
      if result != 0 {
        if result == -1 {
          self.update_bigger_and_smaller_associations(p2, p1, 1)
        } else {
          self.update_bigger_and_smaller_associations(p1, p2, 1)
        }
        return result
      }
    }
    let p1_edge = p1.get_incoming_edges()[0]
    let p2_edge = p2.get_incoming_edges()[0]
    let p1_node = model_order_port_require_node(
      Some(model_order_port_require_source(Some(p1_edge))),
    )
    let p2_node = model_order_port_require_node(
      Some(model_order_port_require_source(Some(p2_edge))),
    )
    let p1_node_handle = model_order_port_node_handle(p1_node)
    let p2_node_handle = model_order_port_node_handle(p2_node)
    if p1_node_handle == p2_node_handle {
      return self.update_elk_0_9_1_compare_result(
        p1,
        p2,
        p1_edge.get_property_int(@runtime.internal_properties_model_order),
        p2_edge.get_property_int(@runtime.internal_properties_model_order),
      )
    }
    for previous_node in self.previous_layer {
      let previous_handle = model_order_port_node_handle(previous_node)
      if previous_handle == p1_node_handle {
        self.update_bigger_and_smaller_associations(p1, p2, 1)
        return 1
      } else if previous_handle == p2_node_handle {
        self.update_bigger_and_smaller_associations(p2, p1, 1)
        return -1
      }
    }
  }

  // Sort outgoing edges by the model order of their edges.
  if !p1.get_outgoing_edges().is_empty() && !p2.get_outgoing_edges().is_empty() {
    let p1_target_node = p1.get_property_l_node(
      @runtime.internal_properties_long_edge_target_node,
    )
    let p2_target_node = p2.get_property_l_node(
      @runtime.internal_properties_long_edge_target_node,
    )

    if model_order_port_strategy_is_prefer_nodes(self.strategy) &&
      p1_target_node is Some(target1) &&
      p2_target_node is Some(target2) &&
      target1.has_property_int(@runtime.internal_properties_model_order) &&
      target2.has_property_int(@runtime.internal_properties_model_order) {
      return self.update_elk_0_9_1_compare_result(
        p1,
        p2,
        target1.get_property_int(@runtime.internal_properties_model_order),
        target2.get_property_int(@runtime.internal_properties_model_order),
      )
    }

    if self.port_model_order {
      let result = model_order_port_check_port_model_order_elk_0_9_1(p1, p2)
      if result != 0 {
        if result == -1 {
          self.update_bigger_and_smaller_associations(p2, p1, 1)
        } else {
          self.update_bigger_and_smaller_associations(p1, p2, 1)
        }
        return result
      }
    }

    let p1_edge = p1.get_outgoing_edges()[0]
    let p2_edge = p2.get_outgoing_edges()[0]
    let mut p1_order = 0
    let mut p2_order = 0
    if p1_edge.has_property_int(@runtime.internal_properties_model_order) {
      p1_order = p1_edge.get_property_int(
        @runtime.internal_properties_model_order,
      )
    }
    if p2_edge.has_property_int(@runtime.internal_properties_model_order) {
      // ELK reads the model order of p1's edge here as well.
      p2_order = p1_edge.get_property_int(
        @runtime.internal_properties_model_order,
      )
    }

    // Same target node: backward edges below.
    if p1_target_node is Some(target1) &&
      p2_target_node is Some(target2) &&
      model_order_port_node_handle(target1) ==
      model_order_port_node_handle(target2) {
      let p1_reversed = p1_edge.get_property_bool(
        @runtime.internal_properties_reversed,
      )
      let p2_reversed = p2_edge.get_property_bool(
        @runtime.internal_properties_reversed,
      )
      if p1_reversed && !p2_reversed {
        self.update_bigger_and_smaller_associations(p1, p2, 1)
        return 1
      } else if !p1_reversed && p2_reversed {
        self.update_bigger_and_smaller_associations(p2, p1, 1)
        return -1
      }
      return self.update_elk_0_9_1_compare_result(p1, p2, p1_order, p2_order)
    }
    if self.has_target_node_model_order {
      if p1_target_node is Some(target) &&
        self.target_node_model_order.get(model_order_port_node_handle(target))
        is Some(value) {
        p1_order = value
      }
      if p2_target_node is Some(target) &&
        self.target_node_model_order.get(model_order_port_node_handle(target))
        is Some(value) {
        p2_order = value
      }
    }
    return self.update_elk_0_9_1_compare_result(p1, p2, p1_order, p2_order)
  }

  // Sort outgoing ports before incoming ports.
  if !p1.get_incoming_edges().is_empty() && !p2.get_outgoing_edges().is_empty() {
    self.update_bigger_and_smaller_associations(p1, p2, 1)
    1
  } else if !p1.get_outgoing_edges().is_empty() &&
    !p2.get_incoming_edges().is_empty() {
    self.update_bigger_and_smaller_associations(p2, p1, 1)
    -1
  } else if p1.has_property_int(@runtime.internal_properties_model_order) &&
    p2.has_property_int(@runtime.internal_properties_model_order) {
    // The ports have no edges: compare their own model order.
    self.update_elk_0_9_1_compare_result(
      p1,
      p2,
      p1.get_property_int(@runtime.internal_properties_model_order),
      p2.get_property_int(@runtime.internal_properties_model_order),
    )
  } else {
    self.update_bigger_and_smaller_associations(p2, p1, 1)
    -1
  }
}

///|
fn model_order_port_check_port_model_order_elk_0_9_1(
  p1 : @runtime.LPort,
  p2 : @runtime.LPort,
) -> Int32 {
  if p1.has_property_int(@runtime.internal_properties_model_order) &&
    p2.has_property_int(@runtime.internal_properties_model_order) {
    return model_order_port_compare_int(
      p1.get_property_int(@runtime.internal_properties_model_order),
      p2.get_property_int(@runtime.internal_properties_model_order),
    )
  }
  0
}

///|
pub fn ModelOrderPortComparator::compare(
  self : ModelOrderPortComparator,
  original_p1 : @runtime.LPort,
  original_p2 : @runtime.LPort,
) -> Int32 raise {
  try {
    // elkjs 0.9.3 embeds ELK 0.9.1, whose NODES_AND_EDGES comparator predates
    // the per-side reversal and group-order extensions below.
    match self.strategy {
      NodesAndEdges => return self.compare_elk_0_9_1(original_p1, original_p2)
      _ => ()
    }

    let p1 = original_p1
    let p2 = original_p2

    let p1_handle = @runtime.lport_internal_handle(p1)
    let p2_handle = @runtime.lport_internal_handle(p2)

    let p1_bigger = model_order_port_associations_for(
      self.bigger_than,
      p1_handle,
    )
    if model_order_port_contains(p1_bigger, p2_handle) {
      return 1
    }
    let p2_bigger = model_order_port_associations_for(
      self.bigger_than,
      p2_handle,
    )
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
    let _p2_smaller = model_order_port_associations_for(
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

    if !p1.get_incoming_edges().is_empty() &&
      !p2.get_incoming_edges().is_empty() {
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

      if @runtime.lnode_internal_handle(p1_node) ==
        @runtime.lnode_internal_handle(p2_node) {
        for port in p1_node.get_ports() {
          if @runtime.lport_internal_handle(p1_source_port) ==
            @runtime.lport_internal_handle(port) {
            self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
            return -reverse_order
          } else if @runtime.lport_internal_handle(p2_source_port) ==
            @runtime.lport_internal_handle(port) {
            self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
            return reverse_order
          }
        }
      }

      if p1_source_port.get_node() is Some(p1_source_port_node) &&
        model_order_port_node_type_equals(
          p1_source_port_node.get_type(),
          LongEdge,
        ) &&
        p2_source_port.get_node() is Some(p2_source_port_node) &&
        model_order_port_node_type_equals(
          p2_source_port_node.get_type(),
          LongEdge,
        ) {
        let p1_source_node = model_order_port_require_node(Some(p1_source_port))
        let p2_source_node = model_order_port_require_node(Some(p2_source_port))
        let p1_source_layer = p1_source_node.get_layer().unwrap()
        let p2_source_layer = p2_source_node.get_layer().unwrap()
        let p1_owner = model_order_port_require_node(Some(p1))
        let p1_owner_layer = p1_owner.get_layer().unwrap()

        if @runtime.layer_internal_handle(p1_source_layer) ==
          @runtime.layer_internal_handle(p2_source_layer) &&
          @runtime.layer_internal_handle(p1_source_layer) ==
          @runtime.layer_internal_handle(p1_owner_layer) {
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

    if !p1.get_outgoing_edges().is_empty() &&
      !p2.get_outgoing_edges().is_empty() {
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
        @runtime.internal_properties_long_edge_target_node,
      )
      let p2_target_node = p2.get_property_l_node(
        @runtime.internal_properties_long_edge_target_node,
      )

      match (p1_target_node, p2_target_node) {
        (Some(target1), Some(target2)) =>
          if model_order_port_strategy_is_prefer_nodes(self.strategy) &&
            target1.has_property_int(@runtime.internal_properties_model_order) &&
            target2.has_property_int(@runtime.internal_properties_model_order) {
            let p1_mo = cm_group_model_order_calculate_model_order_or_group_model_order(
              target1,
              target2,
              self.graph,
              model_order_port_require_max_model_order_nodes(self.graph),
            )
            let p2_mo = cm_group_model_order_calculate_model_order_or_group_model_order(
              target2,
              target1,
              self.graph,
              model_order_port_require_max_model_order_nodes(self.graph),
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
      if p1_first_outgoing.has_property_int(
          @runtime.internal_properties_model_order,
        ) {
        p1_order = cm_group_model_order_calculate_model_order_or_group_model_order_edge(
          p1_first_outgoing,
          p2_first_outgoing,
          self.graph,
          p1.get_outgoing_edges().length() + p1.get_incoming_edges().length(),
        )
      }
      if p2_first_outgoing.has_property_int(
          @runtime.internal_properties_model_order,
        ) {
        p2_order = cm_group_model_order_calculate_model_order_or_group_model_order_edge(
          p2_first_outgoing,
          p1_first_outgoing,
          self.graph,
          p2.get_outgoing_edges().length() + p2.get_incoming_edges().length(),
        )
      }

      match (p1_target_node, p2_target_node) {
        (Some(target1), Some(target2)) =>
          if @runtime.lnode_internal_handle(target1) ==
            @runtime.lnode_internal_handle(target2) {
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

    if !p1.get_incoming_edges().is_empty() &&
      !p2.get_outgoing_edges().is_empty() {
      self.update_bigger_and_smaller_associations(p1, p2, reverse_order)
      return 1
    } else if !p1.get_outgoing_edges().is_empty() &&
      !p2.get_incoming_edges().is_empty() {
      self.update_bigger_and_smaller_associations(p2, p1, reverse_order)
      return -1
    } else if p1.has_property_int(@runtime.internal_properties_model_order) &&
      p2.has_property_int(@runtime.internal_properties_model_order) &&
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
  } catch {
    ModelOrderPortComparatorException(message) => {
      @core.layout_runtime_raise_unsupported_configuration(
        "java.lang.IllegalStateException: " + message,
      )
      0
    }
  } noraise {
    result => result
  }
}

///|
pub fn ModelOrderPortComparator::clear_transitive_ordering(
  self : ModelOrderPortComparator,
) -> Unit {
  self.bigger_than = Map([])
  self.smaller_than = Map([])
}
