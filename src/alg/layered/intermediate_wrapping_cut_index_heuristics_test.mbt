///|
fn wrapping_cut_test_new_graph_with_layers(
  layer_count : Int,
) -> (LGraph, Array[Layer]) {
  let graph = new_l_graph()
  let layers = []
  for _ in 0..<layer_count {
    let layer = new_layer(graph)
    graph.get_layers().push(layer)
    layers.push(layer)
  }
  (graph, layers)
}

///|
fn wrapping_cut_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn wrapping_cut_test_direction(name : String) -> @core.Direction {
  for value in @core.direction_values() {
    if @core.direction_to_string(value) == name {
      return value
    }
  }
  abort("unknown @core.direction")
}

///|
fn wrapping_cut_test_node_type(name : String) -> NodeType {
  for node_type in node_type_values() {
    match node_type {
      NodeType::Normal => if name == "NORMAL" { return node_type }
      NodeType::LongEdge => if name == "LONG_EDGE" { return node_type }
      NodeType::ExternalPort => if name == "EXTERNAL_PORT" { return node_type }
      NodeType::NorthSouthPort =>
        if name == "NORTH_SOUTH_PORT" {
          return node_type
        }
      NodeType::LabelNode => if name == "LABEL_NODE" { return node_type }
      NodeType::BreakingPoint =>
        if name == "BREAKING_POINT" {
          return node_type
        }
      NodeType::Placeholder => if name == "PLACEHOLDER" { return node_type }
      NodeType::NonshiftingPlaceholder =>
        if name == "NONSHIFTING_PLACEHOLDER" {
          return node_type
        }
    }
  }
  abort("unknown node type")
}

///|
fn wrapping_cut_test_new_node(
  graph : LGraph,
  layer : Layer,
  width : Double,
  height : Double,
  top : Double,
  right : Double,
  bottom : Double,
  left : Double,
  node_type? : NodeType? = None,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_layer(Some(layer))
  ignore(node.get_size().set_xy(width, height))
  node.get_margin().set_values(top, right, bottom, left)
  match node_type {
    Some(value) => node.set_type(value)
    None => ()
  }
  node
}

///|
fn wrapping_cut_test_connect(source : LNode, target : LNode) -> LEdge {
  let source_port = new_l_port()
  source_port.set_side(wrapping_cut_test_port_side("EAST"))
  source_port.set_node(Some(source))

  let target_port = new_l_port()
  target_port.set_side(wrapping_cut_test_port_side("WEST"))
  target_port.set_node(Some(target))

  let edge = new_l_edge()
  edge.set_source(Some(source_port))
  edge.set_target(Some(target_port))
  edge
}

///|
fn wrapping_cut_test_new_uniform_graph_stats(
  layer_count : Int,
) -> (LGraph, GraphStats) {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(layer_count)
  graph.set_property_direction(
    layered_components_direction,
    wrapping_cut_test_direction("RIGHT"),
  )
  graph.set_property_double(@core.aspect_ratio, 1.0)
  graph.set_property_double(layered_options_wrapping_correction_factor, 1.0)
  graph.set_property_double(
    layered_options_spacing_node_node_between_layers, 0.0,
  )
  graph.set_property_double(@core.spacing_node_node, 0.0)

  for layer in layers {
    ignore(
      wrapping_cut_test_new_node(graph, layer, 10.0, 10.0, 0.0, 0.0, 0.0, 0.0),
    )
  }

  (graph, new_graph_stats(graph))
}

///|
test "graph stats computes approximation widths heights and chunk values" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(2)
  graph.set_property_direction(
    layered_components_direction,
    wrapping_cut_test_direction("RIGHT"),
  )
  graph.set_property_double(@core.aspect_ratio, 2.0)
  graph.set_property_double(layered_options_wrapping_correction_factor, 1.5)
  graph.set_property_double(
    layered_options_spacing_node_node_between_layers, 2.0,
  )
  graph.set_property_double(@core.spacing_node_node, 3.0)

  ignore(
    wrapping_cut_test_new_node(graph, layers[0], 10.0, 5.0, 1.0, 1.0, 1.0, 1.0),
  )
  ignore(
    wrapping_cut_test_new_node(graph, layers[1], 20.0, 4.0, 2.0, 0.0, 2.0, 0.0),
  )

  let graph_stats = new_graph_stats(graph)
  assert_eq(graph_stats.longest_path, 2)
  assert_eq(graph_stats.dar, 3.0)

  assert_eq(graph_stats.get_approximate_layer_width(layers[0]), 14.0)
  assert_eq(graph_stats.get_approximate_layer_width(layers[1]), 22.0)
  assert_eq(graph_stats.get_approximate_layer_height(layers[0]), 10.0)
  assert_eq(graph_stats.get_approximate_layer_height(layers[1]), 11.0)

  assert_eq(graph_stats.get_sum_width(), 36.0)
  assert_eq(graph_stats.get_max_width(), 22.0)
  assert_eq(graph_stats.get_max_height(), 11.0)
  assert_eq(graph_stats.get_approximate_layering_width(), 36.0)
  assert_eq(graph_stats.get_approximate_layering_height(), 11.0)

  assert_eq(graph_stats.get_approximate_chunk_based_layering_width([1]), 22.0)
  assert_eq(graph_stats.get_approximate_chunk_based_layering_height([1]), 21.0)
  assert_eq(graph_stats.get_approximate_chunk_based_layering_height([]), 0.0)
}

