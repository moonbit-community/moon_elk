///|
fn label_side_selector_parse_mode(value : String) -> EdgeLabelSideSelection {
  match value {
    "ALWAYS_UP" => EdgeLabelSideSelection::AlwaysUp
    "ALWAYS_DOWN" => EdgeLabelSideSelection::AlwaysDown
    "DIRECTION_UP" => EdgeLabelSideSelection::DirectionUp
    "DIRECTION_DOWN" => EdgeLabelSideSelection::DirectionDown
    "SMART_UP" => EdgeLabelSideSelection::SmartUp
    _ => EdgeLabelSideSelection::SmartDown
  }
}

///|
fn label_side_selector_node_type_is_label(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LabelNode => true
    _ => false
  }
}

///|
fn label_side_selector_node_type_is_long_edge(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::LongEdge => true
    _ => false
  }
}

///|
fn label_side_selector_node_type_is_normal(node_type : NodeType) -> Bool {
  match node_type {
    NodeType::Normal => true
    _ => false
  }
}

///|
fn label_side_selector_label_side_is_below(side : @core.LabelSide) -> Bool {
  match side {
    @core.LabelSide::Below => true
    _ => false
  }
}

///|
fn label_side_selector_label_side_is_above(side : @core.LabelSide) -> Bool {
  match side {
    @core.LabelSide::Above => true
    _ => false
  }
}

///|
fn label_side_selector_node_option_equals(
  left : LNode?,
  right : LNode?,
) -> Bool {
  match (left, right) {
    (Some(l), Some(r)) => l.get_handle() == r.get_handle()
    (None, None) => true
    _ => false
  }
}

///|
fn label_side_selector_port_option_equals(
  left : LPort?,
  right : LPort?,
) -> Bool {
  match (left, right) {
    (Some(l), Some(r)) => l.get_handle() == r.get_handle()
    (None, None) => true
    _ => false
  }
}

///|
fn label_side_selector_port_side_option_equals(
  left : @core.PortSide?,
  right : @core.PortSide?,
) -> Bool {
  match (left, right) {
    (Some(@core.PortSide::SideUndefined), Some(@core.PortSide::SideUndefined)) =>
      true
    (Some(@core.PortSide::North), Some(@core.PortSide::North)) => true
    (Some(@core.PortSide::East), Some(@core.PortSide::East)) => true
    (Some(@core.PortSide::South), Some(@core.PortSide::South)) => true
    (Some(@core.PortSide::West), Some(@core.PortSide::West)) => true
    (None, None) => true
    _ => false
  }
}

///|
fn label_side_selector_port_side_is_north_or_east(
  side : @core.PortSide,
) -> Bool {
  match side {
    @core.PortSide::North => true
    @core.PortSide::East => true
    _ => false
  }
}

///|
fn label_side_selector_require_origin_edge(label_dummy : LNode) -> LEdge {
  match label_dummy.get_property_l_edge(internal_properties_origin_l_edge) {
    Some(value) => value
    None => abort("label dummy has no origin edge")
  }
}

///|
fn label_side_selector_require_first_incoming_edge(
  label_dummy : LNode,
) -> LEdge {
  let incoming = label_dummy.get_incoming_edges()
  if incoming.is_empty() {
    abort("label dummy has no incoming edge")
  }
  incoming[0]
}

///|
fn label_side_selector_require_first_outgoing_edge(
  label_dummy : LNode,
) -> LEdge {
  let outgoing = label_dummy.get_outgoing_edges()
  if outgoing.is_empty() {
    abort("label dummy has no outgoing edge")
  }
  outgoing[0]
}

///|
fn label_side_selector_apply_label_side_to_node(
  label_dummy : LNode,
  side : @core.LabelSide,
) -> Unit {
  if !label_side_selector_node_type_is_label(label_dummy.get_type()) {
    return
  }

  let effective_side = if label_dummy.is_inline_edge_label() {
    @core.LabelSide::Inline
  } else {
    side
  }

  label_dummy.set_property_label_side(
    internal_properties_label_side, effective_side,
  )

  if !label_side_selector_label_side_is_below(effective_side) {
    let origin_edge = label_side_selector_require_origin_edge(label_dummy)
    let thickness = origin_edge.get_property_double(@core.edge_thickness)

    let mut port_pos = 0.0
    if label_side_selector_label_side_is_above(effective_side) {
      port_pos = label_dummy.get_size().y - (thickness / 2.0).ceil()
    } else {
      port_pos = (label_dummy.get_size().y -
        label_dummy.get_graph().get_property_double(@core.spacing_edge_label) -
        thickness).ceil() /
        2.0
      label_dummy.get_size().y = label_dummy.get_size().y -
        label_dummy.get_graph().get_property_double(@core.spacing_edge_label)
      label_dummy.get_size().y = label_dummy.get_size().y - thickness
    }

    for port in label_dummy.get_ports() {
      port.get_position().y = port_pos
    }
  }
}

