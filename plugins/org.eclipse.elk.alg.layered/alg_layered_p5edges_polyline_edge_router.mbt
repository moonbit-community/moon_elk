///|
let polyline_edge_router_min_vert_diff : Double = 1.0

///|
let polyline_edge_router_layer_space_fac : Double = 0.4

///|
fn polyline_edge_router_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn polyline_edge_router_graph_properties_contain(
  properties : Array[GraphProperties],
  property : GraphProperties,
) -> Bool {
  for candidate in properties {
    if polyline_edge_router_graph_property_equals(candidate, property) {
      return true
    }
  }
  false
}

///|
fn polyline_edge_router_port_side_equals(
  left : PortSide,
  right : PortSide,
) -> Bool {
  match (left, right) {
    (SideUndefined, SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn polyline_edge_router_layer_equals(left : Layer?, right : Layer?) -> Bool {
  match (left, right) {
    (Some(left_layer), Some(right_layer)) =>
      left_layer.get_id() == right_layer.get_id()
    (None, None) => true
    _ => false
  }
}

///|
fn polyline_edge_router_node_type_is_north_south_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::NorthSouthPort => true
    _ => false
  }
}

///|
fn polyline_edge_router_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn polyline_edge_router_node_type_requires_processing(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::Normal => true
    NodeType::LabelNode => true
    NodeType::LongEdge => true
    NodeType::NorthSouthPort => true
    NodeType::BreakingPoint => true
    _ => false
  }
}

///|
fn polyline_edge_router_node_type_is_external_port(
  node_type : NodeType,
) -> Bool {
  match node_type {
    NodeType::ExternalPort => true
    _ => false
  }
}

///|
fn polyline_edge_router_port_equals(left : LPort?, right : LPort?) -> Bool {
  match (left, right) {
    (Some(left_port), Some(right_port)) =>
      left_port.get_handle() == right_port.get_handle()
    (None, None) => true
    _ => false
  }
}

///|
fn polyline_edge_router_contains_created_junction_point(
  created_junction_points : Array[KVector],
  point : KVector,
) -> Bool {
  for created in created_junction_points {
    if created.equals(point) {
      return true
    }
  }
  false
}

///|
pub fn polyline_edge_router_is_external_west_or_east_port(node : LNode) -> Bool {
  if !polyline_edge_router_node_type_is_external_port(node.get_type()) {
    return false
  }
  let ext_port_side = node.get_property_port_side(
    internal_properties_ext_port_side,
  )
  polyline_edge_router_port_side_equals(ext_port_side, West) ||
  polyline_edge_router_port_side_equals(ext_port_side, East)
}

///|
fn polyline_edge_router_all_external_west_or_east_ports(layer : Layer) -> Bool {
  for node in layer.get_nodes() {
    if !polyline_edge_router_is_external_west_or_east_port(node) {
      return false
    }
  }
  true
}

///|
fn polyline_edge_router_place_nodes_horizontally(
  layer : Layer,
  xoffset : Double,
) -> Unit {
  let mut max_left_margin = 0.0
  let mut max_right_margin = 0.0
  for node in layer.get_nodes() {
    let margin = node.get_margin()
    if margin.left > max_left_margin {
      max_left_margin = margin.left
    }
    if margin.right > max_right_margin {
      max_right_margin = margin.right
    }
  }

  for node in layer.get_nodes() {
    let alignment_value = node.get_property_string(alignment)
    let ratio = if alignment_value == "LEFT" {
      0.0
    } else if alignment_value == "RIGHT" {
      1.0
    } else if alignment_value == "CENTER" {
      0.5
    } else {
      let mut inports = 0
      let mut outports = 0
      for port in node.get_ports() {
        if !port.get_incoming_edges().is_empty() {
          inports += 1
        }
        if !port.get_outgoing_edges().is_empty() {
          outports += 1
        }
      }

      if inports + outports == 0 {
        0.5
      } else {
        outports.to_double() / (inports + outports).to_double()
      }
    }

    let size = layer.get_size()
    let node_size = node.get_size().x
    let mut xpos = (size.x - node_size) * ratio

    if ratio > 0.5 {
      xpos -= max_right_margin * 2.0 * (ratio - 0.5)
    } else if ratio < 0.5 {
      xpos += max_left_margin * 2.0 * (0.5 - ratio)
    }

    let left_margin = node.get_margin().left
    if xpos < left_margin {
      xpos = left_margin
    }

    let right_margin = node.get_margin().right
    if xpos > size.x - right_margin - node_size {
      xpos = size.x - right_margin - node_size
    }

    node.get_position().x = xoffset + xpos
  }
}

