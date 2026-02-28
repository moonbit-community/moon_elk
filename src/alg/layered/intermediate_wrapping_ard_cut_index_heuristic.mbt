///|
fn ard_cut_index_heuristic_get_cut_indexes(
  graph : LGraph,
  graph_stats : GraphStats,
) -> Array[Int] {
  ignore(graph)

  let rows = ard_cut_index_heuristic_get_chunk_count(graph_stats)
  let cuts = []
  let step = graph_stats.longest_path.to_double() / rows.to_double()
  for idx in 1..<rows {
    cuts.push((idx.to_double() * step).round().to_int())
  }
  cuts
}

///|
fn ard_cut_index_heuristic_guarantee_valid() -> Bool {
  false
}

///|
pub fn ard_cut_index_heuristic_get_chunk_count(graph_stats : GraphStats) -> Int {
  let rows_double = (graph_stats.get_sum_width() /
  (graph_stats.dar * graph_stats.get_max_height())).sqrt()
  let mut rows = rows_double.round().to_int()
  if rows > graph_stats.longest_path {
    rows = graph_stats.longest_path
  }
  rows
}

///|
pub fn new_ard_cut_index_heuristic() -> ICutIndexCalculator {
  new_i_cut_index_calculator(
    ard_cut_index_heuristic_get_cut_indexes, ard_cut_index_heuristic_guarantee_valid,
  )
}