///|
fn label_side_selector_apply_label_side_to_edge(
  edge : LEdge,
  side : @core.LabelSide,
) -> Unit {
  for label in edge.get_labels() {
    label.set_property_label_side(internal_properties_label_side, side)
  }
}

///|
fn label_side_selector_apply_label_side_to_label_list(
  labels : Array[LLabel],
  side : @core.LabelSide,
) -> Unit {
  for label in labels {
    label.set_property_label_side(internal_properties_label_side, side)
  }
}

///|
fn label_side_selector_does_edge_point_right(edge : LEdge) -> Bool {
  !edge.get_property_bool(internal_properties_reversed)
}

///|
fn label_side_selector_does_dummy_edge_point_right(label_dummy : LNode) -> Bool {
  let incoming = label_side_selector_require_first_incoming_edge(label_dummy)
  let outgoing = label_side_selector_require_first_outgoing_edge(label_dummy)
  label_side_selector_does_edge_point_right(incoming) ||
  label_side_selector_does_edge_point_right(outgoing)
}

///|
fn label_side_selector_get_long_edge_end_node(
  label_dummy : LNode,
  source : Bool,
) -> LNode? {
  let end_port = if source {
    label_dummy.get_property_l_port(internal_properties_long_edge_source)
  } else {
    label_dummy.get_property_l_port(internal_properties_long_edge_target)
  }

  match end_port {
    Some(port) => port.get_node()
    None => None
  }
}

///|
fn label_side_selector_apply_label_sides_to_label_dummy_run(
  label_dummy_run : Array[LNode],
  default_side : @core.LabelSide,
) -> Unit {
  if label_dummy_run.is_empty() {
    return
  }

  if label_dummy_run.length() == 2 {
    label_side_selector_apply_label_side_to_node(
      label_dummy_run[0],
      @core.LabelSide::Above,
    )
    label_side_selector_apply_label_side_to_node(
      label_dummy_run[1],
      @core.LabelSide::Below,
    )
  } else {
    for dummy_node in label_dummy_run {
      label_side_selector_apply_label_side_to_node(dummy_node, default_side)
    }
  }

  label_dummy_run.clear()
}

///|
fn label_side_selector_apply_for_dummy_node_run_with_simple_loops(
  dummy_nodes : Array[LNode],
  label_dummy_count : Int,
  default_side : @core.LabelSide,
) -> Unit {
  ignore(label_dummy_count)

  let label_dummy_run : Array[LNode] = []
  let mut prev_long_edge_source : LNode? = None
  let mut prev_long_edge_target : LNode? = None

  for current_dummy in dummy_nodes {
    let curr_long_edge_source = label_side_selector_get_long_edge_end_node(
      current_dummy, true,
    )
    let curr_long_edge_target = label_side_selector_get_long_edge_end_node(
      current_dummy, false,
    )

    if !label_side_selector_node_option_equals(
        prev_long_edge_source, curr_long_edge_source,
      ) ||
      !label_side_selector_node_option_equals(
        prev_long_edge_target, curr_long_edge_target,
      ) {
      label_side_selector_apply_label_sides_to_label_dummy_run(
        label_dummy_run, default_side,
      )
      prev_long_edge_source = curr_long_edge_source
      prev_long_edge_target = curr_long_edge_target
    }

    if label_side_selector_node_type_is_label(current_dummy.get_type()) {
      label_dummy_run.push(current_dummy)
    }
  }

  label_side_selector_apply_label_sides_to_label_dummy_run(
    label_dummy_run, default_side,
  )
}

