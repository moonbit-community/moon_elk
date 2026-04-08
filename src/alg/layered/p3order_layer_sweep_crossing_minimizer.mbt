///|
fn layer_sweep_cross_min_type_to_string(
  cross_min_type : CrossMinType,
) -> String {
  match cross_min_type {
    CrossMinType::Barycenter => "BARYCENTER"
    CrossMinType::OneSidedGreedySwitch => "ONE_SIDED_GREEDY_SWITCH"
    CrossMinType::TwoSidedGreedySwitch => "TWO_SIDED_GREEDY_SWITCH"
    CrossMinType::Median => "MEDIAN"
  }
}

///|
priv suberror LayerSweepCrossingMinimizerException {
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
fn[T] layer_sweep_crossing_minimizer_raise_illegal_state(
  message : String,
) -> T raise LayerSweepCrossingMinimizerException {
  raise LayerSweepCrossingMinimizerException::IllegalStateException(message)
}

///|
fn layer_sweep_port_side_is(
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
fn layer_sweep_is_external_port_dummy(node : LNode) -> Bool {
  match node.get_type() {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn layer_sweep_has_nested_graph(node : LNode) -> Bool {
  match node.get_nested_graph() {
    Some(_) => true
    None => false
  }
}

///|
fn layer_sweep_contains_graph_data(
  graphs : Array[GraphInfoHolder],
  candidate : GraphInfoHolder,
) -> Bool {
  let candidate_id = candidate.l_graph().get_id()
  for graph in graphs {
    if graph.l_graph().get_id() == candidate_id {
      return true
    }
  }
  false
}

///|
fn layer_sweep_graph_data_at(
  graph_data : Array[GraphInfoHolder],
  graph_id : Int,
) -> GraphInfoHolder? {
  if graph_id < 0 || graph_id >= graph_data.length() {
    None
  } else {
    Some(graph_data[graph_id])
  }
}

///|
fn layer_sweep_empty_graph(layered_graph : LGraph) -> Bool {
  let layers = layered_graph.get_layers()
  if layers.is_empty() {
    return true
  }
  for layer in layers {
    if !layer.get_nodes().is_empty() {
      return false
    }
  }
  true
}

///|
fn layer_sweep_single_node_graph(layered_graph : LGraph) -> Bool {
  let layers = layered_graph.get_layers()
  layers.length() == 1 && layers[0].get_nodes().length() == 1
}

///|
fn layer_sweep_hierarchical_layout(layered_graph : LGraph) -> Bool {
  let handling = layered_graph.get_property_string(
    layered_options_hierarchy_handling,
  )
  if handling == "INCLUDE_CHILDREN" {
    return true
  }
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      if layer_sweep_has_nested_graph(node) {
        return true
      }
    }
  }
  false
}

///|
fn layer_sweep_ordering_strategy_from_string(
  value : String,
) -> OrderingStrategy {
  match value {
    "NODES_AND_EDGES" => OrderingStrategy::NodesAndEdges
    "PREFER_EDGES" => OrderingStrategy::PreferEdges
    "PREFER_NODES" => OrderingStrategy::PreferNodes
    _ => OrderingStrategy::NoneType
  }
}

///|
fn layer_sweep_intermediate_processing_configuration() -> @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] {
  @core.layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeSplitter,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::InLayerConstraintProcessor,
    ),
  )
  .after(LayeredPhases::P5EdgeRouting)
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LongEdgeJoiner,
    ),
  )
}

///|
let layer_sweep_default_configuration : @core.LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layer_sweep_intermediate_processing_configuration()

///|
pub struct LayerSweepCrossingMinimizer {
  cross_min_type : CrossMinType
  graph_info_holders : Array[GraphInfoHolder]
  graphs_whose_node_order_changed : Array[GraphInfoHolder]
  mut random : MockRandom
  mut random_seed : Int64
}

///|
pub fn new_layer_sweep_crossing_minimizer(
  cross_min_type : CrossMinType,
) -> LayerSweepCrossingMinimizer {
  {
    cross_min_type,
    graph_info_holders: [],
    graphs_whose_node_order_changed: [],
    random: new_mock_random(),
    random_seed: 0L,
  }
}

