///|
fn msd_cut_index_heuristic_guarantee_valid() -> Bool {
  false
}

///|
fn msd_cut_index_heuristic_get_cut_indexes(
  graph : LGraph,
  graph_stats : GraphStats,
) -> Array[Int] {
  let widths = graph_stats.get_widths()
  let heights = graph_stats.get_heights()

  let width_at_index = []
  width_at_index.push(widths[0])
  let mut total = widths[0]
  for i in 1..<widths.length() {
    width_at_index.push(width_at_index[i - 1] + widths[i])
    total = total + widths[i]
  }

  let cut_cnt = ard_cut_index_heuristic_get_chunk_count(graph_stats) - 1
  let freedom = graph.get_property_int(
    layered_options_wrapping_cutting_msd_freedom,
  )

  let mut best_max_scale = -@double.infinity
  let mut best_cuts : Array[Int] = []

  let mut lower = cut_cnt - freedom
  if lower < 0 {
    lower = 0
  }
  let mut upper = cut_cnt + freedom
  if upper > graph_stats.longest_path - 1 {
    upper = graph_stats.longest_path - 1
  }

  let mut m = lower
  while m <= upper {
    let row_sum = total / (m + 1).to_double()
    let mut sum_so_far = 0.0
    let mut index = 1
    let cuts = []

    let mut width = -@double.infinity
    let mut last_cut_width = 0.0
    let mut height = 0.0
    let mut row_height_max = heights[0]

    if m == 0 {
      width = total
      height = graph_stats.get_max_height()
    } else {
      while index < graph_stats.longest_path {
        if width_at_index[index - 1] - sum_so_far >= row_sum {
          cuts.push(index)

          let candidate_width = width_at_index[index - 1] - last_cut_width
          if candidate_width > width {
            width = candidate_width
          }
          height = height + row_height_max

          sum_so_far = sum_so_far + (width_at_index[index - 1] - sum_so_far)
          last_cut_width = width_at_index[index - 1]
          row_height_max = heights[index]
        }

        if heights[index] > row_height_max {
          row_height_max = heights[index]
        }
        index = index + 1
      }

      height = height + row_height_max
    }

    let width_scale = 1.0 / width
    let height_scale = 1.0 / graph_stats.dar / height
    let max_scale = if width_scale < height_scale {
      width_scale
    } else {
      height_scale
    }

    if max_scale > best_max_scale {
      best_max_scale = max_scale
      best_cuts = cuts
    }

    m = m + 1
  }

  best_cuts
}

///|
pub fn new_msd_cut_index_heuristic() -> ICutIndexCalculator {
  new_i_cut_index_calculator(
    msd_cut_index_heuristic_get_cut_indexes, msd_cut_index_heuristic_guarantee_valid,
  )
}
