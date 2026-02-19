///|
fn comment_preprocessor_port_constraints_from_string(
  value : String,
) -> @core.PortConstraints {
  match value {
    "FREE" => @core.PortConstraints::Free
    "FIXED_SIDE" => @core.PortConstraints::FixedSide
    "FIXED_ORDER" => @core.PortConstraints::FixedOrder
    "FIXED_RATIO" => @core.PortConstraints::FixedRatio
    "FIXED_POS" => @core.PortConstraints::FixedPos
    _ => @core.PortConstraints::Undefined
  }
}

///|
fn comment_preprocessor_reverse_edge(edge : LEdge) -> Unit {
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
fn comment_preprocessor_port_equals(left : LPort?, right : LPort) -> Bool {
  match left {
    Some(port) => port.get_handle() == right.get_handle()
    None => false
  }
}

///|
fn comment_preprocessor_remove_hierarchical_port_dummy_node(
  opposite_port : LPort,
) -> Unit {
  match opposite_port.get_property_l_node(internal_properties_port_dummy) {
    Some(dummy) =>
      match dummy.get_layer() {
        Some(layer) => {
          dummy.set_layer(None)
          if layer.get_nodes().is_empty() {
            let layer_index = layer.get_index()
            if layer_index >= 0 {
              ignore(layer.get_graph().get_layers().remove(layer_index))
            }
          }
        }
        None => ()
      }
    None => ()
  }
}

///|
fn comment_preprocessor_process_box(
  box : LNode,
  edge : LEdge,
  opposite_port : LPort,
  real_node : LNode,
) -> Unit {
  let mut top_first = true
  let mut only_top = false
  let mut only_bottom = false

  let constraints = comment_preprocessor_port_constraints_from_string(
    real_node.get_property_string(@core.port_constraints),
  )
  if constraints.is_side_fixed() {
    let mut has_north = false
    let mut has_south = false
    for port1 in real_node.get_ports() {
      let mut break_loop = false
      for port2 in port1.get_connected_ports() {
        match port2.get_node() {
          Some(port2_node) =>
            if !port2_node.get_property_bool(layered_options_comment_box) {
              match port1.get_side() {
                @core.PortSide::North => {
                  has_north = true
                  break_loop = true
                }
                @core.PortSide::South => {
                  has_south = true
                  break_loop = true
                }
                _ => ()
              }
            }
          None => ()
        }
        if break_loop {
          break
        }
      }
      if break_loop {
        break
      }
    }
    only_top = has_south && !has_north
    only_bottom = has_north && !has_south
  }

  if !only_top && !only_bottom && !real_node.get_labels().is_empty() {
    let mut label_pos = 0.0
    for label in real_node.get_labels() {
      label_pos = label_pos + label.get_position().y + label.get_size().y / 2.0
    }
    label_pos = label_pos / real_node.get_labels().length().to_double()
    top_first = label_pos >= real_node.get_size().y / 2.0
  } else {
    top_first = !only_bottom
  }

  let mut box_list : Array[LNode] = []
  let mut use_top = false
  if top_first {
    if !real_node.has_property_l_node_array(internal_properties_top_comments) {
      box_list = []
      use_top = true
    } else {
      let top_boxes = real_node.get_property_l_node_array(
        internal_properties_top_comments,
      )
      if only_top {
        box_list = top_boxes
        use_top = true
      } else if !real_node.has_property_l_node_array(
          internal_properties_bottom_comments,
        ) {
        box_list = []
        use_top = false
      } else {
        let bottom_boxes = real_node.get_property_l_node_array(
          internal_properties_bottom_comments,
        )
        if top_boxes.length() <= bottom_boxes.length() {
          box_list = top_boxes
          use_top = true
        } else {
          box_list = bottom_boxes
          use_top = false
        }
      }
    }
  } else if !real_node.has_property_l_node_array(
      internal_properties_bottom_comments,
    ) {
    box_list = []
    use_top = false
  } else {
    let bottom_boxes = real_node.get_property_l_node_array(
      internal_properties_bottom_comments,
    )
    if only_bottom {
      box_list = bottom_boxes
      use_top = false
    } else if !real_node.has_property_l_node_array(
        internal_properties_top_comments,
      ) {
      box_list = []
      use_top = true
    } else {
      let top_boxes = real_node.get_property_l_node_array(
        internal_properties_top_comments,
      )
      if bottom_boxes.length() <= top_boxes.length() {
        box_list = bottom_boxes
        use_top = false
      } else {
        box_list = top_boxes
        use_top = true
      }
    }
  }

  box_list.push(box)
  if use_top {
    real_node.set_property_l_node_array(
      internal_properties_top_comments, box_list,
    )
  } else {
    real_node.set_property_l_node_array(
      internal_properties_bottom_comments, box_list,
    )
  }

  box.set_property_l_port(
    internal_properties_comment_conn_port,
    Some(opposite_port),
  )

  if comment_preprocessor_port_equals(edge.get_target(), opposite_port) {
    edge.set_target(None)
    if opposite_port.get_degree() == 0 {
      opposite_port.set_node(None)
    }
    comment_preprocessor_remove_hierarchical_port_dummy_node(opposite_port)
  } else {
    edge.set_source(None)
    if opposite_port.get_degree() == 0 {
      opposite_port.set_node(None)
    }
  }
  edge.get_bend_points().clear()
}

///|
fn comment_preprocessor_process(
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Comment pre-processing", 1.0))

  let mut comment_box_count = 0
  let layerless_nodes = layered_graph.get_layerless_nodes()

  let mut node_index = 0
  while node_index < layerless_nodes.length() {
    let node = layerless_nodes[node_index]
    if node.get_property_bool(layered_options_comment_box) {
      comment_box_count = comment_box_count + 1

      let mut edge_count = 0
      let mut edge : LEdge? = None
      let mut opposite_port : LPort? = None
      for port in node.get_ports() {
        edge_count = edge_count + port.get_degree()
        if port.get_incoming_edges().length() == 1 {
          edge = Some(port.get_incoming_edges()[0])
          opposite_port = port.get_incoming_edges()[0].get_source()
        }
        if port.get_outgoing_edges().length() == 1 {
          edge = Some(port.get_outgoing_edges()[0])
          opposite_port = port.get_outgoing_edges()[0].get_target()
        }
      }

      let mut processed = false
      if edge_count == 1 {
        match (edge, opposite_port) {
          (Some(single_edge), Some(opposite)) =>
            match opposite.get_node() {
              Some(real_node) =>
                if opposite.get_degree() == 1 &&
                  !real_node.get_property_bool(layered_options_comment_box) {
                  comment_preprocessor_process_box(
                    node, single_edge, opposite, real_node,
                  )
                  ignore(layerless_nodes.remove(node_index))
                  processed = true
                }
              None => ()
            }
          _ => ()
        }
      }

      if processed {
        continue
      }

      let rev_edges : Array[LEdge] = []
      for port in node.get_ports() {
        for outedge in port.get_outgoing_edges() {
          match outedge.get_target() {
            Some(target_port) =>
              if !target_port.get_outgoing_edges().is_empty() {
                rev_edges.push(outedge)
              }
            None => ()
          }
        }
        for inedge in port.get_incoming_edges() {
          match inedge.get_source() {
            Some(source_port) =>
              if !source_port.get_incoming_edges().is_empty() {
                rev_edges.push(inedge)
              }
            None => ()
          }
        }
      }

      for rev_edge in rev_edges {
        comment_preprocessor_reverse_edge(rev_edge)
      }
    }

    node_index = node_index + 1
  }

  if monitor.is_logging_enabled() {
    monitor.log("Found " + comment_box_count.to_string() + " comment boxes")
  }

  monitor.done()
}

///|
pub fn new_comment_preprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  @core.new_layout_processor(comment_preprocessor_process)
}
