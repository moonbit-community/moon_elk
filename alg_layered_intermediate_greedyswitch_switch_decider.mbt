///|
fn switch_decider_pair_value(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => 0
  }
}

///|
fn switch_decider_node_array_contains(
  nodes : Array[LNode],
  needle : LNode,
) -> Bool {
  for node in nodes {
    if lnode_internal_handle(node) == lnode_internal_handle(needle) {
      return true
    }
  }
  false
}

///|
fn switch_decider_same_layout_unit(left : LNode?, right : LNode?) -> Bool {
  match (left, right) {
    (None, None) => true
    (Some(left_node), Some(right_node)) =>
      lnode_internal_handle(left_node) == lnode_internal_handle(right_node)
    _ => false
  }
}

///|
fn switch_decider_is_external_port(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn switch_decider_is_long_edge(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn switch_decider_is_normal(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn switch_decider_is_north_south_port(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn switch_decider_origin_port_of_external_dummy(node : LNode) -> LPort {
  if node.get_ports().is_empty() {
    abort("external port dummy has no ports")
  }
  match
    node.get_ports()[0].get_property_l_port(internal_properties_origin_l_port) {
    Some(origin_port) => origin_port
    None => abort("external port dummy has no origin port")
  }
}

///|
fn SwitchDecider::switch_decider_parent_cross_counter(
  self : SwitchDecider,
) -> CrossingsCounter {
  match self.parent_cross_counter {
    Some(counter) => counter
    None => abort("parent crossings counter is not initialized")
  }
}

///|
pub struct SwitchDecider {
  free_layer : Array[LNode]
  left_in_layer_counter : CrossingsCounter
  right_in_layer_counter : CrossingsCounter
  north_south_counter : NorthSouthEdgeNeighbouringNodeCrossingsCounter
  crossing_matrix_filler : CrossingMatrixFiller
  graph_data : GraphInfoHolder
  mut parent_cross_counter : CrossingsCounter?
  count_crossings_caused_by_port_switch : Bool
}

///|
pub fn new_switch_decider(
  free_layer_index : Int,
  graph : Array[Array[LNode]],
  crossing_matrix_filler : CrossingMatrixFiller,
  port_positions : Array[Int],
  graph_data : GraphInfoHolder,
  one_sided : Bool,
) -> SwitchDecider {
  if free_layer_index < 0 || free_layer_index >= graph.length() {
    abort("Greedy SwitchDecider: free layer not in graph")
  }

  let free_layer = graph[free_layer_index]
  let left_in_layer_counter = new_crossings_counter(port_positions)
  ignore(
    left_in_layer_counter.init_port_positions_for_in_layer_crossings(
      free_layer,
      PortSide::West,
    ),
  )

  let right_in_layer_counter = new_crossings_counter(port_positions)
  ignore(
    right_in_layer_counter.init_port_positions_for_in_layer_crossings(
      free_layer,
      PortSide::East,
    ),
  )

  let count_crossings_caused_by_port_switch = !one_sided &&
    graph_data.has_parent() &&
    !graph_data.dont_sweep_into() &&
    !free_layer.is_empty() &&
    switch_decider_is_external_port(free_layer[0])

  let switch_decider = {
    free_layer,
    left_in_layer_counter,
    right_in_layer_counter,
    north_south_counter: new_north_south_edge_neighbouring_node_crossings_counter(
      free_layer,
    ),
    crossing_matrix_filler,
    graph_data,
    parent_cross_counter: None,
    count_crossings_caused_by_port_switch,
  }

  if count_crossings_caused_by_port_switch {
    switch_decider.init_parent_crossings_counters(
      free_layer_index,
      graph.length(),
    )
  }

  switch_decider
}

///|
fn SwitchDecider::init_parent_crossings_counters(
  self : SwitchDecider,
  free_layer_index : Int,
  graph_length : Int,
) -> Unit {
  let parent_graph_data = self.graph_data.parent_graph_data()
  let parent_node_order = parent_graph_data.current_node_order()
  let port_pos = parent_graph_data.port_positions()
  let parent_cross_counter = new_crossings_counter(port_pos)
  self.parent_cross_counter = Some(parent_cross_counter)

  let parent_node_layer_pos = self.graph_data.parent_layer_id()
  let left_layer = if parent_node_layer_pos > 0 {
    parent_node_order[parent_node_layer_pos - 1]
  } else {
    []
  }
  let middle_layer = parent_node_order[parent_node_layer_pos]
  let right_layer = if parent_node_layer_pos < parent_node_order.length() - 1 {
    parent_node_order[parent_node_layer_pos + 1]
  } else {
    []
  }

  let right_most_layer = free_layer_index == graph_length - 1
  let counter = self.switch_decider_parent_cross_counter()
  if right_most_layer {
    counter.init_for_counting_between(middle_layer, right_layer)
  } else {
    counter.init_for_counting_between(left_layer, middle_layer)
  }
}

///|
pub fn SwitchDecider::notify_of_switch(
  self : SwitchDecider,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  self.left_in_layer_counter.switch_nodes(
    upper_node,
    lower_node,
    PortSide::West,
  )
  self.right_in_layer_counter.switch_nodes(
    upper_node,
    lower_node,
    PortSide::East,
  )

  if self.count_crossings_caused_by_port_switch {
    let upper_port = switch_decider_origin_port_of_external_dummy(upper_node)
    let lower_port = switch_decider_origin_port_of_external_dummy(lower_node)
    let counter = self.switch_decider_parent_cross_counter()
    counter.switch_ports(upper_port, lower_port)
  }
}

///|
pub fn SwitchDecider::does_switch_reduce_crossings(
  self : SwitchDecider,
  upper_node_index : Int,
  lower_node_index : Int,
) -> Bool {
  if self.constraints_prevent_switch(upper_node_index, lower_node_index) {
    return false
  }

  let upper_node = self.free_layer[upper_node_index]
  let lower_node = self.free_layer[lower_node_index]

  let left_in_layer = self.left_in_layer_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    upper_node,
    lower_node,
    PortSide::West,
  )
  let right_in_layer = self.right_in_layer_counter.count_in_layer_crossings_between_nodes_in_both_orders(
    upper_node,
    lower_node,
    PortSide::East,
  )

  self.north_south_counter.count_crossings(upper_node, lower_node)

  let mut upper_lower_crossings = self.crossing_matrix_filler.get_crossing_matrix_entry(
      upper_node, lower_node,
    ) +
    switch_decider_pair_value(left_in_layer.get_first()) +
    switch_decider_pair_value(right_in_layer.get_first()) +
    self.north_south_counter.get_upper_lower_crossings()

  let mut lower_upper_crossings = self.crossing_matrix_filler.get_crossing_matrix_entry(
      lower_node, upper_node,
    ) +
    switch_decider_pair_value(left_in_layer.get_second()) +
    switch_decider_pair_value(right_in_layer.get_second()) +
    self.north_south_counter.get_lower_upper_crossings()

  if self.count_crossings_caused_by_port_switch {
    let upper_port = switch_decider_origin_port_of_external_dummy(upper_node)
    let lower_port = switch_decider_origin_port_of_external_dummy(lower_node)
    let counter = self.switch_decider_parent_cross_counter()
    let crossing_numbers = counter.count_crossings_between_ports_in_both_orders(
      upper_port, lower_port,
    )
    upper_lower_crossings = upper_lower_crossings +
      switch_decider_pair_value(crossing_numbers.get_first())
    lower_upper_crossings = lower_upper_crossings +
      switch_decider_pair_value(crossing_numbers.get_second())
  }

  upper_lower_crossings > lower_upper_crossings
}

///|
fn SwitchDecider::constraints_prevent_switch(
  self : SwitchDecider,
  node_index : Int,
  lower_node_index : Int,
) -> Bool {
  let upper_node = self.free_layer[node_index]
  let lower_node = self.free_layer[lower_node_index]

  self.have_successor_constraints(upper_node, lower_node) ||
  self.have_layout_unit_constraints(upper_node, lower_node) ||
  self.are_normal_and_north_south_port_dummy(upper_node, lower_node)
}

///|
fn SwitchDecider::have_successor_constraints(
  self : SwitchDecider,
  upper_node : LNode,
  lower_node : LNode,
) -> Bool {
  ignore(self)
  let constraints = upper_node.get_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
  )
  !constraints.is_empty() &&
  switch_decider_node_array_contains(constraints, lower_node)
}

///|
fn SwitchDecider::have_layout_unit_constraints(
  self : SwitchDecider,
  upper_node : LNode,
  lower_node : LNode,
) -> Bool {
  ignore(self)
  let neither_node_is_long_edge_dummy = !switch_decider_is_long_edge(upper_node) &&
    !switch_decider_is_long_edge(lower_node)

  let upper_layout_unit = upper_node.get_property_l_node(
    internal_properties_in_layer_layout_unit,
  )
  let lower_layout_unit = lower_node.get_property_l_node(
    internal_properties_in_layer_layout_unit,
  )

  let are_in_different_layout_units = !switch_decider_same_layout_unit(
    upper_layout_unit, lower_layout_unit,
  )

  let mut nodes_have_layout_units = self.part_of_multi_node_layout_unit(
      upper_node, upper_layout_unit,
    ) ||
    self.part_of_multi_node_layout_unit(lower_node, lower_layout_unit)

  let upper_node_has_northern_edges = self.has_edges_on_side(
    upper_node,
    PortSide::North,
  )
  let lower_node_has_southern_edges = self.has_edges_on_side(
    lower_node,
    PortSide::South,
  )

  nodes_have_layout_units = nodes_have_layout_units ||
    self.has_edges_on_side(upper_node, PortSide::South) ||
    self.has_edges_on_side(lower_node, PortSide::North)

  let has_layout_unit_constraint = (
      nodes_have_layout_units && are_in_different_layout_units
    ) ||
    upper_node_has_northern_edges ||
    lower_node_has_southern_edges

  neither_node_is_long_edge_dummy && has_layout_unit_constraint
}

///|
fn SwitchDecider::has_edges_on_side(
  self : SwitchDecider,
  node : LNode,
  side : PortSide,
) -> Bool {
  ignore(self)
  for port in node.get_port_side_view(side) {
    if port.get_property_l_node(internal_properties_port_dummy) is Some(_) ||
      !port.get_connected_edges().is_empty() {
      return true
    }
  }
  false
}

///|
fn SwitchDecider::part_of_multi_node_layout_unit(
  self : SwitchDecider,
  node : LNode,
  layout_unit : LNode?,
) -> Bool {
  ignore(self)
  match layout_unit {
    Some(unit) => lnode_internal_handle(unit) != lnode_internal_handle(node)
    None => false
  }
}

///|
fn SwitchDecider::are_normal_and_north_south_port_dummy(
  self : SwitchDecider,
  upper_node : LNode,
  lower_node : LNode,
) -> Bool {
  ignore(self)
  (self.is_north_south_port_node(upper_node) && self.is_normal_node(lower_node)) ||
  (self.is_north_south_port_node(lower_node) && self.is_normal_node(upper_node))
}

///|
fn SwitchDecider::is_normal_node(self : SwitchDecider, node : LNode) -> Bool {
  ignore(self)
  switch_decider_is_normal(node)
}

///|
fn SwitchDecider::is_north_south_port_node(
  self : SwitchDecider,
  node : LNode,
) -> Bool {
  ignore(self)
  switch_decider_is_north_south_port(node)
}
