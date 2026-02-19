///|
priv struct StretchWidthLayererState {
  mut width_current : Double
  mut width_up : Double
  mut max_width : Double
  current_graph : LGraph
  mut upper_layer_influence : Double
  mut sorted_layerless_nodes : Array[LNode]
  mut already_placed_nodes : Map[Int, Bool]
  mut already_placed_in_other_layers : Map[Int, Bool]
  mut temp_layerless_nodes : Array[LNode]
  mut successors : Array[Map[Int, Bool]]
  mut out_degree : Array[Int]
  mut remaining_out_going : Array[Int]
  mut in_degree : Array[Int]
  mut selected_node : LNode?
  mut minimum_node_size : Double
  mut maximum_node_size : Double
  mut norm_size : Array[Double]
  mut dummy_size : Double
}

///|
fn stretch_width_layerer_layer_constraint_preprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23007, 7, () => {
    new_layer_constraint_preprocessor_layout_processor()
  })
}

///|
fn stretch_width_layerer_layer_constraint_postprocessor_factory() -> ILayoutProcessorFactory[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor_factory(23011, 11, () => {
    new_layer_constraint_postprocessor_layout_processor()
  })
}

///|
let stretch_width_layerer_baseline_processing_configuration : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EdgeAndLayerConstraintEdgeReverser,
    ),
  )
  .add_before(
    LayeredPhases::P2Layering,
    stretch_width_layerer_layer_constraint_preprocessor_factory(),
  )
  .add_before(
    LayeredPhases::P3NodeOrdering,
    stretch_width_layerer_layer_constraint_postprocessor_factory(),
  )

///|
fn stretch_width_layerer_new_state(
  layered_graph : LGraph,
) -> StretchWidthLayererState {
  {
    width_current: 0.0,
    width_up: 0.0,
    max_width: 0.0,
    current_graph: layered_graph,
    upper_layer_influence: 0.0,
    sorted_layerless_nodes: [],
    already_placed_nodes: {},
    already_placed_in_other_layers: {},
    temp_layerless_nodes: [],
    successors: [],
    out_degree: [],
    remaining_out_going: [],
    in_degree: [],
    selected_node: None,
    minimum_node_size: @double.infinity,
    maximum_node_size: -@double.infinity,
    norm_size: [],
    dummy_size: 0.0,
  }
}

///|
fn stretch_width_layerer_require_edge_source_node(edge : LEdge) -> LNode {
  let source = match edge.get_source() {
    Some(value) => value
    None => abort("edge has no source port")
  }
  match source.get_node() {
    Some(value) => value
    None => abort("source port has no owner node")
  }
}

///|
fn stretch_width_layerer_require_edge_target_node(edge : LEdge) -> LNode {
  let target = match edge.get_target() {
    Some(value) => value
    None => abort("edge has no target port")
  }
  match target.get_node() {
    Some(value) => value
    None => abort("target port has no owner node")
  }
}