///|
let polyline_edge_router_baseline_processor_configuration : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor).add_before(
  LayeredPhases::P3NodeOrdering,
  layered_intermediate_processor_factory(
    IntermediateProcessorStrategy::InvertedPortProcessor,
  ),
)

///|
let polyline_edge_router_north_south_port_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P3NodeOrdering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::NorthSouthPortPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::NorthSouthPortPostprocessor,
    ),
  )

///|
let polyline_edge_router_self_loop_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P1CycleBreaking,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPostprocessor,
    ),
  )
  .before(LayeredPhases::P4NodePlacement)
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopPortRestorer,
    ),
  )
  .add(
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::SelfLoopRouter,
    ),
  )

///|
let polyline_edge_router_center_edge_label_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P2Layering,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummyInserter,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummySwitcher,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelSideSelector,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelDummyRemover,
    ),
  )

///|
let polyline_edge_router_end_edge_label_processing_additions : LayoutProcessorConfiguration[
  LayeredPhases,
  LGraph,
] = layout_processor_configuration_create(layered_phase_descriptor)
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::LabelSideSelector,
    ),
  )
  .add_before(
    LayeredPhases::P4NodePlacement,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EndLabelPreprocessor,
    ),
  )
  .add_after(
    LayeredPhases::P5EdgeRouting,
    layered_intermediate_processor_factory(
      IntermediateProcessorStrategy::EndLabelPostprocessor,
    ),
  )

///|
fn polyline_edge_router_configuration(
  graph : LGraph,
) -> LayoutProcessorConfiguration[LayeredPhases, LGraph]? {
  let graph_properties = graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )

  let configuration = layout_processor_configuration_create_from(
    polyline_edge_router_baseline_processor_configuration,
  )

  if polyline_edge_router_graph_properties_contain(
      graph_properties,
      NorthSouthPorts,
    ) {
    ignore(
      configuration.add_all(
        polyline_edge_router_north_south_port_processing_additions,
      ),
    )
  }

  if polyline_edge_router_graph_properties_contain(graph_properties, SelfLoops) {
    ignore(
      configuration.add_all(polyline_edge_router_self_loop_processing_additions),
    )
  }

  if polyline_edge_router_graph_properties_contain(
      graph_properties,
      CenterLabels,
    ) {
    ignore(
      configuration.add_all(
        polyline_edge_router_center_edge_label_processing_additions,
      ),
    )
  }

  if polyline_edge_router_graph_properties_contain(graph_properties, EndLabels) {
    ignore(
      configuration.add_all(
        polyline_edge_router_end_edge_label_processing_additions,
      ),
    )
  }

  Some(configuration)
}

///|
fn polyline_edge_router_process_node(
  node : LNode,
  layer_left_x_pos : Double,
  max_acceptable_x_diff : Double,
  created_junction_points : Array[KVector],
) -> Unit {
  let layer_right_x_pos = layer_left_x_pos +
    node.get_layer().unwrap().get_size().x

  for port in node.get_ports() {
    let absolute_port_anchor = port.get_absolute_anchor()

    if polyline_edge_router_node_type_is_north_south_port(node.get_type()) {
      if port.has_property_l_port(internal_properties_origin_l_port) {
        let corresponding_port = port.get_property_l_port(
          internal_properties_origin_l_port,
        )
        match corresponding_port {
          Some(origin_port) => {
            absolute_port_anchor.x = origin_port.get_absolute_anchor().x
            node.get_position().x = absolute_port_anchor.x
          }
          None => ()
        }
      }
    }

    let bend_point = new_kvector_xy(0.0, absolute_port_anchor.y)

    if polyline_edge_router_port_side_equals(port.get_side(), East) {
      bend_point.x = layer_right_x_pos
    } else if polyline_edge_router_port_side_equals(port.get_side(), West) {
      bend_point.x = layer_left_x_pos
    } else {
      continue
    }

    let x_distance = (absolute_port_anchor.x - bend_point.x).abs()
    if x_distance <= max_acceptable_x_diff &&
      !polyline_edge_router_is_in_layer_dummy(node) {
      continue
    }

    let add_junction_point = port.get_outgoing_edges().length() +
      port.get_incoming_edges().length() >
      1

    for edge in port.get_connected_edges() {
      let other_port = if polyline_edge_router_port_equals(
          edge.get_source(),
          Some(port),
        ) {
        edge.get_target().unwrap()
      } else {
        edge.get_source().unwrap()
      }

      if (other_port.get_absolute_anchor().y - bend_point.y).abs() >
        polyline_edge_router_min_vert_diff {
        polyline_edge_router_add_bend_point(
          edge, bend_point, add_junction_point, port, created_junction_points,
        )
      }
    }
  }
}

