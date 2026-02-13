///|
fn comment_node_margin_calculator_max(a : Double, b : Double) -> Double {
  if a >= b {
    a
  } else {
    b
  }
}

///|
fn comment_node_margin_calculator_process_comments(node : LNode) -> Unit {
  let margin = node.get_margin()

  let has_top = node.has_property_l_node_array(internal_properties_top_comments)
  let has_bottom = node.has_property_l_node_array(
    internal_properties_bottom_comments,
  )
  if !has_top && !has_bottom {
    return
  }

  let top_boxes = if has_top {
    node.get_property_l_node_array(internal_properties_top_comments)
  } else {
    []
  }
  let bottom_boxes = if has_bottom {
    node.get_property_l_node_array(internal_properties_bottom_comments)
  } else {
    []
  }

  let comment_comment_spacing = layered_spacings_get_individual_or_default(
    node, layered_options_spacing_comment_comment,
  )
  let comment_node_spacing = layered_spacings_get_individual_or_default(
    node, layered_options_spacing_comment_node,
  )

  let mut top_width = 0.0
  if has_top {
    let mut max_height = 0.0
    for comment_box in top_boxes {
      max_height = comment_node_margin_calculator_max(
        max_height,
        comment_box.get_size().y,
      )
      top_width = top_width + comment_box.get_size().x
    }
    top_width = top_width +
      comment_comment_spacing * (top_boxes.length() - 1).to_double()
    margin.top = margin.top + max_height + comment_node_spacing
  }

  let mut bottom_width = 0.0
  if has_bottom {
    let mut max_height = 0.0
    for comment_box in bottom_boxes {
      max_height = comment_node_margin_calculator_max(
        max_height,
        comment_box.get_size().y,
      )
      bottom_width = bottom_width + comment_box.get_size().x
    }
    bottom_width = bottom_width +
      comment_comment_spacing * (bottom_boxes.length() - 1).to_double()
    margin.bottom = margin.bottom + max_height + comment_node_spacing
  }

  let max_comment_width = comment_node_margin_calculator_max(
    top_width, bottom_width,
  )
  if max_comment_width > node.get_size().x {
    let protrusion = (max_comment_width - node.get_size().x) / 2.0
    margin.left = comment_node_margin_calculator_max(margin.left, protrusion)
    margin.right = comment_node_margin_calculator_max(margin.right, protrusion)
  }
}

///|
fn comment_node_margin_calculator_process(
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Node margin calculation", 1.0))

  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      comment_node_margin_calculator_process_comments(node)
    }
  }

  monitor.done()
}

///|
pub fn new_comment_node_margin_calculator_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_layout_processor(comment_node_margin_calculator_process)
}
