///|
fn test_graph_creator_pop_graph(graphs : Array[LGraph]) -> LGraph {
  match graphs.pop() {
    Some(graph) => graph
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "test graph stack is empty",
      )
      new_l_graph()
    }
  }
}

///|
fn test_graph_creator_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "UNDEFINED" => @core.PortConstraints::Undefined
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn[T] test_graph_creator_copy_array(arr : Array[T]) -> Array[T] {
  let copy = []
  for item in arr {
    copy.push(item)
  }
  copy
}

///|
fn[T] test_graph_creator_get_by_indices(
  items : Array[T],
  indices : Array[Int],
) -> Array[T] {
  let copy = []
  for i in indices {
    copy.push(items[i])
  }
  copy
}

///|
fn test_graph_creator_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::North, @core.PortSide::North) => true
    (@core.PortSide::East, @core.PortSide::East) => true
    (@core.PortSide::South, @core.PortSide::South) => true
    (@core.PortSide::West, @core.PortSide::West) => true
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    _ => false
  }
}

///|
pub struct GreedySwitchMockRandom {
  mut seed : Int64
  mut use_mock_sequence : Bool
  mut current : Double
  mut change_by : Double
  mut next_boolean_override : Bool?
}

///|
let greedy_switch_mock_random_multiplier = 25214903917L

///|
let greedy_switch_mock_random_addend = 11L

///|
let greedy_switch_mock_random_mask = 281474976710655L

///|
fn greedy_switch_mock_random_scramble_seed(seed : Int64) -> Int64 {
  (seed ^ greedy_switch_mock_random_multiplier) & greedy_switch_mock_random_mask
}

///|
fn greedy_switch_mock_random_to_signed_int32(value : Int64) -> Int {
  let masked = value & 4294967295L
  if masked >= 2147483648L {
    (masked - 4294967296L).to_int()
  } else {
    masked.to_int()
  }
}

///|
fn greedy_switch_mock_random_system_seed() -> Int64 {
  let source = @random.Rand::new()
  let high = Int64::from_int(source.int(limit=@int.max_value))
  let low = Int64::from_int(source.int(limit=@int.max_value))
  (high << 31) ^ low
}

///|
pub fn new_greedy_switch_mock_random() -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(
      greedy_switch_mock_random_system_seed(),
    ),
    use_mock_sequence: true,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: Some(true),
  }
}

///|
pub fn new_greedy_switch_mock_random_seeded(
  seed_value : Int,
) -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(Int64::from_int(seed_value)),
    use_mock_sequence: false,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: None,
  }
}

///|
pub fn new_greedy_switch_mock_random_seeded_int64(
  seed_value : Int64,
) -> GreedySwitchMockRandom {
  {
    seed: greedy_switch_mock_random_scramble_seed(seed_value),
    use_mock_sequence: false,
    current: 0.01,
    change_by: 0.01,
    next_boolean_override: None,
  }
}

///|
fn GreedySwitchMockRandom::next_bits(
  self : GreedySwitchMockRandom,
  bits : Int,
) -> Int {
  self.seed = (
      self.seed * greedy_switch_mock_random_multiplier +
      greedy_switch_mock_random_addend
    ) &
    greedy_switch_mock_random_mask

  let value = self.seed >> (48 - bits)
  if bits == 32 && value >= 2147483648L {
    (value - 4294967296L).to_int()
  } else {
    value.to_int()
  }
}

///|
pub fn GreedySwitchMockRandom::next_boolean(
  self : GreedySwitchMockRandom,
) -> Bool {
  if self.next_boolean_override is Some(next_boolean) {
    next_boolean
  } else {
    self.next_bits(1) != 0
  }
}

///|
pub fn GreedySwitchMockRandom::next_float(
  self : GreedySwitchMockRandom,
) -> Float {
  if self.use_mock_sequence {
    self.current = self.current + self.change_by
    Float::from_double(self.current)
  } else {
    Float::from_double(self.next_bits(24).to_double() / 16777216.0)
  }
}

///|
pub fn GreedySwitchMockRandom::next_double(
  self : GreedySwitchMockRandom,
) -> Double {
  if self.use_mock_sequence {
    self.current = self.current + self.change_by
    self.current
  } else {
    let high = Int64::from_int(self.next_bits(26))
    let low = Int64::from_int(self.next_bits(27))
    ((high << 27) + low).to_double() / 9007199254740992.0
  }
}

