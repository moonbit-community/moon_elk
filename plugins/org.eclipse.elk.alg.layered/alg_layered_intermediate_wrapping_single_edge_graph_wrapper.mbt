///|
fn single_edge_graph_wrapper_cutting_strategy_from_string(
  value : String,
) -> CuttingStrategy {
  match value {
    "MANUAL" => CuttingStrategy::Manual
    "ARD" => CuttingStrategy::Ard
    _ => CuttingStrategy::Msd
  }
}

///|
fn single_edge_graph_wrapper_validify_strategy_from_string(
  value : String,
) -> ValidifyStrategy {
  match value {
    "LOOK_BACK" => ValidifyStrategy::LookBack
    "GREEDY" => ValidifyStrategy::Greedy
    _ => ValidifyStrategy::No
  }
}

///|
fn single_edge_graph_wrapper_reverse_edge(edge : LEdge) -> Unit {
  let old_source = edge.get_source()
  let old_target = edge.get_target()
  edge.set_source(None)
  edge.set_target(None)
  edge.set_source(old_target)
  edge.set_target(old_source)
  edge.set_property_bool(
    internal_properties_reversed,
    !edge.get_property_bool(internal_properties_reversed),
  )
}

///|
fn single_edge_graph_wrapper_validify_indexes_looking_back_internal(
  desired_cuts : Array[Int],
  valid_cuts : Array[Int],
) -> Array[Int] {
  let final_cuts = []
  let mut valid_idx = 0
  let mut cut_idx = 0
  let mut offset = 0

  while valid_idx < valid_cuts.length() - 1 && cut_idx < desired_cuts.length() {
    let current = desired_cuts[cut_idx] + offset

    while valid_cuts[valid_idx + 1] < current {
      valid_idx = valid_idx + 1
    }

    let mut select = 0
    let dist_lower = current - valid_cuts[valid_idx]
    let dist_higher = valid_cuts[valid_idx + 1] - current
    if dist_lower > dist_higher {
      select = 1
    }

    final_cuts.push(valid_cuts[valid_idx + select])
    offset = offset + valid_cuts[valid_idx + select] - current
    cut_idx = cut_idx + 1

    while cut_idx < desired_cuts.length() &&
          desired_cuts[cut_idx] + offset <= valid_cuts[valid_idx + select] {
      cut_idx = cut_idx + 1
    }
    valid_idx = valid_idx + 1 + select
  }

  final_cuts
}

///|
pub fn single_edge_graph_wrapper_validify_indexes_greedily(
  graph_stats : GraphStats,
  cuts : Array[Int],
) -> Array[Int] {
  let valid_cuts = []
  let mut offset = 0
  for item in cuts {
    let mut cut = item + offset
    while cut < graph_stats.longest_path && !graph_stats.is_cut_allowed(cut) {
      cut = cut + 1
      offset = offset + 1
    }
    if cut >= graph_stats.longest_path {
      break
    }
    valid_cuts.push(cut)
  }
  valid_cuts
}

///|
pub fn single_edge_graph_wrapper_validify_indexes_looking_back(
  graph_stats : GraphStats,
  desired_cuts : Array[Int],
) -> Array[Int] {
  if desired_cuts.is_empty() {
    return []
  }

  let valid_cuts = [@int.min_value]
  for i in 1..<graph_stats.longest_path {
    if graph_stats.is_cut_allowed(i) {
      valid_cuts.push(i)
    }
  }
  if valid_cuts.length() == 1 {
    return []
  }
  valid_cuts.push(@int.max_value)

  single_edge_graph_wrapper_validify_indexes_looking_back_internal(
    desired_cuts, valid_cuts,
  )
}

///|
fn single_edge_graph_wrapper_perform_cuts(
  graph : LGraph,
  graph_stats : GraphStats,
  cuts : Array[Int],
) -> Unit {
  if cuts.is_empty() {
    return
  }

  let mut index = 0
  let mut new_index = 0
  let mut cut_idx = 0
  let mut next_cut = cuts[cut_idx]

  while index < graph_stats.longest_path {
    if index == next_cut {
      new_index = 0
      cut_idx = cut_idx + 1
      if cut_idx < cuts.length() {
        next_cut = cuts[cut_idx]
      } else {
        next_cut = graph_stats.longest_path + 1
      }
    }

    if index != new_index {
      let old_layer = graph.get_layers()[index]
      let new_layer = graph.get_layers()[new_index]
      let nodes_to_move = old_layer.get_nodes().copy()
      for node in nodes_to_move {
        node.set_layer(Some(new_layer))
        if new_index == 0 {
          let incoming_edges = node.get_incoming_edges().copy()
          for edge in incoming_edges {
            single_edge_graph_wrapper_reverse_edge(edge)
            graph.set_property_bool(internal_properties_cyclic, true)
            ignore(cutting_utils_insert_dummies(graph, edge, 1))
          }
        }
      }
    }

    new_index = new_index + 1
    index = index + 1
  }

  let layers = graph.get_layers()
  let mut i = 0
  while i < layers.length() {
    if layers[i].get_nodes().is_empty() {
      ignore(layers.remove(i))
    } else {
      i = i + 1
    }
  }
}

///|
fn single_edge_graph_wrapper_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Path-Like Graph Wrapping", 1.0))

  if graph.get_layers().is_empty() {
    monitor.done()
    return
  }

  let graph_stats = new_graph_stats(graph)

  let sum_width = graph_stats.get_max_width() *
    graph_stats.longest_path.to_double()
  let current_ar = sum_width / graph_stats.get_max_width()
  if graph_stats.dar > current_ar {
    monitor.done()
    return
  }

  let cutting_strategy = single_edge_graph_wrapper_cutting_strategy_from_string(
    graph.get_property_string(layered_options_wrapping_cutting_strategy),
  )
  let calculator = match cutting_strategy {
    CuttingStrategy::Manual => new_manual_cut_index_calculator()
    CuttingStrategy::Ard => new_ard_cut_index_heuristic()
    _ => new_msd_cut_index_heuristic()
  }

  let mut cuts = calculator.get_cut_indexes(graph, graph_stats)

  if !calculator.guarantee_valid() {
    let validify_strategy = single_edge_graph_wrapper_validify_strategy_from_string(
      graph.get_property_string(layered_options_wrapping_validify_strategy),
    )
    match validify_strategy {
      ValidifyStrategy::LookBack =>
        cuts = single_edge_graph_wrapper_validify_indexes_looking_back(
          graph_stats, cuts,
        )
      ValidifyStrategy::Greedy =>
        cuts = single_edge_graph_wrapper_validify_indexes_greedily(
          graph_stats, cuts,
        )
      _ => ()
    }
  }

  single_edge_graph_wrapper_perform_cuts(graph, graph_stats, cuts)

  monitor.done()
}

///|
pub fn new_single_edge_graph_wrapper_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(single_edge_graph_wrapper_process)
}