///|
fn LayerSweepCrossingMinimizer::first_index(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  ignore(self)
  if is_forward_sweep {
    0
  } else {
    length - 1
  }
}

///|
fn LayerSweepCrossingMinimizer::end_index(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  ignore(self)
  if is_forward_sweep {
    length - 1
  } else {
    0
  }
}

///|
fn LayerSweepCrossingMinimizer::first_free(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
  length : Int,
) -> Int {
  ignore(self)
  if is_forward_sweep {
    1
  } else {
    length - 2
  }
}

///|
fn LayerSweepCrossingMinimizer::next(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
) -> Int {
  ignore(self)
  if is_forward_sweep {
    1
  } else {
    -1
  }
}

///|
fn LayerSweepCrossingMinimizer::is_not_end(
  self : LayerSweepCrossingMinimizer,
  length : Int,
  free_layer_index : Int,
  is_forward_sweep : Bool,
) -> Bool {
  ignore(self)
  if is_forward_sweep {
    free_layer_index < length
  } else {
    free_layer_index >= 0
  }
}

///|
fn LayerSweepCrossingMinimizer::side_opposed_sweep_direction(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
) -> @core.PortSide {
  ignore(self)
  if is_forward_sweep {
    @core.PortSide::West
  } else {
    @core.PortSide::East
  }
}

///|
fn LayerSweepCrossingMinimizer::is_hierarchical(
  self : LayerSweepCrossingMinimizer,
  port : LPort,
) -> Bool {
  ignore(self)
  port.has_property_l_node(internal_properties_port_dummy)
}

///|
fn LayerSweepCrossingMinimizer::dummy_node_for(
  self : LayerSweepCrossingMinimizer,
  port : LPort,
) -> LNode? {
  ignore(self)
  port.get_property_l_node(internal_properties_port_dummy)
}

///|
fn LayerSweepCrossingMinimizer::origin_port(
  self : LayerSweepCrossingMinimizer,
  node : LNode,
) -> LPort raise LayerSweepCrossingMinimizerException {
  ignore(self)
  match node.get_property_l_port(internal_properties_origin_l_port) {
    Some(origin) => origin
    None =>
      layer_sweep_crossing_minimizer_raise_illegal_state(
        "external port dummy has no origin port",
      )
  }
}

///|
fn LayerSweepCrossingMinimizer::is_on_end_of_sweep_side(
  self : LayerSweepCrossingMinimizer,
  port : LPort,
  is_forward_sweep : Bool,
) -> Bool {
  ignore(self)
  if is_forward_sweep {
    layer_sweep_port_side_is(port.get_side(), @core.PortSide::East)
  } else {
    layer_sweep_port_side_is(port.get_side(), @core.PortSide::West)
  }
}

///|
fn LayerSweepCrossingMinimizer::mark_graph_as_changed(
  self : LayerSweepCrossingMinimizer,
  graph : GraphInfoHolder,
) -> Unit {
  if !layer_sweep_contains_graph_data(
      self.graphs_whose_node_order_changed,
      graph,
    ) {
    self.graphs_whose_node_order_changed.push(graph)
  }
}

///|
fn LayerSweepCrossingMinimizer::save_all_node_orders_of_changed_graphs(
  self : LayerSweepCrossingMinimizer,
) -> Unit {
  for graph in self.graphs_whose_node_order_changed {
    if graph.currently_best_node_and_port_order() is Some(best) {
      graph.set_best_node_n_port_order(Some(new_sweep_copy_from(best)))
    }
  }
}

///|
fn LayerSweepCrossingMinimizer::set_currently_best_node_orders(
  self : LayerSweepCrossingMinimizer,
) -> Unit {
  for graph in self.graphs_whose_node_order_changed {
    graph.set_currently_best_node_and_port_order(
      Some(new_sweep_copy(graph.current_node_order())),
    )
  }
}