///|
test "graph stats adjusts desired aspect ratio for vertical @core.direction" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(1)
  graph.set_property_direction(
    layered_components_direction,
    wrapping_cut_test_direction("DOWN"),
  )
  graph.set_property_double(@core.aspect_ratio, 4.0)
  graph.set_property_double(layered_options_wrapping_correction_factor, 2.0)

  ignore(
    wrapping_cut_test_new_node(graph, layers[0], 10.0, 10.0, 0.0, 0.0, 0.0, 0.0),
  )

  let graph_stats = new_graph_stats(graph)
  assert_eq(graph_stats.dar, 0.125)
}

///|
test "graph stats detects allowed and forbidden cut indices from topology" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(3)

  let source = wrapping_cut_test_new_node(
    graph,
    layers[0],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  let middle = wrapping_cut_test_new_node(
    graph,
    layers[1],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  let left_target = wrapping_cut_test_new_node(
    graph,
    layers[2],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  let right_target = wrapping_cut_test_new_node(
    graph,
    layers[2],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )

  ignore(wrapping_cut_test_connect(source, middle))
  ignore(wrapping_cut_test_connect(middle, left_target))
  ignore(wrapping_cut_test_connect(middle, right_target))

  let graph_stats = new_graph_stats(graph)
  assert_false(graph_stats.is_cut_allowed(0))
  assert_true(graph_stats.is_cut_allowed(1))
  assert_false(graph_stats.is_cut_allowed(2))

  let cuts_allowed = graph_stats.get_cuts_allowed()
  assert_eq(cuts_allowed.length(), 3)
  assert_false(cuts_allowed[0])
  assert_true(cuts_allowed[1])
  assert_false(cuts_allowed[2])
}

///|
test "graph stats with forbidden index option keeps all cuts false as upstream" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(3)
  graph.set_property_string(
    layered_options_wrapping_validify_forbidden_indices, "[2]",
  )

  let source = wrapping_cut_test_new_node(
    graph,
    layers[0],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  let middle = wrapping_cut_test_new_node(
    graph,
    layers[1],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  let target = wrapping_cut_test_new_node(
    graph,
    layers[2],
    4.0,
    4.0,
    0.0,
    0.0,
    0.0,
    0.0,
  )
  ignore(wrapping_cut_test_connect(source, middle))
  ignore(wrapping_cut_test_connect(middle, target))

  let graph_stats = new_graph_stats(graph)
  assert_false(graph_stats.is_cut_allowed(1))
  assert_false(graph_stats.is_cut_allowed(2))
}

///|
test "graph stats adds origin height for north south port incoming edges" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(2)
  graph.set_property_double(@core.spacing_node_node, 0.0)

  let origin = wrapping_cut_test_new_node(
    graph,
    layers[0],
    1.0,
    4.0,
    2.0,
    0.0,
    3.0,
    0.0,
  )
  let north_south_port = wrapping_cut_test_new_node(
    graph,
    layers[0],
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    node_type=Some(wrapping_cut_test_node_type("NORTH_SOUTH_PORT")),
  )
  north_south_port.set_property_l_node(
    internal_properties_origin_l_node,
    Some(origin),
  )

  let target = wrapping_cut_test_new_node(
    graph,
    layers[1],
    1.0,
    5.0,
    1.0,
    0.0,
    1.0,
    0.0,
  )
  ignore(wrapping_cut_test_connect(north_south_port, target))

  let graph_stats = new_graph_stats(graph)
  assert_eq(graph_stats.get_approximate_layer_height(layers[1]), 16.0)
}

///|
test "manual cut calculator reads manually configured cuts and defaults to empty" {
  let (graph, layers) = wrapping_cut_test_new_graph_with_layers(1)
  ignore(
    wrapping_cut_test_new_node(graph, layers[0], 1.0, 1.0, 0.0, 0.0, 0.0, 0.0),
  )
  graph.set_property_string(layered_options_wrapping_cutting_cuts, "[1, 3, 5]")

  let calculator = new_manual_cut_index_calculator()
  let graph_stats = new_graph_stats(graph)
  let cuts = calculator.get_cut_indexes(graph, graph_stats)
  assert_eq(cuts.length(), 3)
  assert_eq(cuts[0], 1)
  assert_eq(cuts[1], 3)
  assert_eq(cuts[2], 5)
  assert_false(calculator.guarantee_valid())

  let empty_graph = new_l_graph()
  let empty_graph_stats = new_graph_stats(empty_graph)
  let empty_cuts = calculator.get_cut_indexes(empty_graph, empty_graph_stats)
  assert_eq(empty_cuts.length(), 0)
}

///|
test "ard cut index heuristic computes chunk count and equidistant cuts" {
  let (graph, graph_stats) = wrapping_cut_test_new_uniform_graph_stats(4)
  let calculator = new_ard_cut_index_heuristic()
  let cuts = calculator.get_cut_indexes(graph, graph_stats)

  assert_eq(ard_cut_index_heuristic_get_chunk_count(graph_stats), 2)
  assert_eq(cuts.length(), 1)
  assert_eq(cuts[0], 2)
  assert_false(calculator.guarantee_valid())
}

///|
test "msd cut index heuristic optimizes cuts around the center" {
  let (graph, graph_stats) = wrapping_cut_test_new_uniform_graph_stats(4)
  graph.set_property_int(layered_options_wrapping_cutting_msd_freedom, 0)

  let calculator = new_msd_cut_index_heuristic()
  let cuts = calculator.get_cut_indexes(graph, graph_stats)
  assert_eq(cuts.length(), 1)
  assert_eq(cuts[0], 2)
  assert_false(calculator.guarantee_valid())
}
