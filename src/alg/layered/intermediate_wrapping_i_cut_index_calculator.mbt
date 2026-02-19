///|
pub struct ICutIndexCalculator {
  get_cut_indexes : (LGraph, GraphStats) -> Array[Int]
  guarantee_valid : () -> Bool
}

///|
pub fn new_i_cut_index_calculator(
  get_cut_indexes : (LGraph, GraphStats) -> Array[Int],
  guarantee_valid : () -> Bool,
) -> ICutIndexCalculator {
  { get_cut_indexes, guarantee_valid }
}

///|
pub fn ICutIndexCalculator::get_cut_indexes(
  self : ICutIndexCalculator,
  graph : LGraph,
  graph_stats : GraphStats,
) -> Array[Int] {
  (self.get_cut_indexes)(graph, graph_stats)
}

///|
pub fn ICutIndexCalculator::guarantee_valid(self : ICutIndexCalculator) -> Bool {
  (self.guarantee_valid)()
}

///|
fn manual_cut_index_calculator_get_cut_indexes(
  graph : LGraph,
  graph_stats : GraphStats,
) -> Array[Int] {
  ignore(graph_stats)
  if graph.has_property_string(layered_options_wrapping_cutting_cuts) {
    layered_options_parse_int_list(
      graph.get_property_string(layered_options_wrapping_cutting_cuts),
    )
  } else {
    []
  }
}

///|
fn manual_cut_index_calculator_guarantee_valid() -> Bool {
  false
}

///|
pub fn new_manual_cut_index_calculator() -> ICutIndexCalculator {
  new_i_cut_index_calculator(
    manual_cut_index_calculator_get_cut_indexes, manual_cut_index_calculator_guarantee_valid,
  )
}