///|
fn LayerSweepCrossingMinimizer::sort_port_dummies_by_port_positions(
  self : LayerSweepCrossingMinimizer,
  parent_node : LNode,
  layer_close_to_node_edge : Array[LNode],
  side : @core.PortSide,
) -> Array[LNode] raise LayerSweepCrossingMinimizerException {
  if layer_close_to_node_edge.is_empty() {
    return []
  }

  let sorted_dummies = []
  for port in in_north_south_east_west_order(parent_node, side) {
    if self.is_hierarchical(port) {
      match self.dummy_node_for(port) {
        Some(dummy) => sorted_dummies.push(dummy)
        None => ()
      }
    }
  }

  if sorted_dummies.length() < layer_close_to_node_edge.length() {
    layer_sweep_crossing_minimizer_raise_illegal_state(
      "did not find enough hierarchical dummy ports to sort",
    )
  }

  let trimmed = []
  for i in 0..<layer_close_to_node_edge.length() {
    trimmed.push(sorted_dummies[i])
  }
  trimmed
}

///|
fn LayerSweepCrossingMinimizer::sort_ports_by_dummy_positions_in_last_layer(
  self : LayerSweepCrossingMinimizer,
  node_order : Array[Array[LNode]],
  parent : LNode,
  on_right_most_layer : Bool,
) -> Unit raise LayerSweepCrossingMinimizerException {
  if node_order.is_empty() {
    return
  }

  let end_index = self.end_index(on_right_most_layer, node_order.length())
  let last_layer = node_order[end_index]
  if last_layer.is_empty() {
    return
  }

  let mut j = self.first_index(on_right_most_layer, last_layer.length())
  if !layer_sweep_is_external_port_dummy(last_layer[j]) {
    return
  }

  let ports = parent.get_ports()
  for i in 0..<ports.length() {
    let port = ports[i]
    if self.is_on_end_of_sweep_side(port, on_right_most_layer) &&
      self.is_hierarchical(port) {
      if j < 0 || j >= last_layer.length() {
        break
      }
      ports[i] = self.origin_port(last_layer[j])
      j = j + self.next(on_right_most_layer)
    }
  }
}

///|
fn LayerSweepCrossingMinimizer::sweep_in_hierarchical_node(
  self : LayerSweepCrossingMinimizer,
  is_forward_sweep : Bool,
  node : LNode,
  is_first_sweep : Bool,
) -> Bool raise LayerSweepCrossingMinimizerException {
  let nested_graph = match node.get_nested_graph() {
    Some(graph) => graph
    None => return false
  }
  let nested_data = match
    layer_sweep_graph_data_at(self.graph_info_holders, nested_graph.get_id()) {
    Some(data) => data
    None => return false
  }
  let nested_order = nested_data.current_node_order()
  if nested_order.is_empty() {
    return false
  }
  let start_index = self.first_index(is_forward_sweep, nested_order.length())
  if nested_order[start_index].is_empty() {
    return false
  }
  let first_node = nested_order[start_index][0]

  if layer_sweep_is_external_port_dummy(first_node) {
    nested_order[start_index] = self.sort_port_dummies_by_port_positions(
      node,
      nested_order[start_index],
      self.side_opposed_sweep_direction(is_forward_sweep),
    )
  } else {
    ignore(
      nested_data
      .cross_minimizer()
      .set_first_layer_order(nested_order, is_forward_sweep),
    )
  }

  let improved = self.sweep_reducing_crossings(
    nested_data, is_forward_sweep, is_first_sweep,
  )
  self.sort_ports_by_dummy_positions_in_last_layer(
    nested_data.current_node_order(),
    nested_data.parent(),
    is_forward_sweep,
  )
  improved
}

///|
fn LayerSweepCrossingMinimizer::sweep_in_hierarchical_nodes(
  self : LayerSweepCrossingMinimizer,
  layer : Array[LNode],
  is_forward_sweep : Bool,
  is_first_sweep : Bool,
) -> Bool raise LayerSweepCrossingMinimizerException {
  let mut improved = false
  for node in layer {
    if !layer_sweep_has_nested_graph(node) {
      continue
    }
    let nested_graph = match node.get_nested_graph() {
      Some(graph) => graph
      None => continue
    }
    let nested_data = match
      layer_sweep_graph_data_at(self.graph_info_holders, nested_graph.get_id()) {
      Some(data) => data
      None => continue
    }
    if nested_data.dont_sweep_into() {
      continue
    }
    improved = self.sweep_in_hierarchical_node(
        is_forward_sweep, node, is_first_sweep,
      ) ||
      improved
  }
  improved
}

