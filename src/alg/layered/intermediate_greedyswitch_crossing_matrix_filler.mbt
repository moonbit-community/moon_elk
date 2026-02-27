///|
fn crossing_matrix_new_bool_matrix(size : Int) -> Array[Array[Bool]] {
  let matrix = []
  for _ in 0..<size {
    matrix.push(Array::make(size, false))
  }
  matrix
}

///|
fn crossing_matrix_new_int_matrix(size : Int) -> Array[Array[Int]] {
  let matrix = []
  for _ in 0..<size {
    matrix.push(Array::make(size, 0))
  }
  matrix
}

///|
fn crossing_matrix_is_one_sided(switch_type : GreedySwitchType) -> Bool {
  match switch_type {
    GreedySwitchType::OneSided => true
    _ => false
  }
}

///|
pub enum CrossingCountSide {
  West
  East
}

///|
pub fn crossing_count_side_values() -> Array[CrossingCountSide] {
  [CrossingCountSide::West, CrossingCountSide::East]
}

///|
pub struct CrossingMatrixFiller {
  is_crossing_matrix_filled : Array[Array[Bool]]
  crossing_matrix : Array[Array[Int]]
  in_between_layer_crossing_counter : BetweenLayerEdgeTwoNodeCrossingsCounter
  direction : CrossingCountSide
  one_sided : Bool
}

///|
pub fn new_crossing_matrix_filler(
  greedy_switch_type : GreedySwitchType,
  graph : Array[Array[LNode]],
  free_layer_index : Int,
  direction : CrossingCountSide,
) -> CrossingMatrixFiller {
  let effective_free_layer_index = if free_layer_index < 0 ||
    free_layer_index >= graph.length() {
    @core.layout_runtime_report_unsupported_configuration(
      "crossing matrix filler free layer index is out of range",
    )
    if graph.is_empty() {
      0
    } else {
      graph.length() - 1
    }
  } else {
    free_layer_index
  }

  let free_layer = if graph.is_empty() {
    []
  } else {
    graph[effective_free_layer_index]
  }
  let layer_size = free_layer.length()
  {
    direction,
    one_sided: crossing_matrix_is_one_sided(greedy_switch_type),
    is_crossing_matrix_filled: crossing_matrix_new_bool_matrix(layer_size),
    crossing_matrix: crossing_matrix_new_int_matrix(layer_size),
    in_between_layer_crossing_counter: new_between_layer_edge_two_node_crossings_counter(
      graph, effective_free_layer_index,
    ),
  }
}

///|
pub fn CrossingMatrixFiller::get_crossing_matrix_entry(
  self : CrossingMatrixFiller,
  upper_node : LNode,
  lower_node : LNode,
) -> Int {
  let upper_id = upper_node.get_id()
  let lower_id = lower_node.get_id()
  if !self.is_crossing_matrix_filled[upper_id][lower_id] {
    self.fill_crossing_matrix(upper_node, lower_node)
    self.is_crossing_matrix_filled[upper_id][lower_id] = true
    self.is_crossing_matrix_filled[lower_id][upper_id] = true
  }
  self.crossing_matrix[upper_id][lower_id]
}

///|
fn CrossingMatrixFiller::fill_crossing_matrix(
  self : CrossingMatrixFiller,
  upper_node : LNode,
  lower_node : LNode,
) -> Unit {
  if self.one_sided {
    match self.direction {
      CrossingCountSide::East =>
        self.in_between_layer_crossing_counter.count_eastern_edge_crossings(
          upper_node, lower_node,
        )
      CrossingCountSide::West =>
        self.in_between_layer_crossing_counter.count_western_edge_crossings(
          upper_node, lower_node,
        )
    }
  } else {
    self.in_between_layer_crossing_counter.count_both_side_crossings(
      upper_node, lower_node,
    )
  }

  let upper_id = upper_node.get_id()
  let lower_id = lower_node.get_id()
  self.crossing_matrix[upper_id][lower_id] = self.in_between_layer_crossing_counter.get_upper_lower_crossings()
  self.crossing_matrix[lower_id][upper_id] = self.in_between_layer_crossing_counter.get_lower_upper_crossings()
}