///|
fn polyline_edge_router_process_in_layer_edge(
  edge : LEdge,
  layer_x_pos : Double,
  edge_spacing : Double,
) -> Unit {
  let source_port = edge.get_source().unwrap()
  let target_port = edge.get_target().unwrap()

  let source_anchor_y = source_port.get_absolute_anchor().y
  let mid_y = (source_anchor_y + target_port.get_absolute_anchor().y) / 2.0

  let bend_point = if polyline_edge_router_port_side_equals(
      source_port.get_side(),
      East,
    ) {
    new_kvector_xy(
      layer_x_pos +
      source_port.get_node().unwrap().get_layer().unwrap().get_size().x +
      edge_spacing,
      mid_y,
    )
  } else {
    new_kvector_xy(layer_x_pos - edge_spacing, mid_y)
  }

  edge.get_bend_points().add_first_vector(bend_point)
}

///|
fn polyline_edge_router_calculate_west_in_layer_edge_ydiff(
  layer : Layer,
) -> Double {
  let mut max_y_diff = 0.0

  for node in layer.get_nodes() {
    for outgoing_edge in node.get_outgoing_edges() {
      let target_layer = outgoing_edge
        .get_target()
        .unwrap()
        .get_node()
        .unwrap()
        .get_layer()
      if polyline_edge_router_layer_equals(Some(layer), target_layer) &&
        polyline_edge_router_port_side_equals(
          outgoing_edge.get_source().unwrap().get_side(),
          West,
        ) {
        let source_pos = outgoing_edge
          .get_source()
          .unwrap()
          .get_absolute_anchor().y
        let target_pos = outgoing_edge
          .get_target()
          .unwrap()
          .get_absolute_anchor().y
        let y_diff = (target_pos - source_pos).abs()
        if y_diff > max_y_diff {
          max_y_diff = y_diff
        }
      }
    }
  }

  max_y_diff
}

///|
fn polyline_edge_router_add_bend_point(
  edge : LEdge,
  bend_point : KVector,
  add_junction_point : Bool,
  curr_port : LPort,
  created_junction_points : Array[KVector],
) -> Unit {
  if (
      edge.is_in_layer_edge() ||
      !curr_port.get_absolute_anchor().equals(bend_point)
    ) &&
    !edge.is_self_loop() {
    if polyline_edge_router_port_equals(edge.get_source(), Some(curr_port)) {
      edge.get_bend_points().add_first_vector(new_kvector_copy(bend_point))
    } else {
      edge.get_bend_points().add_vector(new_kvector_copy(bend_point))
    }

    if add_junction_point &&
      !polyline_edge_router_contains_created_junction_point(
        created_junction_points, bend_point,
      ) {
      let junction_points = if edge.has_property_kvector_chain(
          layered_options_junction_points,
        ) {
        edge.get_property_kvector_chain(layered_options_junction_points)
      } else {
        let chain = new_kvector_chain()
        edge.set_property_kvector_chain(layered_options_junction_points, chain)
        chain
      }

      let junction_point = new_kvector_copy(bend_point)
      junction_points.add_vector(junction_point)
      created_junction_points.push(junction_point)
    }
  }
}