///|
fn LayerSweepCrossingMinimizer::sweep_reducing_crossings(
  self : LayerSweepCrossingMinimizer,
  graph : GraphInfoHolder,
  forward : Bool,
  first_sweep : Bool,
) -> Bool raise LayerSweepCrossingMinimizerException {
  let nodes = graph.current_node_order()
  let length = nodes.length()
  if length == 0 {
    return false
  }

  let mut improved = graph
    .port_distributor()
    .distribute_ports_while_sweeping(
      nodes,
      self.first_index(forward, length),
      forward,
    )
  let first_layer = nodes[self.first_index(forward, length)]
  improved = self.sweep_in_hierarchical_nodes(first_layer, forward, first_sweep) ||
    improved

  let mut free_layer = self.first_free(forward, length)
  while self.is_not_end(length, free_layer, forward) {
    let first_try_with_initial_order = graph
      .l_graph()
      .get_property_bool(internal_properties_first_try_with_initial_order)
    let second_try_with_initial_order = graph
      .l_graph()
      .get_property_bool(internal_properties_second_try_with_initial_order)
    improved = graph
      .cross_minimizer()
      .minimize_crossings(
        nodes,
        free_layer,
        forward,
        first_sweep &&
        !first_try_with_initial_order &&
        !second_try_with_initial_order,
      ) ||
      improved
    improved = graph
      .port_distributor()
      .distribute_ports_while_sweeping(nodes, free_layer, forward) ||
      improved
    improved = self.sweep_in_hierarchical_nodes(
        nodes[free_layer],
        forward,
        first_sweep,
      ) ||
      improved
    free_layer = free_layer + self.next(forward)
  }

  self.mark_graph_as_changed(graph)
  improved
}

///|
fn LayerSweepCrossingMinimizer::count_current_number_of_crossings(
  self : LayerSweepCrossingMinimizer,
  current_graph : GraphInfoHolder,
) -> Int {
  let mut total_crossings = 0
  let to_count = [current_graph]
  while !to_count.is_empty() {
    let g_data = match to_count.pop() {
      Some(data) => data
      None => break
    }
    total_crossings = total_crossings +
      g_data.cross_counter().count_all_crossings(g_data.current_node_order())

    for child_graph in g_data.child_graphs() {
      match
        layer_sweep_graph_data_at(self.graph_info_holders, child_graph.get_id()) {
        Some(child_data) =>
          if !child_data.dont_sweep_into() {
            to_count.push(child_data)
          }
        None => ()
      }
    }
  }
  total_crossings
}

///|
fn LayerSweepCrossingMinimizer::count_model_order_node_changes(
  self : LayerSweepCrossingMinimizer,
  graph : LGraph,
  layers : Array[Array[LNode]],
  strategy : OrderingStrategy,
  cm_group_order_strategy : GroupOrderStrategy,
) -> Int {
  ignore(self)
  let mut previous_layer = -1
  let mut wrong_model_order = 0
  for layer in layers {
    let reference_layer = if previous_layer == -1 {
      layers[0]
    } else {
      layers[previous_layer]
    }
    let comparator = new_model_order_node_comparator(
      graph,
      reference_layer,
      strategy,
      LongEdgeOrderingStrategy::Equal,
      cm_group_order_strategy,
      false,
    )
    for i in 0..<layer.length() {
      for j in (i + 1)..<layer.length() {
        if layer[i].has_property_int(internal_properties_model_order) &&
          layer[j].has_property_int(internal_properties_model_order) &&
          comparator.compare(layer[i], layer[j]) > 0 {
          wrong_model_order = wrong_model_order + 1
        }
      }
    }
    previous_layer = previous_layer + 1
  }
  wrong_model_order
}