///|
pub fn GreedySwitchMockRandom::next_int(
  self : GreedySwitchMockRandom,
  limit : Int,
) -> Int {
  if limit <= 0 {
    @core.layout_runtime_report_unsupported_configuration(
      "limit must be positive",
    )
    return 0
  }

  if (limit & -limit) == limit {
    let product = Int64::from_int(limit) * Int64::from_int(self.next_bits(31))
    return (product >> 31).to_int()
  }

  let mut bits = 0
  let mut value = 0
  while true {
    bits = self.next_bits(31)
    value = bits % limit
    let probe = greedy_switch_mock_random_to_signed_int32(
      Int64::from_int(bits) -
      Int64::from_int(value) +
      Int64::from_int(limit - 1),
    )
    if probe >= 0 {
      return value
    }
  }
  @core.layout_runtime_report_unsupported_configuration("unreachable")
  0
}

///|
pub fn GreedySwitchMockRandom::int(
  self : GreedySwitchMockRandom,
  limit : Int,
) -> Int {
  self.next_int(limit)
}

///|
pub fn GreedySwitchMockRandom::next_long(
  self : GreedySwitchMockRandom,
) -> Int64 {
  (Int64::from_int(self.next_bits(32)) << 32) +
  Int64::from_int(self.next_bits(32))
}

///|
pub fn GreedySwitchMockRandom::set_seed(
  self : GreedySwitchMockRandom,
  seed : Int64,
) -> Unit {
  self.seed = greedy_switch_mock_random_scramble_seed(seed)
}

///|
pub fn GreedySwitchMockRandom::set_seed_int(
  self : GreedySwitchMockRandom,
  seed : Int,
) -> Unit {
  self.set_seed(Int64::from_int(seed))
}

///|
pub fn GreedySwitchMockRandom::set_next_boolean(
  self : GreedySwitchMockRandom,
  next_boolean : Bool,
) -> Unit {
  self.next_boolean_override = Some(next_boolean)
}

///|
pub fn GreedySwitchMockRandom::clear_next_boolean_override(
  self : GreedySwitchMockRandom,
) -> Unit {
  self.next_boolean_override = None
}

///|
pub fn GreedySwitchMockRandom::set_change_by(
  self : GreedySwitchMockRandom,
  change_by : Double,
) -> Unit {
  self.use_mock_sequence = true
  self.change_by = change_by
}

///|
pub fn GreedySwitchMockRandom::set_current(
  self : GreedySwitchMockRandom,
  current : Float,
) -> Unit {
  self.use_mock_sequence = true
  self.current = current.to_double()
}

///|
pub struct GreedySwitchTestGraphCreator {
  mut port_id : Int
  mut node_id : Int
  mut edge_id : Int
  mut graph : LGraph
  mut random : GreedySwitchMockRandom
}

///|
pub fn new_greedy_switch_test_graph_creator() -> GreedySwitchTestGraphCreator {
  let creator = {
    port_id: 0,
    node_id: 0,
    edge_id: 0,
    graph: new_l_graph(),
    random: new_greedy_switch_mock_random(),
  }
  ignore(creator.set_up_graph(creator.graph))
  creator
}

///|
pub fn GreedySwitchTestGraphCreator::get_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  self.set_up_graph(self.graph)
}

///|
pub fn GreedySwitchTestGraphCreator::set_graph(
  self : GreedySwitchTestGraphCreator,
  graph : LGraph,
) -> LGraph {
  self.graph = graph
  self.set_up_graph(self.graph)
}

///|
pub fn GreedySwitchTestGraphCreator::set_up_graph(
  self : GreedySwitchTestGraphCreator,
  graph : LGraph,
) -> LGraph {
  self.set_up_ids()
  graph.set_property_mock_random(internal_properties_random, Some(self.random))
  graph.set_property_bool(
    internal_properties_random_next_boolean,
    self.random.next_boolean(),
  )
  graph.set_property_string(
    layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )
  graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_empty_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  self.graph = new_l_graph()
  self.set_up_graph(self.graph)
}

///|
pub fn GreedySwitchTestGraphCreator::get_two_nodes_no_connection_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layer = self.make_layer(self.graph)
  ignore(self.add_node_to_layer(layer))
  ignore(self.add_node_to_layer(layer))
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::set_up_ids(
  self : GreedySwitchTestGraphCreator,
) -> Unit {
  let graphs = [self.graph]
  while !graphs.is_empty() {
    let graph = test_graph_creator_pop_graph(graphs)
    let mut layer_id = 0
    let mut port_id = 0
    for layer in graph.get_layers() {
      layer.set_id(layer_id)
      layer_id = layer_id + 1
      let mut node_id = 0
      for node in layer.get_nodes() {
        match node.get_nested_graph() {
          Some(nested) => graphs.push(nested)
          None => ()
        }
        node.set_id(node_id)
        node_id = node_id + 1
        for port in node.get_ports() {
          port.set_id(port_id)
          port_id = port_id + 1
        }
      }
    }
  }
}

