///|
fn breaking_point_inserter_cutting_strategy_from_string(
  value : String,
) -> CuttingStrategy {
  match value {
    "MANUAL" => CuttingStrategy::Manual
    "ARD" => CuttingStrategy::Ard
    _ => CuttingStrategy::Msd
  }
}

///|
fn breaking_point_inserter_validify_strategy_from_string(
  value : String,
) -> ValidifyStrategy {
  match value {
    "LOOK_BACK" => ValidifyStrategy::LookBack
    "GREEDY" => ValidifyStrategy::Greedy
    _ => ValidifyStrategy::No
  }
}

///|
fn breaking_point_inserter_require_edge_source(edge : LEdge) -> LPort {
  match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
}

///|
fn breaking_point_inserter_require_edge_target(edge : LEdge) -> LPort {
  match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
}

///|
fn breaking_point_inserter_require_port_node(port : LPort) -> LNode {
  match port.get_node() {
    Some(value) => value
    None => abort("port has no owner node")
  }
}

///|
fn breaking_point_inserter_port_side(value : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == value {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn breaking_point_inserter_node_type_is_breaking_point(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
fn breaking_point_inserter_contains_edge(
  edges : Array[LEdge],
  edge : LEdge,
) -> Bool {
  let handle = edge.get_handle()
  for item in edges {
    if item.get_handle() == handle {
      return true
    }
  }
  false
}

///|
fn breaking_point_inserter_add_open_edge(
  open_edges : Array[LEdge],
  edge : LEdge,
) -> Unit {
  if !breaking_point_inserter_contains_edge(open_edges, edge) {
    open_edges.push(edge)
  }
}

///|
fn breaking_point_inserter_remove_open_edge(
  open_edges : Array[LEdge],
  edge : LEdge,
) -> Unit {
  let handle = edge.get_handle()
  for i in 0..<open_edges.length() {
    if open_edges[i].get_handle() == handle {
      ignore(open_edges.remove(i))
      return
    }
  }
}

///|
fn breaking_point_inserter_compute_score(
  graph : LGraph,
  index : Int,
  spans : Int,
  dist : Int,
) -> Double {
  ignore(index)
  let distance_penalty = graph.get_property_double(
    layered_options_wrapping_multi_edge_distance_penalty,
  )
  spans.to_double() + @math.pow(dist.to_double(), distance_penalty)
}

///|
fn breaking_point_inserter_compute_edge_spans(graph : LGraph) -> Array[Int] {
  let spans = []
  let open : Map[Int, Bool] = {}
  let mut open_count = 0

  for layer in graph.get_layers() {
    spans.push(open_count)

    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        let handle = edge.get_handle()
        if !open.contains(handle) {
          open[handle] = true
          open_count = open_count + 1
        }
      }
    }

    for node in layer.get_nodes() {
      for edge in node.get_incoming_edges() {
        let handle = edge.get_handle()
        if open.contains(handle) {
          ignore(open.remove(handle))
          open_count = open_count - 1
        }
      }
    }
  }

  spans
}

///|
pub struct BreakingPointInserterCut {
  mut index : Int
  mut new_index : Int
  mut prev : BreakingPointInserterCut?
  mut suc : BreakingPointInserterCut?
  mut assigned : Bool
}

///|
fn new_breaking_point_inserter_cut(index : Int) -> BreakingPointInserterCut {
  { index, new_index: index, prev: None, suc: None, assigned: false }
}

///|
fn breaking_point_inserter_cut_self_or_next(
  cut : BreakingPointInserterCut?,
) -> BreakingPointInserterCut? {
  match cut {
    Some(value) =>
      if !value.assigned {
        Some(value)
      } else {
        breaking_point_inserter_cut_self_or_next(value.suc)
      }
    None => None
  }
}

///|
fn breaking_point_inserter_cut_next(
  cut : BreakingPointInserterCut,
) -> BreakingPointInserterCut? {
  breaking_point_inserter_cut_self_or_next(cut.suc)
}

///|
fn breaking_point_inserter_cut_offset(
  cut : BreakingPointInserterCut,
  offset : Int,
) -> Unit {
  cut.index = cut.index + offset
}

///|
fn breaking_point_inserter_cut_offset_prev(
  cut : BreakingPointInserterCut,
  offset : Int,
) -> Unit {
  match cut.prev {
    Some(prev) =>
      if !prev.assigned {
        breaking_point_inserter_cut_offset(prev, offset)
        breaking_point_inserter_cut_offset_prev(prev, offset)
      }
    None => ()
  }
}

///|
fn breaking_point_inserter_cut_offset_suc(
  cut : BreakingPointInserterCut,
  offset : Int,
) -> Unit {
  match cut.suc {
    Some(suc) =>
      if !suc.assigned {
        breaking_point_inserter_cut_offset(suc, offset)
        breaking_point_inserter_cut_offset_suc(suc, offset)
      }
    None => ()
  }
}

///|
fn breaking_point_inserter_cut_apply_offset(
  cut : BreakingPointInserterCut,
) -> Unit {
  if !cut.assigned {
    abort("Cannot offset an unassigned cut.")
  }
  let offset = cut.new_index - cut.index
  breaking_point_inserter_cut_offset(cut, offset)
  breaking_point_inserter_cut_offset_prev(cut, offset)
  breaking_point_inserter_cut_offset_suc(cut, offset)
}

///|
fn breaking_point_inserter_improve_cuts(
  graph : LGraph,
  cuts : Array[Int],
) -> Array[Int] {
  let improved_cuts = []

  let ccuts = []
  let mut last_cut : BreakingPointInserterCut? = None
  for cut_idx in cuts {
    let cut = new_breaking_point_inserter_cut(cut_idx)
    ccuts.push(cut)
    match last_cut {
      Some(last) => {
        cut.prev = Some(last)
        last.suc = Some(cut)
      }
      None => ()
    }
    last_cut = Some(cut)
  }

  let spans = breaking_point_inserter_compute_edge_spans(graph)

  let mut i = 0
  while i < ccuts.length() {
    let mut l_cut : BreakingPointInserterCut? = None
    let mut r_cut = breaking_point_inserter_cut_self_or_next(Some(ccuts[0]))

    let mut best_cut : BreakingPointInserterCut? = None
    let mut best_score = @double.infinity

    let mut idx = 1
    while idx < graph.get_layers().length() {
      let mut hit : BreakingPointInserterCut? = None
      let r_dist = match r_cut {
        Some(r_value) => (r_value.index - idx).abs()
        None =>
          match l_cut {
            Some(l_value) => (idx - l_value.index).abs() + 1
            None => @int.max_value / 2
          }
      }
      let l_dist = match l_cut {
        Some(l_value) => (idx - l_value.index).abs()
        None => r_dist + 1
      }

      let dist = if l_dist < r_dist {
        hit = l_cut
        l_dist
      } else {
        hit = r_cut
        r_dist
      }

      let score = breaking_point_inserter_compute_score(
        graph,
        idx,
        spans[idx],
        dist,
      )
      if score < best_score {
        best_score = score
        best_cut = hit
        match best_cut {
          Some(value) => value.new_index = idx
          None => ()
        }
      }

      match r_cut {
        Some(r_value) =>
          if idx == r_value.index {
            l_cut = Some(r_value)
            r_cut = breaking_point_inserter_cut_next(r_value)
          }
        None => ()
      }

      idx = idx + 1
    }

    match best_cut {
      Some(value) => {
        improved_cuts.push(value.new_index)
        value.assigned = true
        breaking_point_inserter_cut_apply_offset(value)
      }
      None => ()
    }

    i = i + 1
  }

  improved_cuts.sort()
  improved_cuts
}

///|
fn breaking_point_inserter_apply_cuts(graph : LGraph, cuts : Array[Int]) -> Int {
  if cuts.is_empty() {
    return 0
  }

  let layers = graph.get_layers()
  let original_layers = layers.copy()

  let mut idx = 0
  let mut cut_idx = 0
  let mut cut = cuts[cut_idx]
  let mut no_split_edges = 0

  let already_split : Map[Int, Bool] = {}
  let open_edges = []

  for layer in original_layers {
    for node in layer.get_nodes() {
      for edge in node.get_outgoing_edges() {
        breaking_point_inserter_add_open_edge(open_edges, edge)
      }
      for edge in node.get_incoming_edges() {
        breaking_point_inserter_remove_open_edge(open_edges, edge)
      }
    }

    if idx + 1 == cut {
      let bp_layer_1 = new_layer(graph)
      let bp_layer_2 = new_layer(graph)
      let layer_index = layer.get_index()
      if layer_index < 0 {
        abort("layer to cut is detached from graph")
      }
      ignore(layers.insert(layer_index + 1, bp_layer_1))
      ignore(layers.insert(layer_index + 2, bp_layer_2))

      for original_edge in open_edges.copy() {
        let original_handle = original_edge.get_handle()
        if !already_split.contains(original_handle) {
          no_split_edges = no_split_edges + 1
          already_split[original_handle] = true
        }

        let bp_start_marker = new_l_node(graph=Some(graph))
        bp_start_marker.set_property_string(port_constraints, "FIXED_SIDE")
        bp_start_marker.set_layer(Some(bp_layer_1))
        bp_start_marker.set_type(NodeType::BreakingPoint)
        let in_port_bp_1 = new_l_port()
        in_port_bp_1.set_node(Some(bp_start_marker))
        in_port_bp_1.set_side(breaking_point_inserter_port_side("WEST"))
        let out_port_bp_1 = new_l_port()
        out_port_bp_1.set_node(Some(bp_start_marker))
        out_port_bp_1.set_side(breaking_point_inserter_port_side("EAST"))

        let bp_end_marker = new_l_node(graph=Some(graph))
        bp_end_marker.set_property_string(port_constraints, "FIXED_SIDE")
        bp_end_marker.set_layer(Some(bp_layer_2))
        bp_end_marker.set_type(NodeType::BreakingPoint)
        let in_port_bp_2 = new_l_port()
        in_port_bp_2.set_node(Some(bp_end_marker))
        in_port_bp_2.set_side(breaking_point_inserter_port_side("WEST"))
        let out_port_bp_2 = new_l_port()
        out_port_bp_2.set_node(Some(bp_end_marker))
        out_port_bp_2.set_side(breaking_point_inserter_port_side("EAST"))

        let node_start_edge = new_l_edge()
        node_start_edge.set_source(original_edge.get_source())
        node_start_edge.set_target(Some(in_port_bp_1))
        node_start_edge.set_property_int(
          internal_properties_model_order,
          original_edge.get_property_int(internal_properties_model_order),
        )

        let start_end_edge = new_l_edge()
        start_end_edge.set_source(Some(out_port_bp_1))
        start_end_edge.set_target(Some(in_port_bp_2))
        start_end_edge.set_property_int(
          internal_properties_model_order,
          original_edge.get_property_int(internal_properties_model_order),
        )

        original_edge.set_source(Some(out_port_bp_2))

        let bp_info = new_bp_info(
          bp_start_marker, bp_end_marker, node_start_edge, start_end_edge, original_edge,
        )
        bp_start_marker.set_property_bp_info(
          internal_properties_breaking_point_info,
          Some(bp_info),
        )
        bp_end_marker.set_property_bp_info(
          internal_properties_breaking_point_info,
          Some(bp_info),
        )

        let prev_node = breaking_point_inserter_require_port_node(
          breaking_point_inserter_require_edge_source(node_start_edge),
        )
        if breaking_point_inserter_node_type_is_breaking_point(
            prev_node.get_type(),
          ) {
          match
            prev_node.get_property_bp_info(
              internal_properties_breaking_point_info,
            ) {
            Some(prev_info) => {
              prev_info.set_next(Some(bp_info))
              bp_info.set_prev(Some(prev_info))
            }
            None => ()
          }
        }
      }

      cut_idx = cut_idx + 1
      if cut_idx < cuts.length() {
        cut = cuts[cut_idx]
      } else {
        break
      }
    }

    idx = idx + 1
  }

  no_split_edges
}

///|
fn breaking_point_inserter_process(
  graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Breaking Point Insertion", 1.0))

  let graph_stats = new_graph_stats(graph)

  let cutting_strategy = breaking_point_inserter_cutting_strategy_from_string(
    graph.get_property_string(layered_options_wrapping_cutting_strategy),
  )
  let calculator = match cutting_strategy {
    CuttingStrategy::Manual => new_manual_cut_index_calculator()
    CuttingStrategy::Ard => new_ard_cut_index_heuristic()
    _ => new_msd_cut_index_heuristic()
  }

  let mut cuts = calculator.get_cut_indexes(graph, graph_stats)

  if graph.get_property_bool(layered_options_wrapping_multi_edge_improve_cuts) {
    cuts = breaking_point_inserter_improve_cuts(graph, cuts)
  }

  if !calculator.guarantee_valid() &&
    graph.has_property_string(layered_options_wrapping_validify_strategy) {
    let validify_strategy = breaking_point_inserter_validify_strategy_from_string(
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

  if cuts.is_empty() {
    monitor.done()
    return
  }

  ignore(breaking_point_inserter_apply_cuts(graph, cuts))

  monitor.done()
}

///|
pub fn new_breaking_point_inserter_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(breaking_point_inserter_process)
}