///|
fn LayerSweepCrossingMinimizer::count_model_order_port_changes(
  self : LayerSweepCrossingMinimizer,
  graph : LGraph,
  layers : Array[Array[LNode]],
  strategy : OrderingStrategy,
) -> Int {
  ignore(self)
  let mut previous_layer = -1
  let mut wrong_model_order = 0
  for layer in layers {
    let reference_layer = if previous_layer == -1 {
      layers[0]
    } else {
      layers[previous_layer]
    }
    for node in layer {
      let comparator = new_model_order_port_comparator(
        graph,
        reference_layer,
        strategy,
        sort_by_input_model_processor_long_edge_target_node_preprocessing(node),
        node
        .get_graph()
        .get_property_bool(
          layered_options_consider_model_order_port_model_order,
        ),
      )
      let ports = node.get_ports()
      for i in 0..<ports.length() {
        for j in (i + 1)..<ports.length() {
          if comparator.compare(ports[i], ports[j]) > 0 {
            wrong_model_order = wrong_model_order + 1
          }
        }
      }
    }
    previous_layer = previous_layer + 1
  }
  wrong_model_order
}

///|
fn LayerSweepCrossingMinimizer::count_current_number_of_crossings_node_port_order(
  self : LayerSweepCrossingMinimizer,
  current_graph : GraphInfoHolder,
) -> Double {
  let mut total_crossings = 0.0
  let to_count = [current_graph]
  while !to_count.is_empty() {
    let g_data = match to_count.pop() {
      Some(data) => data
      None => break
    }

    let mut model_order_influence = 0.0
    let model_order_strategy = current_graph
      .l_graph()
      .get_property_string(layered_options_consider_model_order_strategy)
    let cm_group_order_strategy = group_order_strategy_from_string(
      current_graph
      .l_graph()
      .get_property_string(
        layered_options_consider_model_order_group_model_order_cm_group_order_strategy,
      ),
    )
    let crossing_counter_node_influence = current_graph
      .l_graph()
      .get_property_double(
        layered_options_consider_model_order_crossing_counter_node_influence,
      )
    let crossing_counter_port_influence = current_graph
      .l_graph()
      .get_property_double(
        layered_options_consider_model_order_crossing_counter_port_influence,
      )
    if model_order_strategy != "NONE" {
      let strategy = layer_sweep_ordering_strategy_from_string(
        model_order_strategy,
      )
      model_order_influence = model_order_influence +
        crossing_counter_node_influence *
        self
        .count_model_order_node_changes(
          current_graph.l_graph(),
          g_data.current_node_order(),
          strategy,
          cm_group_order_strategy,
        )
        .to_double()
      model_order_influence = model_order_influence +
        crossing_counter_port_influence *
        self
        .count_model_order_port_changes(
          current_graph.l_graph(),
          g_data.current_node_order(),
          strategy,
        )
        .to_double()
    }

    total_crossings = total_crossings +
      g_data
      .cross_counter()
      .count_all_crossings(g_data.current_node_order())
      .to_double() +
      model_order_influence

    for child_graph in g_data.child_graphs() {
      match
        layer_sweep_graph_data_at(self.graph_info_holders, child_graph.get_id()) {
        Some(child_data) =>
          if !child_data.dont_sweep_into() {
            total_crossings = total_crossings +
              self.count_current_number_of_crossings(child_data).to_double()
          }
        None => ()
      }
    }
  }
  total_crossings
}