///|
fn polyline_edge_router_is_in_layer_dummy(node : LNode) -> Bool {
  if polyline_edge_router_node_type_is_long_edge(node.get_type()) {
    for edge in node.get_connected_edges() {
      if edge.is_in_layer_edge() {
        return true
      }
    }
  }
  false
}

///|
fn polyline_edge_router_process(
  layered_graph : LGraph,
  monitor : IElkProgressMonitor?,
) -> Unit {
  let actual_monitor = match monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(actual_monitor.begin("Polyline edge routing", 1.0))

  let sloped_edge_zone_width = layered_graph.get_property_double(
    layered_options_edge_routing_polyline_sloped_edge_zone_width,
  )
  let node_spacing = layered_graph.get_property_double(
    layered_options_spacing_node_node_between_layers,
  )
  let edge_spacing = layered_graph.get_property_double(
    layered_options_spacing_edge_edge_between_layers,
  )
  let edge_space_fac = if edge_spacing / node_spacing < 1.0 {
    edge_spacing / node_spacing
  } else {
    1.0
  }

  let created_junction_points = []

  let mut xpos = 0.0
  let mut layer_spacing = 0.0

  let layers = layered_graph.get_layers()
  if !layers.is_empty() {
    let y_diff = polyline_edge_router_calculate_west_in_layer_edge_ydiff(
      layers[0],
    )
    xpos = polyline_edge_router_layer_space_fac * edge_space_fac * y_diff
  }

  for layer_index in 0..<layers.length() {
    let layer = layers[layer_index]
    let external_layer = polyline_edge_router_all_external_west_or_east_ports(
      layer,
    )

    if external_layer && xpos > 0.0 {
      xpos -= node_spacing
    }

    polyline_edge_router_place_nodes_horizontally(layer, xpos)

    let mut max_vert_diff = 0.0

    for node in layer.get_nodes() {
      let mut max_curr_output_y_diff = 0.0
      for outgoing_edge in node.get_outgoing_edges() {
        let mut source_pos = outgoing_edge
          .get_source()
          .unwrap()
          .get_absolute_anchor().y
        let mut target_pos = outgoing_edge
          .get_target()
          .unwrap()
          .get_absolute_anchor().y

        let target_layer = outgoing_edge
          .get_target()
          .unwrap()
          .get_node()
          .unwrap()
          .get_layer()
        if polyline_edge_router_layer_equals(Some(layer), target_layer) &&
          !outgoing_edge.is_self_loop() {
          polyline_edge_router_process_in_layer_edge(
            outgoing_edge,
            xpos,
            polyline_edge_router_layer_space_fac *
            edge_space_fac *
            (source_pos - target_pos).abs(),
          )

          if polyline_edge_router_port_side_equals(
              outgoing_edge.get_source().unwrap().get_side(),
              West,
            ) {
            source_pos = 0.0
            target_pos = 0.0
          }
        }

        let current_diff = (target_pos - source_pos).abs()
        if current_diff > max_curr_output_y_diff {
          max_curr_output_y_diff = current_diff
        }
      }

      if polyline_edge_router_node_type_requires_processing(node.get_type()) {
        polyline_edge_router_process_node(
          node, xpos, sloped_edge_zone_width, created_junction_points,
        )
      }

      if max_curr_output_y_diff > max_vert_diff {
        max_vert_diff = max_curr_output_y_diff
      }
    }

    if layer_index + 1 < layers.length() {
      let y_diff = polyline_edge_router_calculate_west_in_layer_edge_ydiff(
        layers[layer_index + 1],
      )
      if y_diff > max_vert_diff {
        max_vert_diff = y_diff
      }
    }

    layer_spacing = polyline_edge_router_layer_space_fac *
      edge_space_fac *
      max_vert_diff
    if !external_layer && layer_index + 1 < layers.length() {
      layer_spacing += node_spacing
    }

    xpos += layer.get_size().x + layer_spacing
  }

  created_junction_points.clear()
  layered_graph.get_size().x = xpos
  actual_monitor.done()
}

///|
pub fn new_polyline_edge_router_layout_phase() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_phase(
    polyline_edge_router_process, polyline_edge_router_configuration,
  )
}
