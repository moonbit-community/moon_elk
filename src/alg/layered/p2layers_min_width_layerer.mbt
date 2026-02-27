///|
let min_width_layerer_upperbound_on_width_range_lower = 1

///|
let min_width_layerer_upperbound_on_width_range_upper = 4

///|
let min_width_layerer_compensator_range_lower = 1

///|
let min_width_layerer_compensator_range_upper = 2

///|
let layered_options_layering_min_width_upper_bound_on_width : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.alg.layered.layering.minWidth.upperBoundOnWidth", 4,
)

///|
let layered_options_layering_min_width_upper_layer_estimation_scaling_factor : @graph.IProperty[
  Int,
] = @graph.new_property(
  "org.eclipse.elk.alg.layered.layering.minWidth.upperLayerEstimationScalingFactor",
  2,
)

///|
priv struct MinWidthLayererData {
  dummy_size : Double
  norm_size : Array[Double]
  avg_size : Double
  in_degree : Array[Int]
  out_degree : Array[Int]
}

///|
priv struct MinWidthLayererResult {
  max_width : Double
  layers : Array[Array[LNode]]
}

///|
fn min_width_layerer_layer_constraint_preprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn min_width_layerer_layer_constraint_postprocessor_factory() -> @core.ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let min_width_layerer_baseline_processing_configuration : @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = @core.layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    min_width_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    min_width_layerer_layer_constraint_postprocessor_factory(),
  )

///|
fn min_width_layerer_require_edge_target_node(edge : LEdge) -> LNode {
  let target = match edge.get_target() {
    Some(value) => value
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "edge has no target port",
      )
      return new_l_node()
    }
  }
  match target.get_node() {
    Some(value) => value
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "target port has no owner node",
      )
      new_l_node()
    }
  }
}

///|
fn min_width_layerer_count_edges_except_self_loops(edges : Array[LEdge]) -> Int {
  let mut count = 0
  for edge in edges {
    if !edge.is_self_loop() {
      count += 1
    }
  }
  count
}

///|
fn min_width_layerer_precalc_successors(
  nodes : Array[LNode],
) -> Array[Map[Int, Bool]] {
  let successors = []
  for node in nodes {
    let out_nodes : Map[Int, Bool] = {}
    for edge in node.get_outgoing_edges() {
      if edge.is_self_loop() {
        continue
      }
      let target = min_width_layerer_require_edge_target_node(edge)
      out_nodes[target.get_handle()] = true
    }
    successors.push(out_nodes)
  }
  successors
}

///|
fn min_width_layerer_sort_nodes_by_desc_out_degree(
  nodes : Array[LNode],
  out_degree : Array[Int],
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let current = nodes[i]
    let current_out = out_degree[current.get_id()]
    let mut j = i
    while j > 0 && out_degree[nodes[j - 1].get_id()] < current_out {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
    i += 1
  }
}

///|
fn min_width_layerer_targets_contain_all(
  targets : Map[Int, Bool],
  successors : Map[Int, Bool],
) -> Bool {
  for entry in successors.to_array() {
    if !targets.contains(entry.0) {
      return false
    }
  }
  true
}

///|
fn min_width_layerer_select_node(
  nodes : Array[LNode],
  successors : Array[Map[Int, Bool]],
  targets : Map[Int, Bool],
) -> LNode? {
  for node in nodes {
    if min_width_layerer_targets_contain_all(targets, successors[node.get_id()]) {
      return Some(node)
    }
  }
  None
}

///|
fn min_width_layerer_remove_unplaced_node(
  nodes : Array[LNode],
  node : LNode,
) -> Unit {
  let handle = node.get_handle()
  let mut i = 0
  while i < nodes.length() {
    if nodes[i].get_handle() == handle {
      ignore(nodes.remove(i))
      return
    }
    i += 1
  }
}

///|
fn min_width_layerer_compute_min_width_layering(
  upper_bound_on_width : Int,
  compensator : Int,
  nodes : Array[LNode],
  node_successors : Array[Map[Int, Bool]],
  data : MinWidthLayererData,
) -> MinWidthLayererResult {
  let layers = []
  let unplaced_nodes = nodes.copy()

  let ubw_consider_size = upper_bound_on_width.to_double() * data.avg_size

  let mut in_deg = 0
  let mut out_deg = 0

  let mut already_placed_in_current_layer : Map[Int, Bool] = {}
  let already_placed_in_other_layers : Map[Int, Bool] = {}

  let mut current_layer : Array[LNode] = []

  let mut width_current = 0.0
  let mut width_up = 0.0

  let mut max_width = 0.0
  let mut real_width = 0.0
  let mut current_spanning_edges = 0.0
  let mut going_out_from_this_layer = 0.0

  while !unplaced_nodes.is_empty() {
    let current_node = min_width_layerer_select_node(
      unplaced_nodes, node_successors, already_placed_in_other_layers,
    )

    match current_node {
      Some(node) => {
        min_width_layerer_remove_unplaced_node(unplaced_nodes, node)
        current_layer.push(node)
        already_placed_in_current_layer[node.get_handle()] = true

        out_deg = data.out_degree[node.get_id()]
        width_current += data.norm_size[node.get_id()] -
          out_deg.to_double() * data.dummy_size

        in_deg = data.in_degree[node.get_id()]
        width_up += in_deg.to_double() * data.dummy_size

        going_out_from_this_layer += out_deg.to_double() * data.dummy_size
        real_width += data.norm_size[node.get_id()]
      }
      None => ()
    }

    let mut should_go_up = false
    if current_node is None || unplaced_nodes.is_empty() {
      should_go_up = true
    } else if current_node is Some(node) {
      if width_current >= ubw_consider_size &&
        data.norm_size[node.get_id()] > out_deg.to_double() * data.dummy_size {
        should_go_up = true
      } else if width_up >= compensator.to_double() * ubw_consider_size {
        should_go_up = true
      }
    }

    if should_go_up {
      layers.push(current_layer)
      current_layer = []
      for entry in already_placed_in_current_layer.to_array() {
        already_placed_in_other_layers[entry.0] = true
      }
      already_placed_in_current_layer = {}

      current_spanning_edges -= going_out_from_this_layer
      let candidate_width = current_spanning_edges * data.dummy_size +
        real_width
      if candidate_width > max_width {
        max_width = candidate_width
      }
      current_spanning_edges += width_up

      width_current = width_up
      width_up = 0.0
      going_out_from_this_layer = 0.0
      real_width = 0.0
    }
  }

  { max_width, layers }
}