///|
fn LayerSweepCrossingMinimizer::minimize_crossings_with_counter(
  self : LayerSweepCrossingMinimizer,
  graph_data : GraphInfoHolder,
) -> Int raise LayerSweepCrossingMinimizerException {
  let mut is_forward_sweep = self.random.next_boolean()
  let first_try_with_initial_order = graph_data
    .l_graph()
    .get_property_bool(internal_properties_first_try_with_initial_order)
  let second_try_with_initial_order = graph_data
    .l_graph()
    .get_property_bool(internal_properties_second_try_with_initial_order)
  let consider_model_order_strategy = graph_data
    .l_graph()
    .get_property_string(layered_options_consider_model_order_strategy)
  if (!first_try_with_initial_order && !second_try_with_initial_order) ||
    consider_model_order_strategy == "NONE" {
    ignore(
      graph_data
      .cross_minimizer()
      .set_first_layer_order(graph_data.current_node_order(), is_forward_sweep),
    )
  } else {
    is_forward_sweep = first_try_with_initial_order
  }

  ignore(self.sweep_reducing_crossings(graph_data, is_forward_sweep, true))
  if second_try_with_initial_order {
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_second_try_with_initial_order, false)
  }
  if first_try_with_initial_order {
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_first_try_with_initial_order, false)
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_second_try_with_initial_order, true)
  }

  let mut crossings_in_graph = self.count_current_number_of_crossings(
    graph_data,
  )
  let mut old_number_of_crossings = 0
  while true {
    self.set_currently_best_node_orders()
    if crossings_in_graph == 0 {
      return 0
    }

    is_forward_sweep = !is_forward_sweep
    old_number_of_crossings = crossings_in_graph
    ignore(self.sweep_reducing_crossings(graph_data, is_forward_sweep, false))
    crossings_in_graph = self.count_current_number_of_crossings(graph_data)
    if old_number_of_crossings <= crossings_in_graph {
      break
    }
  }
  old_number_of_crossings
}

///|
fn LayerSweepCrossingMinimizer::minimize_crossings_node_port_order_with_counter(
  self : LayerSweepCrossingMinimizer,
  graph_data : GraphInfoHolder,
) -> Double raise LayerSweepCrossingMinimizerException {
  let mut is_forward_sweep = self.random.next_boolean()
  let first_try_with_initial_order = graph_data
    .l_graph()
    .get_property_bool(internal_properties_first_try_with_initial_order)
  let second_try_with_initial_order = graph_data
    .l_graph()
    .get_property_bool(internal_properties_second_try_with_initial_order)
  let consider_model_order_strategy = graph_data
    .l_graph()
    .get_property_string(layered_options_consider_model_order_strategy)
  if (!first_try_with_initial_order && !second_try_with_initial_order) ||
    consider_model_order_strategy == "NONE" {
    ignore(
      graph_data
      .cross_minimizer()
      .set_first_layer_order(graph_data.current_node_order(), is_forward_sweep),
    )
  } else {
    is_forward_sweep = first_try_with_initial_order
  }

  ignore(self.sweep_reducing_crossings(graph_data, is_forward_sweep, true))
  if second_try_with_initial_order {
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_second_try_with_initial_order, false)
  }
  if first_try_with_initial_order {
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_first_try_with_initial_order, false)
    graph_data
    .l_graph()
    .set_property_bool(internal_properties_second_try_with_initial_order, true)
  }

  let mut crossings_in_graph = self.count_current_number_of_crossings_node_port_order(
    graph_data,
  )
  let mut old_number_of_crossings = 0.0
  while true {
    self.set_currently_best_node_orders()
    if crossings_in_graph == 0.0 {
      return 0.0
    }

    is_forward_sweep = !is_forward_sweep
    old_number_of_crossings = crossings_in_graph
    ignore(self.sweep_reducing_crossings(graph_data, is_forward_sweep, false))
    crossings_in_graph = self.count_current_number_of_crossings_node_port_order(
      graph_data,
    )
    if old_number_of_crossings <= crossings_in_graph {
      break
    }
  }
  old_number_of_crossings
}

///|
fn LayerSweepCrossingMinimizer::minimize_crossings_no_counter(
  self : LayerSweepCrossingMinimizer,
  graph_data : GraphInfoHolder,
) -> Unit raise LayerSweepCrossingMinimizerException {
  let mut is_forward_sweep = self.random.next_boolean()
  let mut improved = true
  while improved {
    improved = false
    improved = graph_data
      .cross_minimizer()
      .set_first_layer_order(graph_data.current_node_order(), is_forward_sweep)
    improved = self.sweep_reducing_crossings(
        graph_data, is_forward_sweep, false,
      ) ||
      improved
    is_forward_sweep = !is_forward_sweep
  }
  self.set_currently_best_node_orders()
}