///|
pub fn GreedySwitchTestGraphCreator::get_cross_formed_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let top_right = self.add_node_to_layer(right_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(bottom_left, top_right)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::multiple_edges_and_single_edge(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(bottom_left, bottom_right)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_cross_formed_graph_with_constraints_in_second_layer(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  ignore(self.get_cross_formed_graph())
  let layer_one = self.graph.get_layers()[1]
  let top_node = layer_one.get_nodes()[0]
  let second_node = layer_one.get_nodes()[1]
  self.set_in_layer_order_constraint(top_node, second_node)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_cross_formed_graph_constraints_prevent_any_switch(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let top_right = self.add_node_to_layer(right_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(bottom_left, top_right)
  self.set_in_layer_order_constraint(top_right, bottom_right)
  self.set_in_layer_order_constraint(top_left, bottom_left)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_one_node_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layer = self.make_layer(self.graph)
  ignore(self.add_node_to_layer(layer))
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_in_layer_edges_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let middle_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_node = self.add_node_to_layer(left_layer)
  let middle_nodes = self.add_nodes_to_layer(3, middle_layer)
  let right_node = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(middle_nodes[1], right_node)
  self.east_west_edge_from_to_nodes(left_node, middle_nodes[1])
  self.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[2],
    @core.PortSide::West,
  )
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_in_layer_edges_graph_which_results_in_crossings_when_switched(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_node = self.add_node_to_layer(left_layer)
  let right_nodes = self.add_nodes_to_layer(3, right_layer)

  self.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    @core.PortSide::West,
  )
  self.east_west_edge_from_to_nodes(left_node, right_nodes[2])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_multiple_edges_between_same_nodes_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let top_right = self.add_node_to_layer(right_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  self.east_west_edge_from_to_nodes(bottom_left, top_right)
  self.east_west_edge_from_to_nodes(bottom_left, top_right)

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_cross_with_extra_edge_in_between_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_nodes = self.add_nodes_to_layer(3, left_layer)
  let right_nodes = self.add_nodes_to_layer(3, right_layer)

  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[2])
  self.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[2], right_nodes[0])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_cross_with_many_self_loops_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let top_right = self.add_node_to_layer(right_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  let top_left_port = self.add_port_on_side(top_left, @core.PortSide::East)
  let bottom_left_port = self.add_port_on_side(
    bottom_left,
    @core.PortSide::East,
  )
  self.set_up_ids()
  let self_loop_cross_graph = self.graph
  for layer in self_loop_cross_graph.get_layers() {
    for node in layer.get_nodes() {
      self.self_loop_on(node, @core.PortSide::East)
      self.self_loop_on(node, @core.PortSide::East)
      self.self_loop_on(node, @core.PortSide::East)
      self.self_loop_on(node, @core.PortSide::West)
      self.self_loop_on(node, @core.PortSide::West)
      self.self_loop_on(node, @core.PortSide::West)
    }
  }
  let top_right_port = self.add_port_on_side(top_right, @core.PortSide::West)
  let bottom_right_port = self.add_port_on_side(
    bottom_right,
    @core.PortSide::West,
  )

  self.add_edge_between_ports(top_left_port, bottom_right_port)
  self.add_edge_between_ports(bottom_left_port, top_right_port)
  self_loop_cross_graph
}

///|
pub fn GreedySwitchTestGraphCreator::self_loop_on(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
  side : @core.PortSide,
) -> Unit {
  self.add_edge_between_ports(
    self.add_port_on_side(node, side),
    self.add_port_on_side(node, side),
  )
}

///|
pub fn GreedySwitchTestGraphCreator::get_more_complex_three_layer_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let middle_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_nodes = self.add_nodes_to_layer(3, left_layer)
  let middle_nodes = self.add_nodes_to_layer(2, middle_layer)
  let right_nodes = self.add_nodes_to_layer(3, right_layer)

  let left_middle_node_port = self.add_port_on_side(
    left_nodes[1],
    @core.PortSide::East,
  )
  let middle_lower_node_port_east = self.add_port_on_side(
    middle_nodes[1],
    @core.PortSide::East,
  )
  let middle_upper_node_port_east = self.add_port_on_side(
    middle_nodes[0],
    @core.PortSide::East,
  )
  let right_upper_node_port = self.add_port_on_side(
    right_nodes[0],
    @core.PortSide::West,
  )
  let right_middle_node_port = self.add_port_on_side(
    right_nodes[1],
    @core.PortSide::West,
  )
  self.set_up_ids()

  self.add_edge_between_ports(
    middle_upper_node_port_east, right_upper_node_port,
  )
  self.add_edge_between_ports(
    middle_upper_node_port_east, right_middle_node_port,
  )
  self.add_edge_between_ports(
    middle_upper_node_port_east, right_middle_node_port,
  )
  self.east_west_edge_from_to_port_node(
    middle_lower_node_port_east,
    right_nodes[2],
  )
  self.east_west_edge_from_to_port_node(left_middle_node_port, middle_nodes[0])
  self.east_west_edge_from_to_node_port(middle_nodes[1], right_upper_node_port)
  self.east_west_edge_from_to_port_node(left_middle_node_port, middle_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[2], middle_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[0])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_fixed_port_order_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_node = self.add_node_to_layer(left_layer)
  self.set_port_order_fixed(left_node)

  let right_top_node = self.add_node_to_layer(right_layer)
  let right_bottom_node = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(left_node, right_bottom_node)
  self.east_west_edge_from_to_nodes(left_node, right_top_node)

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_graph_no_crossings_due_to_port_order_not_fixed(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let left_node = self.add_node_to_layer(left_layer)
  let right_top_node = self.add_node_to_layer(right_layer)
  let right_bottom_node = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(left_node, right_bottom_node)
  self.east_west_edge_from_to_nodes(left_node, right_top_node)

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_switch_only_one_sided(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layers = self.make_layers(3)

  let left_nodes = self.add_nodes_to_layer(2, layers[0])
  let middle_nodes = self.add_nodes_to_layer(2, layers[1])
  let right_nodes = self.add_nodes_to_layer(2, layers[2])

  self.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[0])
  self.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[0])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_switch_only_east_one_sided(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layers = self.make_layers(3)

  let left_nodes = self.add_nodes_to_layer(2, layers[0])
  let middle_nodes = self.add_nodes_to_layer(2, layers[1])
  let right_nodes = self.add_nodes_to_layer(2, layers[2])

  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[1])
  self.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[1])
  self.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_fixed_port_order_in_layer_edges_dont_cross_each_other(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layer = self.make_layer(self.graph)
  let nodes = self.add_nodes_to_layer(2, layer)
  self.set_fixed_order_constraint(nodes[0])
  self.set_fixed_order_constraint(nodes[1])

  let upper_port_upper_node = self.add_port_on_side(
    nodes[0],
    @core.PortSide::East,
  )
  let lower_port_upper_node = self.add_port_on_side(
    nodes[0],
    @core.PortSide::East,
  )
  let upper_port_lower_node = self.add_port_on_side(
    nodes[1],
    @core.PortSide::East,
  )
  let lower_port_lower_node = self.add_port_on_side(
    nodes[1],
    @core.PortSide::East,
  )
  self.add_edge_between_ports(upper_port_upper_node, lower_port_lower_node)
  self.add_edge_between_ports(lower_port_upper_node, upper_port_lower_node)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_fixed_port_order_in_layer_edges_with_crossings(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layer = self.make_layer(self.graph)
  let nodes = self.add_nodes_to_layer(2, layer)
  self.set_fixed_order_constraint(nodes[0])
  self.set_fixed_order_constraint(nodes[1])
  self.add_in_layer_edge_nodes(nodes[0], nodes[1], @core.PortSide::East)
  self.add_in_layer_edge_nodes(nodes[0], nodes[1], @core.PortSide::East)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_more_complex_in_layer_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layers = self.make_layers(3)
  let left_nodes = self.add_nodes_to_layer(4, layers[0])
  let middle_nodes = self.add_nodes_to_layer(3, layers[1])
  let right_node = self.add_node_to_layer(layers[2])
  self.set_fixed_order_constraint(middle_nodes[0])
  self.set_fixed_order_constraint(middle_nodes[1])

  self.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[0])

  self.east_west_edge_from_to_nodes(left_nodes[3], middle_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[2], middle_nodes[1])
  self.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[1],
    @core.PortSide::West,
  )
  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[0])
  self.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[2],
    @core.PortSide::West,
  )

  self.add_in_layer_edge_nodes(
    middle_nodes[0],
    middle_nodes[1],
    @core.PortSide::East,
  )
  self.east_west_edge_from_to_nodes(middle_nodes[0], right_node)

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_graph_which_could_be_worsened_by_switch(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layers = self.make_layers(3)
  let left_nodes = self.add_nodes_to_layer(2, layers[0])
  let middle_nodes = self.add_nodes_to_layer(2, layers[1])
  let right_nodes = self.add_nodes_to_layer(2, layers[2])

  self.set_in_layer_order_constraint(left_nodes[0], left_nodes[1])
  self.set_in_layer_order_constraint(right_nodes[0], right_nodes[1])

  self.east_west_edge_from_to_nodes(middle_nodes[0], right_nodes[1])
  self.east_west_edge_from_to_nodes(middle_nodes[1], right_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[0], middle_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[1], middle_nodes[1])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_nodes_in_different_layout_units_prevent_switch(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let layers = self.make_layers(2)
  let left_nodes = self.add_nodes_to_layer(2, layers[0])
  let right_nodes = self.add_nodes_to_layer(3, layers[1])

  self.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])

  self.add_north_south_edge(
    @core.PortSide::East,
    right_nodes[2],
    right_nodes[1],
    left_nodes[0],
    true,
  )

  right_nodes[1].set_property_l_node(
    internal_properties_in_layer_layout_unit,
    Some(right_nodes[2]),
  )
  right_nodes[2].set_property_l_node(
    internal_properties_in_layer_layout_unit,
    Some(right_nodes[2]),
  )

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::multiple_in_between_layer_edges_into_node_with_no_fixed_port_order(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let left_nodes = self.add_nodes_to_layer(2, left_layer)
  let right_layer = self.make_layer(self.graph)
  let right_nodes = self.add_nodes_to_layer(2, right_layer)

  self.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[1],
    @core.PortSide::West,
  )
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::multiple_in_between_layer_edges_into_node_with_no_fixed_port_order_cause_crossings(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let left_nodes = self.add_nodes_to_layer(2, left_layer)
  let right_layer = self.make_layer(self.graph)
  let right_nodes = self.add_nodes_to_layer(3, right_layer)

  self.add_in_layer_edge_nodes(
    right_nodes[0],
    right_nodes[2],
    @core.PortSide::West,
  )
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_switched_problem_graph(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_nodes = self.add_nodes_to_layer(2, self.make_layer(self.graph))
  let right_nodes = self.add_nodes_to_layer(4, self.make_layer(self.graph))

  self.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[2])
  self.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[3])

  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[0])
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  self.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[2])

  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::two_edges_into_same_port(
  self : GreedySwitchTestGraphCreator,
) -> LGraph {
  let left_layer = self.make_layer(self.graph)
  let right_layer = self.make_layer(self.graph)

  let top_left = self.add_node_to_layer(left_layer)
  let bottom_left = self.add_node_to_layer(left_layer)
  let top_right = self.add_node_to_layer(right_layer)
  let bottom_right = self.add_node_to_layer(right_layer)

  self.east_west_edge_from_to_nodes(top_left, bottom_right)
  let bottom_left_first_port = self.add_port_on_side(
    bottom_left,
    @core.PortSide::East,
  )
  let bottom_left_second_port = self.add_port_on_side(
    bottom_left,
    @core.PortSide::East,
  )
  let top_right_first_port = self.add_port_on_side(
    top_right,
    @core.PortSide::West,
  )
  let top_right_second_port = self.add_port_on_side(
    top_right,
    @core.PortSide::West,
  )

  self.add_edge_between_ports(bottom_left_first_port, top_right_first_port)
  self.add_edge_between_ports(bottom_left_second_port, top_right_second_port)
  self.set_up_ids()
  self.graph
}