///|
fn stretch_width_layerer_sort_descending_by_node_id(
  nodes : Array[LNode],
) -> Unit {
  let mut i = 1
  while i < nodes.length() {
    let current = nodes[i]
    let current_id = current.get_id()
    let mut j = i
    while j > 0 && nodes[j - 1].get_id() < current_id {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
    i += 1
  }
}

///|
fn stretch_width_layerer_get_rank(node : LNode) -> Int {
  let mut max_rank = node.get_outgoing_edges().length()
  for pre_edge in node.get_incoming_edges() {
    let pre = stretch_width_layerer_require_edge_source_node(pre_edge)
    let temp = pre.get_outgoing_edges().length()
    if temp > max_rank {
      max_rank = temp
    }
  }
  max_rank
}

///|
fn stretch_width_layerer_compute_sorted_nodes(
  state : StretchWidthLayererState,
) -> Unit {
  let unsorted_nodes = state.current_graph.get_layerless_nodes()
  state.sorted_layerless_nodes = unsorted_nodes.copy()
  for node in unsorted_nodes {
    node.set_id(stretch_width_layerer_get_rank(node))
  }
  stretch_width_layerer_sort_descending_by_node_id(state.sorted_layerless_nodes)
}

///|
fn stretch_width_layerer_compute_successors(
  state : StretchWidthLayererState,
) -> Unit {
  let successors = []
  let mut i = 0
  for node in state.sorted_layerless_nodes {
    node.set_id(i)
    let curr_succ : Map[Int, Bool] = {}
    for edge in node.get_outgoing_edges() {
      let target = stretch_width_layerer_require_edge_target_node(edge)
      curr_succ[target.get_handle()] = true
    }
    ignore(curr_succ.remove(node.get_handle()))
    successors.push(curr_succ)
    i += 1
  }
  state.successors = successors
}

///|
fn stretch_width_layerer_compute_degrees(
  state : StretchWidthLayererState,
) -> Unit {
  let length = state.sorted_layerless_nodes.length()
  state.in_degree = Array::make(length, 0)
  state.out_degree = Array::make(length, 0)
  for node in state.sorted_layerless_nodes {
    state.in_degree[node.get_id()] = node.get_incoming_edges().length()
    state.out_degree[node.get_id()] = node.get_outgoing_edges().length()
  }
}

///|
fn stretch_width_layerer_min_max_node_size(
  state : StretchWidthLayererState,
) -> Unit {
  for node in state.sorted_layerless_nodes {
    if node.get_type() is NodeType::Normal {
      let size = node.get_size().y
      if size < state.minimum_node_size {
        state.minimum_node_size = size
      }
      if size > state.maximum_node_size {
        state.maximum_node_size = size
      }
    }
  }
}

///|
fn stretch_width_layerer_compute_normalized_size(
  state : StretchWidthLayererState,
) -> Unit {
  state.norm_size = Array::make(state.sorted_layerless_nodes.length(), 0.0)
  for node in state.sorted_layerless_nodes {
    state.norm_size[node.get_id()] = node.get_size().y / state.minimum_node_size
  }
}

///|
fn stretch_width_layerer_get_average_out_degree(
  state : StretchWidthLayererState,
) -> Double {
  let nodes = state.current_graph.get_layerless_nodes()
  let mut all_out = 0.0
  for node in nodes {
    all_out += node.get_outgoing_edges().length().to_double()
  }
  all_out / nodes.length().to_double()
}

///|
fn stretch_width_layerer_condition_go_up(
  state : StretchWidthLayererState,
) -> Bool {
  let selected = match state.selected_node {
    Some(value) => value
    None => abort("selected node is required")
  }
  let selected_id = selected.get_id()
  let a = state.width_current -
    state.out_degree[selected_id].to_double() * state.dummy_size +
    state.norm_size[selected_id] >
    state.max_width
  let b = state.width_up +
    state.in_degree[selected_id].to_double() * state.dummy_size >
    state.max_width * state.upper_layer_influence * state.dummy_size
  a || b
}

///|
fn stretch_width_layerer_select_node(
  state : StretchWidthLayererState,
) -> LNode? {
  for node in state.temp_layerless_nodes {
    if state.remaining_out_going[node.get_id()] <= 0 {
      return Some(node)
    }
  }
  None
}

///|
fn stretch_width_layerer_update_out_going(
  state : StretchWidthLayererState,
  current_layer : Layer,
) -> Unit {
  for node in current_layer.get_nodes() {
    for edge in node.get_incoming_edges() {
      let pos = stretch_width_layerer_require_edge_source_node(edge).get_id()
      state.remaining_out_going[pos] -= 1
    }
  }
}

///|
fn stretch_width_layerer_remove_temp_node(
  state : StretchWidthLayererState,
  selected : LNode,
) -> Unit {
  let handle = selected.get_handle()
  let mut i = 0
  while i < state.temp_layerless_nodes.length() {
    if state.temp_layerless_nodes[i].get_handle() == handle {
      ignore(state.temp_layerless_nodes.remove(i))
      return
    }
    i += 1
  }
}

///|
fn stretch_width_layerer_reverse_layers(layers : Array[Layer]) -> Unit {
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
fn stretch_width_layerer_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  Some(stretch_width_layerer_baseline_processing_configuration)
}

///|
fn stretch_width_layerer_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("StretchWidth layering", 1.0))

  if layered_graph.get_layerless_nodes().is_empty() {
    monitor.done()
    return
  }

  let state = stretch_width_layerer_new_state(layered_graph)
  state.dummy_size = layered_graph.get_property_double(spacing_edge_edge)

  stretch_width_layerer_compute_sorted_nodes(state)
  stretch_width_layerer_compute_successors(state)
  stretch_width_layerer_compute_degrees(state)
  stretch_width_layerer_min_max_node_size(state)
  stretch_width_layerer_compute_normalized_size(state)

  if state.minimum_node_size < 1.0 {
    state.minimum_node_size = 1.0
  }
  if state.maximum_node_size < 1.0 {
    state.maximum_node_size = 1.0
  }

  state.dummy_size /= state.minimum_node_size
  state.max_width = state.maximum_node_size / state.minimum_node_size
  state.upper_layer_influence = stretch_width_layerer_get_average_out_degree(
    state,
  )

  let mut current_layer = new_layer(state.current_graph)
  state.current_graph.get_layers().push(current_layer)

  state.temp_layerless_nodes = state.sorted_layerless_nodes.copy()
  state.remaining_out_going = state.out_degree.copy()

  while !state.temp_layerless_nodes.is_empty() {
    state.selected_node = stretch_width_layerer_select_node(state)
    let should_advance_layer = match state.selected_node {
      Some(_) =>
        stretch_width_layerer_condition_go_up(state) &&
        state.already_placed_nodes.length() > 0
      None => true
    }

    if should_advance_layer {
      stretch_width_layerer_update_out_going(state, current_layer)
      current_layer = new_layer(state.current_graph)
      state.current_graph.get_layers().push(current_layer)
      for entry in state.already_placed_nodes.to_array() {
        state.already_placed_in_other_layers[entry.0] = true
      }
      state.already_placed_nodes = {}
      state.width_current = state.width_up
      state.width_up = 0.0
    } else {
      let selected = match state.selected_node {
        Some(value) => value
        None => abort("selected node should not be null")
      }
      if stretch_width_layerer_condition_go_up(state) {
        state.current_graph.get_layers().clear()
        current_layer = new_layer(state.current_graph)
        state.current_graph.get_layers().push(current_layer)
        state.width_current = 0.0
        state.width_up = 0.0
        state.already_placed_nodes = {}
        state.already_placed_in_other_layers = {}
        state.max_width += 1.0
        state.temp_layerless_nodes = state.sorted_layerless_nodes.copy()
        state.remaining_out_going = state.out_degree.copy()
      } else {
        selected.set_layer(Some(current_layer))
        stretch_width_layerer_remove_temp_node(state, selected)
        state.already_placed_nodes[selected.get_handle()] = true
        let selected_id = selected.get_id()
        state.width_current = state.width_current -
          state.out_degree[selected_id].to_double() * state.dummy_size +
          state.norm_size[selected_id]
        state.width_up += state.in_degree[selected_id].to_double() *
          state.dummy_size
      }
    }
  }

  layered_graph.get_layerless_nodes().clear()
  stretch_width_layerer_reverse_layers(layered_graph.get_layers())
  monitor.done()
}

///|
pub fn new_stretch_width_layerer_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    stretch_width_layerer_process, stretch_width_layerer_configuration,
  )
}