///|
fn LayerSweepCrossingMinimizer::compare_different_randomized_layouts(
  self : LayerSweepCrossingMinimizer,
  graph_data : GraphInfoHolder,
) -> Unit raise LayerSweepCrossingMinimizerException {
  self.random.set_seed(self.random_seed)
  self.graphs_whose_node_order_changed.clear()

  let crossing_counter_node_influence = graph_data
    .l_graph()
    .get_property_double(
      layered_options_consider_model_order_crossing_counter_node_influence,
    )
  let crossing_counter_port_influence = graph_data
    .l_graph()
    .get_property_double(
      layered_options_consider_model_order_crossing_counter_port_influence,
    )
  let mut thoroughness = graph_data
    .l_graph()
    .get_property_int(layered_options_thoroughness)
  if thoroughness < 1 {
    thoroughness = 1
  }

  if crossing_counter_node_influence != 0.0 ||
    crossing_counter_port_influence != 0.0 {
    let consider_model_order_strategy = graph_data
      .l_graph()
      .get_property_string(layered_options_consider_model_order_strategy)
    if consider_model_order_strategy != "NONE" {
      graph_data
      .l_graph()
      .set_property_bool(internal_properties_first_try_with_initial_order, true)
    }

    let mut best_crossings = @double.max_value
    for _ in 0..<thoroughness {
      let crossings = self.minimize_crossings_node_port_order_with_counter(
        graph_data,
      )
      if crossings < best_crossings {
        best_crossings = crossings
        self.save_all_node_orders_of_changed_graphs()
        if best_crossings == 0.0 {
          break
        }
      }
    }
  } else {
    let consider_model_order_strategy = graph_data
      .l_graph()
      .get_property_string(layered_options_consider_model_order_strategy)
    if consider_model_order_strategy != "NONE" {
      graph_data
      .l_graph()
      .set_property_bool(internal_properties_first_try_with_initial_order, true)
    }

    let mut best_crossings = @int.MAX_VALUE
    for _ in 0..<thoroughness {
      let crossings = self.minimize_crossings_with_counter(graph_data)
      if crossings < best_crossings {
        best_crossings = crossings
        self.save_all_node_orders_of_changed_graphs()
        if best_crossings == 0 {
          break
        }
      }
    }
  }
}

///|
fn LayerSweepCrossingMinimizer::set_port_order_on_parent_graph(
  self : LayerSweepCrossingMinimizer,
  graph_data : GraphInfoHolder,
) -> Unit raise LayerSweepCrossingMinimizerException {
  if !graph_data.has_external_ports() {
    return
  }

  match graph_data.get_best_sweep() {
    Some(best_sweep) => {
      self.sort_ports_by_dummy_positions_in_last_layer(
        best_sweep.nodes(),
        graph_data.parent(),
        true,
      )
      self.sort_ports_by_dummy_positions_in_last_layer(
        best_sweep.nodes(),
        graph_data.parent(),
        false,
      )
      graph_data
      .parent()
      .set_property_string(@core.port_constraints, "FIXED_ORDER")
    }
    None => ()
  }
}

///|
fn LayerSweepCrossingMinimizer::choose_minimizing_method(
  self : LayerSweepCrossingMinimizer,
  graphs_to_sweep_on : Array[GraphInfoHolder],
) -> (GraphInfoHolder) -> Unit raise LayerSweepCrossingMinimizerException {
  ignore(self)
  if graphs_to_sweep_on.is_empty() {
    return _ => ()
  }
  let parent = graphs_to_sweep_on[0]
  if !parent.cross_min_deterministic() {
    graph => self.compare_different_randomized_layouts(graph)
  } else if parent.cross_min_always_improves() {
    graph => self.minimize_crossings_no_counter(graph)
  } else {
    graph => ignore(self.minimize_crossings_with_counter(graph))
  }
}

