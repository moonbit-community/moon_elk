///|
fn comment_postprocessor_max(a : Double, b : Double) -> Double {
  if a >= b {
    a
  } else {
    b
  }
}

///|
fn comment_postprocessor_get_box_port(comment_box : LNode) -> LPort? {
  let node_port = comment_box.get_property_l_port(
    internal_properties_comment_conn_port,
  )
  for port in comment_box.get_ports() {
    for edge in port.get_outgoing_edges() {
      edge.set_target(node_port)
      return Some(port)
    }
    for edge in port.get_incoming_edges() {
      edge.set_source(node_port)
      return Some(port)
    }
  }
  None
}

///|
fn comment_postprocessor_process_node(
  node : LNode,
  top_boxes : Array[LNode]?,
  bottom_boxes : Array[LNode]?,
) -> Unit {
  let node_pos = node.get_position()
  let node_size = node.get_size()
  let margin = node.get_margin()

  let comment_comment_spacing = layered_spacings_get_individual_or_default(
    node, layered_options_spacing_comment_comment,
  )

  match top_boxes {
    Some(top_box_list) => {
      let mut boxes_width = comment_comment_spacing *
        (top_box_list.length() - 1).to_double()
      let mut max_height = 0.0
      for box in top_box_list {
        boxes_width = boxes_width + box.get_size().x
        max_height = comment_postprocessor_max(max_height, box.get_size().y)
      }

      let mut x = node_pos.x - (boxes_width - node_size.x) / 2.0
      let base_line = node_pos.y - margin.top + max_height
      let anchor_inc = node_size.x / (top_box_list.length() + 1).to_double()
      let mut anchor_x = anchor_inc
      for box in top_box_list {
        box.get_position().x = x
        box.get_position().y = base_line - box.get_size().y
        x = x + box.get_size().x + comment_comment_spacing

        match comment_postprocessor_get_box_port(box) {
          Some(box_port) => {
            box_port.get_position().x = box.get_size().x / 2.0 -
              box_port.get_anchor().x
            box_port.get_position().y = box.get_size().y

            match
              box.get_property_l_port(internal_properties_comment_conn_port) {
              Some(node_port) =>
                if node_port.get_degree() == 1 {
                  node_port.get_position().x = anchor_x -
                    node_port.get_anchor().x
                  node_port.get_position().y = 0.0
                  node_port.set_node(Some(node))
                }
              None => ()
            }
          }
          None => ()
        }

        anchor_x = anchor_x + anchor_inc
      }
    }
    None => ()
  }

  match bottom_boxes {
    Some(bottom_box_list) => {
      let mut boxes_width = comment_comment_spacing *
        (bottom_box_list.length() - 1).to_double()
      let mut max_height = 0.0
      for box in bottom_box_list {
        boxes_width = boxes_width + box.get_size().x
        max_height = comment_postprocessor_max(max_height, box.get_size().y)
      }

      let mut x = node_pos.x - (boxes_width - node_size.x) / 2.0
      let base_line = node_pos.y + node_size.y + margin.bottom - max_height
      let anchor_inc = node_size.x / (bottom_box_list.length() + 1).to_double()
      let mut anchor_x = anchor_inc
      for box in bottom_box_list {
        box.get_position().x = x
        box.get_position().y = base_line
        x = x + box.get_size().x + comment_comment_spacing

        match comment_postprocessor_get_box_port(box) {
          Some(box_port) => {
            box_port.get_position().x = box.get_size().x / 2.0 -
              box_port.get_anchor().x
            box_port.get_position().y = 0.0

            match
              box.get_property_l_port(internal_properties_comment_conn_port) {
              Some(node_port) =>
                if node_port.get_degree() == 1 {
                  node_port.get_position().x = anchor_x -
                    node_port.get_anchor().x
                  node_port.get_position().y = node_size.y
                  node_port.set_node(Some(node))
                }
              None => ()
            }
          }
          None => ()
        }

        anchor_x = anchor_x + anchor_inc
      }
    }
    None => ()
  }
}

///|
fn comment_postprocessor_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Comment post-processing", 1.0))

  for layer in layered_graph.get_layers() {
    let boxes : Array[LNode] = []
    for node in layer.get_nodes() {
      let top_boxes = if node.has_property_l_node_array(
          internal_properties_top_comments,
        ) {
        Some(node.get_property_l_node_array(internal_properties_top_comments))
      } else {
        None
      }
      let bottom_boxes = if node.has_property_l_node_array(
          internal_properties_bottom_comments,
        ) {
        Some(
          node.get_property_l_node_array(internal_properties_bottom_comments),
        )
      } else {
        None
      }
      let has_top = match top_boxes {
        Some(_) => true
        None => false
      }
      let has_bottom = match bottom_boxes {
        Some(_) => true
        None => false
      }

      if has_top || has_bottom {
        comment_postprocessor_process_node(node, top_boxes, bottom_boxes)
        match top_boxes {
          Some(top_box_list) =>
            for box in top_box_list {
              boxes.push(box)
            }
          None => ()
        }
        match bottom_boxes {
          Some(bottom_box_list) =>
            for box in bottom_box_list {
              boxes.push(box)
            }
          None => ()
        }
      }
    }

    for box in boxes {
      box.set_layer(Some(layer))
    }
  }

  monitor.done()
}

///|
pub fn new_comment_postprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(comment_postprocessor_process)
}