///|
fn label_side_selector_smart_for_consecutive_dummy_node_run(
  dummy_nodes : Array[LNode],
  label_dummy_count : Int,
  top_group : Bool,
  bottom_group : Bool,
  default_side : @core.LabelSide,
) -> Unit {
  if dummy_nodes.is_empty() {
    return
  }

  if top_group &&
    (!bottom_group || dummy_nodes.length() > 1) &&
    label_dummy_count == 1 &&
    label_side_selector_node_type_is_label(dummy_nodes[0].get_type()) {
    label_side_selector_apply_label_side_to_node(
      dummy_nodes[0],
      @core.LabelSide::Above,
    )
  } else if bottom_group &&
    (!top_group || dummy_nodes.length() > 1) &&
    label_dummy_count == 1 &&
    label_side_selector_node_type_is_label(
      dummy_nodes[dummy_nodes.length() - 1].get_type(),
    ) {
    label_side_selector_apply_label_side_to_node(
      dummy_nodes[dummy_nodes.length() - 1],
      @core.LabelSide::Below,
    )
  } else if dummy_nodes.length() == 2 {
    label_side_selector_apply_label_side_to_node(
      dummy_nodes[0],
      @core.LabelSide::Above,
    )
    label_side_selector_apply_label_side_to_node(
      dummy_nodes[1],
      @core.LabelSide::Below,
    )
  } else {
    label_side_selector_apply_for_dummy_node_run_with_simple_loops(
      dummy_nodes, label_dummy_count, default_side,
    )
  }

  dummy_nodes.clear()
}

///|
fn label_side_selector_edge_source_is_port(edge : LEdge, port : LPort) -> Bool {
  match edge.get_source() {
    Some(source_port) => source_port.get_handle() == port.get_handle()
    None => false
  }
}

///|
fn label_side_selector_gather_labels_for_port(
  port : LPort,
  target_list : Array[LLabel],
) -> Bool {
  let mut has_incident_edge = false

  for incident_edge in port.get_connected_edges() {
    has_incident_edge = true

    if label_side_selector_edge_source_is_port(incident_edge, port) {
      for label in incident_edge.get_labels() {
        if label.get_property_string(@core.edge_labels_placement) == "TAIL" {
          if !label.has_property_l_edge(internal_properties_end_label_edge) {
            label.set_property_l_edge(
              internal_properties_end_label_edge,
              Some(incident_edge),
            )
          }
          target_list.push(label)
        }
      }
    } else {
      for label in incident_edge.get_labels() {
        if label.get_property_string(@core.edge_labels_placement) == "HEAD" {
          if !label.has_property_l_edge(internal_properties_end_label_edge) {
            label.set_property_l_edge(
              internal_properties_end_label_edge,
              Some(incident_edge),
            )
          }
          target_list.push(label)
        }
      }
    }
  }

  has_incident_edge
}

///|
fn label_side_selector_gather_labels(port : LPort) -> Array[LLabel]? {
  let labels : Array[LLabel] = []
  let mut has_incident_edge = label_side_selector_gather_labels_for_port(
    port, labels,
  )

  match port.get_property_l_node(internal_properties_port_dummy) {
    Some(dummy_node) =>
      for dummy_port in dummy_node.get_ports() {
        let origin_port = dummy_port.get_property_l_port(
          internal_properties_origin_l_port,
        )
        if label_side_selector_port_option_equals(origin_port, Some(port)) {
          if label_side_selector_gather_labels_for_port(dummy_port, labels) {
            has_incident_edge = true
          }
        }
      }
    None => ()
  }

  if has_incident_edge {
    Some(labels)
  } else {
    None
  }
}

///|
fn label_side_selector_smart_for_regular_node_port_end_labels(
  end_label_queue : Array[Array[LLabel]],
  port_side : @core.PortSide,
  default_side : @core.LabelSide,
) -> Unit {
  if end_label_queue.length() == 2 {
    if label_side_selector_port_side_is_north_or_east(port_side) {
      label_side_selector_apply_label_side_to_label_list(
        end_label_queue[0],
        @core.LabelSide::Above,
      )
      label_side_selector_apply_label_side_to_label_list(
        end_label_queue[1],
        @core.LabelSide::Below,
      )
    } else {
      label_side_selector_apply_label_side_to_label_list(
        end_label_queue[0],
        @core.LabelSide::Below,
      )
      label_side_selector_apply_label_side_to_label_list(
        end_label_queue[1],
        @core.LabelSide::Above,
      )
    }
  } else {
    for label_list in end_label_queue {
      label_side_selector_apply_label_side_to_label_list(
        label_list, default_side,
      )
    }
  }
}