///|
fn LayerSweepCrossingMinimizer::initialize(
  self : LayerSweepCrossingMinimizer,
  root_graph : LGraph,
) -> Array[GraphInfoHolder] {
  self.graph_info_holders.clear()
  self.graphs_whose_node_order_changed.clear()

  if root_graph.get_property_mock_random(internal_properties_random)
    is Some(random) {
    self.random = random
  } else {
    let seed_value = root_graph.get_property_int(@core.random_seed)
    self.random = if seed_value == 0 {
      new_greedy_switch_mock_random_seeded(
        @random.Rand::new().int(limit=@int.MAX_VALUE),
      )
    } else {
      new_greedy_switch_mock_random_seeded(seed_value)
    }
  }
  self.random_seed = self.random.next_long()
  root_graph.set_property_mock_random(
    internal_properties_random,
    Some(self.random),
  )

  let graphs_to_sweep_on = []
  let graphs = [root_graph]
  let mut i = 0
  while i < graphs.length() {
    let graph = graphs[i]
    graph.set_id(i)
    i = i + 1

    let graph_data = new_graph_info_holder_from_graph(
      graph,
      self.cross_min_type,
      self.graph_info_holders,
    )

    for child in graph_data.child_graphs() {
      graphs.push(child)
    }
    self.graph_info_holders.push(graph_data)
    if graph_data.dont_sweep_into() {
      ignore(graphs_to_sweep_on.insert(0, graph_data))
    }
  }

  graphs_to_sweep_on
}

///|
fn LayerSweepCrossingMinimizer::transfer_node_and_port_orders_to_graph(
  self : LayerSweepCrossingMinimizer,
) -> Unit {
  for graph_data in self.graph_info_holders {
    match graph_data.get_best_sweep() {
      Some(best_sweep) =>
        best_sweep.transfer_node_and_port_orders_to_graph(
          graph_data.l_graph(),
          true,
        )
      None => ()
    }
  }
}

///|
fn LayerSweepCrossingMinimizer::process_internal(
  self : LayerSweepCrossingMinimizer,
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit raise LayerSweepCrossingMinimizerException {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(
    monitor.begin(
      "Minimize Crossings " +
      layer_sweep_cross_min_type_to_string(self.cross_min_type),
      1.0,
    ),
  )

  if layer_sweep_empty_graph(layered_graph) ||
    (
      layer_sweep_single_node_graph(layered_graph) &&
      !layer_sweep_hierarchical_layout(layered_graph)
    ) {
    monitor.done()
    return
  }

  let graphs_to_sweep_on = self.initialize(layered_graph)
  let minimizing_method = self.choose_minimizing_method(graphs_to_sweep_on)

  for graph_data in graphs_to_sweep_on {
    if graph_data.current_node_order().length() > 0 {
      minimizing_method(graph_data)
      if graph_data.has_parent() {
        self.set_port_order_on_parent_graph(graph_data)
      }
    }
  }

  self.transfer_node_and_port_orders_to_graph()
  monitor.done()
}

///|
pub fn LayerSweepCrossingMinimizer::process(
  self : LayerSweepCrossingMinimizer,
  layered_graph : LGraph,
  progress_monitor? : @core.IElkProgressMonitor? = None,
) -> Unit {
  self.process_internal(layered_graph, progress_monitor) catch {
    LayerSweepCrossingMinimizerException::IllegalStateException(message) =>
      @core.layout_runtime_report_unsupported_configuration(message)
  }
}

///|
pub fn LayerSweepCrossingMinimizer::get_graph_data(
  self : LayerSweepCrossingMinimizer,
) -> Array[GraphInfoHolder] {
  self.graph_info_holders
}

///|
fn layer_sweep_configuration(
  graph : LGraph,
) -> @core.LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  ignore(graph)
  let configuration = @core.layout_processor_configuration_create_from(
    layer_sweep_default_configuration,
  )
  ignore(
    configuration.add_before(
      LayeredPhases::P3NodeOrdering,
      layered_intermediate_processor_factory(
        IntermediateProcessorStrategy::PortListSorter,
      ),
    ),
  )
  Some(configuration)
}

///|
pub fn new_layer_sweep_crossing_minimizer_layout_phase(
  cross_min_type : CrossMinType,
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  let minimizer = new_layer_sweep_crossing_minimizer(cross_min_type)
  @core.new_hierarchy_aware_layout_phase(
    (graph, monitor) => minimizer.process(graph, progress_monitor=monitor),
    layer_sweep_configuration,
  )
}