///|
fn min_width_layerer_reverse_layers(layers : Array[Layer]) -> Unit {
  if layers.length() < 2 {
    return
  }
  let mut left = 0
  let mut right = layers.length() - 1
  while left < right {
    let left_value = layers[left]
    let right_value = layers[right]
    layers[left] = right_value
    layers[right] = left_value
    left += 1
    right -= 1
  }
}

///|
fn min_width_layerer_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(min_width_layerer_baseline_processing_configuration)
}

///|
fn min_width_layerer_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("MinWidth layering", 1.0))

  let layers = layered_graph.get_layers()
  let not_inserted = layered_graph.get_layerless_nodes()

  let upper_bound_on_width = layered_graph.get_property_int(
    layered_options_layering_min_width_upper_bound_on_width,
  )
  let compensator = layered_graph.get_property_int(
    layered_options_layering_min_width_upper_layer_estimation_scaling_factor,
  )

  let mut minimum_node_size = @double.infinity
  for node in not_inserted {
    if node.get_type() is NodeType::Normal {
      let size = node.get_size().y
      if size < minimum_node_size {
        minimum_node_size = size
      }
    }
  }
  if minimum_node_size < 1.0 {
    minimum_node_size = 1.0
  }

  let num_of_nodes = not_inserted.length()
  let in_degree = Array::make(num_of_nodes, 0)
  let out_degree = Array::make(num_of_nodes, 0)
  let norm_size = Array::make(num_of_nodes, 0.0)
  let mut avg_size_sum = 0.0
  let mut i = 0
  for node in not_inserted {
    node.set_id(i)
    i += 1
    in_degree[node.get_id()] = min_width_layerer_count_edges_except_self_loops(
      node.get_incoming_edges(),
    )
    out_degree[node.get_id()] = min_width_layerer_count_edges_except_self_loops(
      node.get_outgoing_edges(),
    )
    norm_size[node.get_id()] = node.get_size().y / minimum_node_size
    avg_size_sum += norm_size[node.get_id()]
  }

  let dummy_size = layered_graph.get_property_double(@core.spacing_edge_edge) /
    minimum_node_size
  let avg_size = avg_size_sum / num_of_nodes.to_double()
  let data : MinWidthLayererData = {
    dummy_size,
    norm_size,
    avg_size,
    in_degree,
    out_degree,
  }

  let node_successors = min_width_layerer_precalc_successors(not_inserted)
  min_width_layerer_sort_nodes_by_desc_out_degree(not_inserted, data.out_degree)

  let mut min_width = @double.infinity
  let mut min_num_of_layers = @int.max_value
  let mut candidate_layering : Array[Array[LNode]]? = None

  let mut ubw_start = upper_bound_on_width
  let mut ubw_end = upper_bound_on_width
  let mut c_start = compensator
  let mut c_end = compensator

  if upper_bound_on_width < 0 {
    ubw_start = min_width_layerer_upperbound_on_width_range_lower
    ubw_end = min_width_layerer_upperbound_on_width_range_upper
  }
  if compensator < 0 {
    c_start = min_width_layerer_compensator_range_lower
    c_end = min_width_layerer_compensator_range_upper
  }

  let mut ubw = ubw_start
  while ubw <= ubw_end {
    let mut c = c_start
    while c <= c_end {
      let result = min_width_layerer_compute_min_width_layering(
        ubw, c, not_inserted, node_successors, data,
      )
      let new_width = result.max_width
      let new_num_of_layers = result.layers.length()
      if new_width < min_width ||
        (new_width == min_width && new_num_of_layers < min_num_of_layers) {
        min_width = new_width
        min_num_of_layers = new_num_of_layers
        candidate_layering = Some(result.layers)
      }
      c += 1
    }
    ubw += 1
  }

  let chosen_layering = match candidate_layering {
    Some(value) => value
    None => []
  }
  for layer_list in chosen_layering {
    let current_layer = new_layer(layered_graph)
    for node in layer_list {
      node.set_layer(Some(current_layer))
    }
    layers.push(current_layer)
  }

  min_width_layerer_reverse_layers(layers)
  not_inserted.clear()
  monitor.done()
}

///|
pub fn new_min_width_layerer_layout_phase() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_phase(
    min_width_layerer_process, min_width_layerer_configuration,
  )
}