///|
fn label_side_selector_smart_for_regular_node(
  node : LNode,
  default_side : @core.LabelSide,
) -> Unit {
  let end_label_queue : Array[Array[LLabel]] = []
  let mut current_port_side : @core.PortSide? = None

  for port in node.get_ports() {
    if !label_side_selector_port_side_option_equals(
        current_port_side,
        Some(port.get_side()),
      ) {
      if !end_label_queue.is_empty() {
        match current_port_side {
          Some(side) =>
            label_side_selector_smart_for_regular_node_port_end_labels(
              end_label_queue, side, default_side,
            )
          None => ()
        }
      }

      end_label_queue.clear()
      current_port_side = Some(port.get_side())
    }

    match label_side_selector_gather_labels(port) {
      Some(port_end_labels) => end_label_queue.push(port_end_labels)
      None => ()
    }
  }

  if !end_label_queue.is_empty() {
    match current_port_side {
      Some(side) =>
        label_side_selector_smart_for_regular_node_port_end_labels(
          end_label_queue, side, default_side,
        )
      None => ()
    }
  }
}

///|
fn label_side_selector_same_side(
  graph : LGraph,
  label_side : @core.LabelSide,
) -> Unit {
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if label_side_selector_node_type_is_label(node.get_type()) {
        label_side_selector_apply_label_side_to_node(node, label_side)
      }

      for edge in node.get_outgoing_edges() {
        label_side_selector_apply_label_side_to_edge(edge, label_side)
      }
    }
  }
}

///|
fn label_side_selector_based_on_direction(
  graph : LGraph,
  side_for_rightward_edges : @core.LabelSide,
) -> Unit {
  for layer in graph.get_layers() {
    for node in layer.get_nodes() {
      if label_side_selector_node_type_is_label(node.get_type()) {
        let side = if label_side_selector_does_dummy_edge_point_right(node) {
          side_for_rightward_edges
        } else {
          @core.LabelSide::opposite(side_for_rightward_edges)
        }
        label_side_selector_apply_label_side_to_node(node, side)
      }

      for edge in node.get_outgoing_edges() {
        let side = if label_side_selector_does_edge_point_right(edge) {
          side_for_rightward_edges
        } else {
          @core.LabelSide::opposite(side_for_rightward_edges)
        }
        label_side_selector_apply_label_side_to_edge(edge, side)
      }
    }
  }
}

///|
fn label_side_selector_smart(
  graph : LGraph,
  default_side : @core.LabelSide,
) -> Unit {
  let dummy_node_queue : Array[LNode] = []

  for layer in graph.get_layers() {
    let mut top_group = true
    let mut label_dummies_in_queue = 0

    for node in layer.get_nodes() {
      if label_side_selector_node_type_is_label(node.get_type()) {
        label_dummies_in_queue = label_dummies_in_queue + 1
        dummy_node_queue.push(node)
        continue
      }

      if label_side_selector_node_type_is_long_edge(node.get_type()) {
        dummy_node_queue.push(node)
        continue
      }

      if label_side_selector_node_type_is_normal(node.get_type()) {
        label_side_selector_smart_for_regular_node(node, default_side)
      }

      if !dummy_node_queue.is_empty() {
        label_side_selector_smart_for_consecutive_dummy_node_run(
          dummy_node_queue, label_dummies_in_queue, top_group, false, default_side,
        )
      }

      top_group = false
      label_dummies_in_queue = 0
    }

    if !dummy_node_queue.is_empty() {
      label_side_selector_smart_for_consecutive_dummy_node_run(
        dummy_node_queue, label_dummies_in_queue, top_group, true, default_side,
      )
    }
  }
}

///|
fn label_side_selector_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }

  let mode = label_side_selector_parse_mode(
    layered_graph.get_property_string(
      layered_options_edge_labels_side_selection,
    ),
  )
  ignore(
    monitor.begin(
      "Label side selection (" + edge_label_side_selection_to_string(mode) + ")",
      1.0,
    ),
  )

  match mode {
    EdgeLabelSideSelection::AlwaysUp =>
      label_side_selector_same_side(layered_graph, @core.LabelSide::Above)
    EdgeLabelSideSelection::AlwaysDown =>
      label_side_selector_same_side(layered_graph, @core.LabelSide::Below)
    EdgeLabelSideSelection::DirectionUp =>
      label_side_selector_based_on_direction(
        layered_graph,
        @core.LabelSide::Above,
      )
    EdgeLabelSideSelection::DirectionDown =>
      label_side_selector_based_on_direction(
        layered_graph,
        @core.LabelSide::Below,
      )
    EdgeLabelSideSelection::SmartUp =>
      label_side_selector_smart(layered_graph, @core.LabelSide::Above)
    EdgeLabelSideSelection::SmartDown =>
      label_side_selector_smart(layered_graph, @core.LabelSide::Below)
  }

  monitor.done()
}

///|
pub fn new_label_side_selector_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(label_side_selector_process)
}