///|
pub fn GreedySwitchTestGraphCreator::get_current_order(
  self : GreedySwitchTestGraphCreator,
  graph : LGraph,
) -> Array[Array[LNode]] {
  ignore(self)
  let node_order = []
  for layer in graph.get_layers() {
    let nodes = []
    for node in layer.get_nodes() {
      nodes.push(node)
    }
    node_order.push(nodes)
  }
  node_order
}

///|
pub fn GreedySwitchTestGraphCreator::set_as_north_south_node(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> Unit {
  ignore(self)
  node.set_type(NodeType::NorthSouthPort)
}

///|
pub fn GreedySwitchTestGraphCreator::add_north_south_edge(
  self : GreedySwitchTestGraphCreator,
  side : @core.PortSide,
  node_with_ns_ports : LNode,
  north_south_dummy : LNode,
  node_with_east_west_ports : LNode,
  node_with_east_west_ports_is_origin : Bool,
) -> Unit {
  let normal_node_east_of_ns_port_node = match
    (node_with_east_west_ports.get_layer(), node_with_ns_ports.get_layer()) {
    (Some(normal_layer), Some(ns_layer)) =>
      normal_layer.get_index() < ns_layer.get_index()
    _ => false
  }
  let direction = if normal_node_east_of_ns_port_node {
    @core.PortSide::West
  } else {
    @core.PortSide::East
  }

  let target_node_port_side = direction.opposed()
  let normal_node_port = self.add_port_on_side(
    node_with_east_west_ports, target_node_port_side,
  )
  let dummy_node_port = self.add_port_on_side(north_south_dummy, direction)

  if node_with_east_west_ports_is_origin {
    self.add_edge_between_ports(normal_node_port, dummy_node_port)
  } else {
    self.add_edge_between_ports(dummy_node_port, normal_node_port)
  }

  north_south_dummy.set_property_l_node(
    internal_properties_in_layer_layout_unit,
    Some(node_with_ns_ports),
  )
  north_south_dummy.set_property_l_node(
    internal_properties_origin_l_node,
    Some(node_with_ns_ports),
  )
  self.set_as_north_south_node(north_south_dummy)

  let origin_port = self.add_port_on_side(node_with_ns_ports, side)
  dummy_node_port.set_property_l_port(
    internal_properties_origin_l_port,
    Some(origin_port),
  )
  origin_port.set_property_l_node(
    internal_properties_port_dummy,
    Some(north_south_dummy),
  )

  let barycenter_associates = node_with_ns_ports.get_property_l_node_array(
    internal_properties_barycenter_associates,
  )
  barycenter_associates.push(north_south_dummy)
  node_with_ns_ports.set_property_l_node_array(
    internal_properties_barycenter_associates, barycenter_associates,
  )

  if test_graph_creator_side_equals(side, @core.PortSide::North) {
    let successor_constraints = north_south_dummy.get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    )
    successor_constraints.push(node_with_ns_ports)
    north_south_dummy.set_property_l_node_array(
      internal_properties_in_layer_successor_constraints, successor_constraints,
    )
  } else {
    let successor_constraints = node_with_ns_ports.get_property_l_node_array(
      internal_properties_in_layer_successor_constraints,
    )
    successor_constraints.push(north_south_dummy)
    node_with_ns_ports.set_property_l_node_array(
      internal_properties_in_layer_successor_constraints, successor_constraints,
    )
  }
}

///|
pub fn GreedySwitchTestGraphCreator::set_in_layer_order_constraint(
  self : GreedySwitchTestGraphCreator,
  this_node : LNode,
  before_this_node : LNode,
) -> Unit {
  ignore(self)
  this_node.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
    [before_this_node],
  )
}

///|
pub fn GreedySwitchTestGraphCreator::set_as_long_edge_dummy(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> Unit {
  ignore(self)
  node.set_type(NodeType::LongEdge)
  node.set_property_l_node(internal_properties_in_layer_layout_unit, None)
}

///|
pub fn GreedySwitchTestGraphCreator::set_port_order_fixed(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> Unit {
  ignore(self)
  node.set_property_string(@core.port_constraints, "FIXED_ORDER")
}

///|
pub fn GreedySwitchTestGraphCreator::make_layers(
  self : GreedySwitchTestGraphCreator,
  amount : Int,
) -> Array[Layer] {
  self.make_layers_in_graph(amount, self.graph)
}

///|
pub fn GreedySwitchTestGraphCreator::make_layers_in_graph(
  self : GreedySwitchTestGraphCreator,
  amount : Int,
  graph : LGraph,
) -> Array[Layer] {
  let layers = []
  for _ in 0..<amount {
    layers.push(self.make_layer(graph))
  }
  layers
}

///|
pub fn GreedySwitchTestGraphCreator::set_fixed_order_constraint(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> Unit {
  self.set_port_order_fixed(node)
}

///|
pub fn GreedySwitchTestGraphCreator::set_fixed_order_constraint_on_nodes(
  self : GreedySwitchTestGraphCreator,
  nodes : Array[LNode],
) -> Unit {
  for node in nodes {
    self.set_fixed_order_constraint(node)
  }
}

///|
pub fn GreedySwitchTestGraphCreator::add_in_layer_edge_nodes(
  self : GreedySwitchTestGraphCreator,
  node_one : LNode,
  node_two : LNode,
  port_side : @core.PortSide,
) -> Unit {
  let port_one = self.add_port_on_side(node_one, port_side)
  let port_two = self.add_port_on_side(node_two, port_side)
  self.add_edge_between_ports(port_one, port_two)
}

///|
pub fn GreedySwitchTestGraphCreator::add_in_layer_edge_node_port(
  self : GreedySwitchTestGraphCreator,
  node_one : LNode,
  port_two : LPort,
  port_side : @core.PortSide,
) -> Unit {
  let port_one = self.add_port_on_side(node_one, port_side)
  self.add_edge_between_ports(port_one, port_two)
}

///|
pub fn GreedySwitchTestGraphCreator::add_in_layer_edge_port_node(
  self : GreedySwitchTestGraphCreator,
  port_one : LPort,
  node_two : LNode,
) -> Unit {
  let port_two = self.add_port_on_side(node_two, port_one.get_side())
  self.add_edge_between_ports(port_one, port_two)
}

///|
pub fn GreedySwitchTestGraphCreator::add_nodes_to_layer(
  self : GreedySwitchTestGraphCreator,
  amount_of_nodes : Int,
  layer : Layer,
) -> Array[LNode] {
  let nodes = []
  for _ in 0..<amount_of_nodes {
    nodes.push(self.add_node_to_layer(layer))
  }
  nodes
}

///|
pub fn GreedySwitchTestGraphCreator::make_layer(
  _self : GreedySwitchTestGraphCreator,
  graph : LGraph,
) -> Layer {
  let layer = new_layer(graph)
  graph.get_layers().push(layer)
  layer
}

///|
pub fn GreedySwitchTestGraphCreator::add_node_to_layer(
  self : GreedySwitchTestGraphCreator,
  layer : Layer,
) -> LNode {
  let node = new_l_node(graph=Some(layer.get_graph()))
  node.set_type(NodeType::Normal)
  node.set_property_l_node(internal_properties_in_layer_layout_unit, Some(node))
  node.set_layer(Some(layer))
  node.set_id(self.node_id)
  self.node_id = self.node_id + 1
  node
}

///|
pub fn GreedySwitchTestGraphCreator::east_west_edge_from_to_nodes(
  self : GreedySwitchTestGraphCreator,
  left : LNode,
  right : LNode,
) -> Unit {
  let left_port = self.add_port_on_side(left, @core.PortSide::East)
  let right_port = self.add_port_on_side(right, @core.PortSide::West)
  self.add_edge_between_ports(left_port, right_port)
}

///|
pub fn GreedySwitchTestGraphCreator::add_edge_between_ports(
  self : GreedySwitchTestGraphCreator,
  from : LPort,
  to : LPort,
) -> Unit {
  let edge = new_l_edge()
  edge.set_source(Some(from))
  edge.set_target(Some(to))
  edge.set_id(self.edge_id)
  self.edge_id = self.edge_id + 1
}

///|
pub fn GreedySwitchTestGraphCreator::add_port_on_side(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
  port_side : @core.PortSide,
) -> LPort {
  let port = self.add_port_to(node)
  port.set_side(port_side)

  let current_constraints = if node.has_property_string(@core.port_constraints) {
    node.get_property_string(@core.port_constraints)
  } else {
    @core.port_constraints.get_default()
  }
  if !test_graph_creator_port_constraints_from_string(current_constraints).is_side_fixed() {
    node.set_property_string(@core.port_constraints, "FIXED_SIDE")
  }
  port
}

///|
pub fn GreedySwitchTestGraphCreator::add_ports_on_side(
  self : GreedySwitchTestGraphCreator,
  n : Int,
  node : LNode,
  port_side : @core.PortSide,
) -> Array[LPort] {
  let ports = []
  for _ in 0..<n {
    ports.push(self.add_port_on_side(node, port_side))
  }
  ports
}

///|
fn GreedySwitchTestGraphCreator::add_port_to(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> LPort {
  let port = new_l_port()
  port.set_node(Some(node))
  port.set_id(self.port_id)
  self.port_id = self.port_id + 1
  port
}

///|
pub fn[T] GreedySwitchTestGraphCreator::get_list_copy_in_index_order(
  self : GreedySwitchTestGraphCreator,
  list : Array[T],
  indices : Array[Int],
) -> Array[T] {
  ignore(self)
  test_graph_creator_get_by_indices(list, indices)
}

///|
pub fn[T] GreedySwitchTestGraphCreator::copy_of_list_switching_order(
  self : GreedySwitchTestGraphCreator,
  i : Int,
  j : Int,
  list : Array[T],
) -> Array[T] {
  ignore(self)
  let copy = test_graph_creator_copy_array(list)
  let first = copy[i]
  let second = copy[j]
  copy[i] = second
  copy[j] = first
  copy
}

///|
pub fn[T] GreedySwitchTestGraphCreator::switch_order_in_array(
  self : GreedySwitchTestGraphCreator,
  i : Int,
  j : Int,
  arr : Array[T],
) -> Array[T] {
  ignore(self)
  let copy = test_graph_creator_copy_array(arr)
  let first = copy[i]
  let second = copy[j]
  copy[i] = second
  copy[j] = first
  copy
}

///|
pub fn GreedySwitchTestGraphCreator::add_external_port_dummy_node_to_layer(
  self : GreedySwitchTestGraphCreator,
  layer : Layer,
  port : LPort,
) -> LNode {
  let node = self.add_node_to_layer(layer)
  node.set_type(NodeType::ExternalPort)
  node.set_property_l_port(internal_properties_origin_l_port, Some(port))
  node.set_property_port_side(
    internal_properties_ext_port_side,
    port.get_side(),
  )
  port.set_property_l_node(internal_properties_port_dummy, Some(node))
  port.set_property_bool(internal_properties_inside_connections, true)
  let graph = node.get_graph()
  let graph_properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  let mut has_external_ports = false
  for property in graph_properties {
    match property {
      GraphProperties::ExternalPorts => {
        has_external_ports = true
        break
      }
      _ => ()
    }
  }
  if !has_external_ports {
    graph_properties.push(GraphProperties::ExternalPorts)
    graph.set_property_graph_properties_array(
      internal_properties_graph_properties, graph_properties,
    )
  }
  node
}

///|
pub fn GreedySwitchTestGraphCreator::add_external_port_dummies_to_layer(
  self : GreedySwitchTestGraphCreator,
  layer : Layer,
  ports : Array[LPort],
) -> Array[LNode] {
  if ports.is_empty() {
    return []
  }
  let nodes = []
  let side = ports[0].get_side()
  for i in 0..<ports.length() {
    let port_index = if test_graph_creator_side_equals(
        side,
        @core.PortSide::East,
      ) {
      i
    } else {
      ports.length() - 1 - i
    }
    nodes.push(
      self.add_external_port_dummy_node_to_layer(layer, ports[port_index]),
    )
  }
  nodes
}

///|
pub fn GreedySwitchTestGraphCreator::nested_graph(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
) -> LGraph {
  match node.get_nested_graph() {
    Some(graph) => graph
    None => {
      let nested_graph = new_l_graph()
      ignore(self.set_up_graph(nested_graph))
      node.set_nested_graph(Some(nested_graph))
      nested_graph.set_parent_node(Some(node))
      nested_graph
    }
  }
}

///|
pub fn GreedySwitchTestGraphCreator::switch_order_of_nodes_in_layer(
  self : GreedySwitchTestGraphCreator,
  node_one : Int,
  node_two : Int,
  layer : Layer,
) -> Array[LNode] {
  ignore(self)
  let nodes = layer.get_nodes()
  let switched = test_graph_creator_copy_array(nodes)
  let first_node = switched[node_one]
  let second_node = switched[node_two]
  switched[node_one] = second_node
  switched[node_two] = first_node
  switched
}

///|
pub fn GreedySwitchTestGraphCreator::copy_of_nodes_in_layer(
  self : GreedySwitchTestGraphCreator,
  layer_index : Int,
) -> Array[LNode] {
  test_graph_creator_copy_array(
    self.graph.get_layers()[layer_index].get_nodes(),
  )
}

///|
pub fn GreedySwitchTestGraphCreator::copy_of_switch_order_of_nodes_in_layer(
  self : GreedySwitchTestGraphCreator,
  node_one : Int,
  node_two : Int,
  layer_index : Int,
) -> Array[LNode] {
  let layer = self.copy_of_nodes_in_layer(layer_index)
  self.get_copy_with_switched_order(node_one, node_two, layer)
}

///|
pub fn GreedySwitchTestGraphCreator::get_copy_with_switched_order(
  self : GreedySwitchTestGraphCreator,
  node_one : Int,
  node_two : Int,
  layer : Array[LNode],
) -> Array[LNode] {
  ignore(self)
  let switched = test_graph_creator_copy_array(layer)
  let first_node = switched[node_one]
  let second_node = switched[node_two]
  switched[node_one] = second_node
  switched[node_two] = first_node
  switched
}

///|
pub fn GreedySwitchTestGraphCreator::east_west_edges_from_to(
  self : GreedySwitchTestGraphCreator,
  number_of_nodes : Int,
  left : LNode,
  right : LNode,
) -> Unit {
  for _ in 0..<number_of_nodes {
    self.east_west_edge_from_to_nodes(left, right)
  }
}

///|
pub fn GreedySwitchTestGraphCreator::east_west_edge_from_to_port_node(
  self : GreedySwitchTestGraphCreator,
  left_port : LPort,
  right_node : LNode,
) -> Unit {
  self.add_edge_between_ports(
    left_port,
    self.add_port_on_side(right_node, @core.PortSide::West),
  )
}

///|
pub fn GreedySwitchTestGraphCreator::copy_ports_in_index_order(
  self : GreedySwitchTestGraphCreator,
  node : LNode,
  indices : Array[Int],
) -> Array[LPort] {
  ignore(self)
  let ports = node.get_ports()
  let copy = []
  for i in indices {
    copy.push(ports[i])
  }
  copy
}

///|
pub fn GreedySwitchTestGraphCreator::east_west_edge_from_to_node_port(
  self : GreedySwitchTestGraphCreator,
  left : LNode,
  right : LPort,
) -> Unit {
  self.add_edge_between_ports(
    self.add_port_on_side(left, @core.PortSide::East),
    right,
  )
}

///|
pub fn GreedySwitchTestGraphCreator::get_random(
  self : GreedySwitchTestGraphCreator,
) -> GreedySwitchMockRandom {
  self.random
}

///|
pub fn GreedySwitchTestGraphCreator::set_random(
  self : GreedySwitchTestGraphCreator,
  random : GreedySwitchMockRandom,
) -> Unit {
  self.random = random
}
