///|
pub enum GraphTransformerMode {
  ToInternalLtr
  ToInputDirection
}

///|
fn graph_transformer_mirror_port_side_x(side : PortSide) -> PortSide {
  match side {
    PortSide::East => PortSide::West
    PortSide::West => PortSide::East
    _ => side
  }
}

///|
fn graph_transformer_mirror_port_side_y(side : PortSide) -> PortSide {
  match side {
    PortSide::North => PortSide::South
    PortSide::South => PortSide::North
    _ => side
  }
}

///|
fn graph_transformer_transpose_port_side(side : PortSide) -> PortSide {
  match side {
    PortSide::North => PortSide::West
    PortSide::West => PortSide::North
    PortSide::South => PortSide::East
    PortSide::East => PortSide::South
    PortSide::SideUndefined => PortSide::SideUndefined
  }
}

///|
fn graph_transformer_mirror_x_vector(v : KVector, offset : Double) -> Unit {
  v.x = offset - v.x
}

///|
fn graph_transformer_mirror_y_vector(v : KVector, offset : Double) -> Unit {
  v.y = offset - v.y
}

///|
fn graph_transformer_transpose_vector(v : KVector) -> Unit {
  let temp = v.x
  v.x = v.y
  v.y = temp
}

///|
fn graph_transformer_mirror_x_padding(padding_value : LPadding) -> Unit {
  let old_left = padding_value.left
  let old_right = padding_value.right
  padding_value.left = old_right
  padding_value.right = old_left
}

///|
fn graph_transformer_mirror_y_padding(padding_value : LPadding) -> Unit {
  let old_top = padding_value.top
  let old_bottom = padding_value.bottom
  padding_value.top = old_bottom
  padding_value.bottom = old_top
}

///|
fn graph_transformer_transpose_padding(padding_value : LPadding) -> Unit {
  let old_top = padding_value.top
  let old_bottom = padding_value.bottom
  let old_left = padding_value.left
  let old_right = padding_value.right
  padding_value.top = old_left
  padding_value.bottom = old_right
  padding_value.left = old_top
  padding_value.right = old_bottom
}

///|
fn graph_transformer_reverse_port_index(port : LPort) -> Unit {
  if !port.has_property_int(layered_options_port_index) {
    return
  }
  let index = port.get_property_int(layered_options_port_index)
  port.set_property_int(layered_options_port_index, -index)
}

///|
fn graph_transformer_mirror_layer_constraint_x(node : LNode) -> Unit {
  let current = node.get_property_string(
    layered_options_layering_layer_constraint,
  )
  if current == "FIRST" {
    node.set_property_string(layered_options_layering_layer_constraint, "LAST")
  } else if current == "FIRST_SEPARATE" {
    node.set_property_string(
      layered_options_layering_layer_constraint, "LAST_SEPARATE",
    )
  } else if current == "LAST" {
    node.set_property_string(layered_options_layering_layer_constraint, "FIRST")
  } else if current == "LAST_SEPARATE" {
    node.set_property_string(
      layered_options_layering_layer_constraint, "FIRST_SEPARATE",
    )
  }
}

///|
fn graph_transformer_mirror_in_layer_constraint_y(node : LNode) -> Unit {
  let current = node.get_property_string(
    internal_properties_in_layer_constraint,
  )
  if current == "TOP" {
    node.set_property_string(internal_properties_in_layer_constraint, "BOTTOM")
  } else if current == "BOTTOM" {
    node.set_property_string(internal_properties_in_layer_constraint, "TOP")
  }
}

///|
fn graph_transformer_transpose_layer_constraint(node : LNode) -> Unit {
  let layer_constraint = node.get_property_string(
    layered_options_layering_layer_constraint,
  )
  let in_layer_constraint = node.get_property_string(
    internal_properties_in_layer_constraint,
  )
  if layer_constraint == "FIRST_SEPARATE" {
    node.set_property_string(layered_options_layering_layer_constraint, "NONE")
    node.set_property_string(internal_properties_in_layer_constraint, "TOP")
  } else if layer_constraint == "LAST_SEPARATE" {
    node.set_property_string(layered_options_layering_layer_constraint, "NONE")
    node.set_property_string(internal_properties_in_layer_constraint, "BOTTOM")
  } else if in_layer_constraint == "TOP" {
    node.set_property_string(
      layered_options_layering_layer_constraint, "FIRST_SEPARATE",
    )
    node.set_property_string(internal_properties_in_layer_constraint, "NONE")
  } else if in_layer_constraint == "BOTTOM" {
    node.set_property_string(
      layered_options_layering_layer_constraint, "LAST_SEPARATE",
    )
    node.set_property_string(internal_properties_in_layer_constraint, "NONE")
  }
}

///|
fn graph_transformer_collect_nodes(layered_graph : LGraph) -> Array[LNode] {
  let nodes = []
  for node in layered_graph.get_layerless_nodes() {
    nodes.push(node)
  }
  for layer in layered_graph.get_layers() {
    for node in layer.get_nodes() {
      nodes.push(node)
    }
  }
  nodes
}

///|
fn graph_transformer_mirror_x(
  layered_graph : LGraph,
  nodes : Array[LNode],
) -> Unit {
  let graph_size = layered_graph.get_size()
  let graph_offset = layered_graph.get_offset()

  let mut offset = 0.0
  if graph_size.x == 0.0 {
    for node in nodes {
      let right = node.get_position().x +
        node.get_size().x +
        node.get_margin().right
      if right > offset {
        offset = right
      }
    }
  } else {
    offset = graph_size.x - graph_offset.x
  }
  offset = offset - graph_offset.x

  for node in nodes {
    let node_position = node.get_position()
    let node_size = node.get_size()
    let node_padding = node.get_padding()
    graph_transformer_mirror_x_vector(node_position, offset - node_size.x)
    graph_transformer_mirror_x_padding(node_padding)

    for port in node.get_ports() {
      let port_position = port.get_position()
      let port_size = port.get_size()
      let port_anchor = port.get_anchor()
      graph_transformer_mirror_x_vector(
        port_position,
        node_size.x - port_size.x,
      )
      graph_transformer_mirror_x_vector(port_anchor, port_size.x)
      port.set_side(graph_transformer_mirror_port_side_x(port.get_side()))
      graph_transformer_reverse_port_index(port)

      for edge in port.get_outgoing_edges() {
        for bend_point in edge.get_bend_points().to_array() {
          graph_transformer_mirror_x_vector(bend_point, offset)
        }
        if edge.has_property_kvector_chain(layered_options_junction_points) {
          let junction_points = edge.get_property_kvector_chain(
            layered_options_junction_points,
          )
          for point in junction_points.to_array() {
            graph_transformer_mirror_x_vector(point, offset)
          }
        }
        for label in edge.get_labels() {
          graph_transformer_mirror_x_vector(
            label.get_position(),
            offset - label.get_size().x,
          )
        }
      }

      for label in port.get_labels() {
        graph_transformer_mirror_x_vector(
          label.get_position(),
          port_size.x - label.get_size().x,
        )
      }
    }

    match node.get_type() {
      NodeType::ExternalPort => {
        node.set_property_port_side(
          internal_properties_ext_port_side,
          graph_transformer_mirror_port_side_x(
            node.get_property_port_side(internal_properties_ext_port_side),
          ),
        )
        graph_transformer_mirror_layer_constraint_x(node)
      }
      _ => ()
    }

    for label in node.get_labels() {
      graph_transformer_mirror_x_vector(
        label.get_position(),
        node_size.x - label.get_size().x,
      )
    }
  }

  graph_transformer_mirror_x_padding(layered_graph.get_padding())
}

///|
fn graph_transformer_mirror_y(
  layered_graph : LGraph,
  nodes : Array[LNode],
) -> Unit {
  let graph_size = layered_graph.get_size()
  let graph_offset = layered_graph.get_offset()

  let mut offset = 0.0
  if graph_size.y == 0.0 {
    for node in nodes {
      let bottom = node.get_position().y +
        node.get_size().y +
        node.get_margin().bottom
      if bottom > offset {
        offset = bottom
      }
    }
  } else {
    offset = graph_size.y - graph_offset.y
  }
  offset = offset - graph_offset.y

  for node in nodes {
    let node_position = node.get_position()
    let node_size = node.get_size()
    let node_padding = node.get_padding()
    graph_transformer_mirror_y_vector(node_position, offset - node_size.y)
    graph_transformer_mirror_y_padding(node_padding)

    for port in node.get_ports() {
      let port_position = port.get_position()
      let port_size = port.get_size()
      let port_anchor = port.get_anchor()
      graph_transformer_mirror_y_vector(
        port_position,
        node_size.y - port_size.y,
      )
      graph_transformer_mirror_y_vector(port_anchor, port_size.y)
      port.set_side(graph_transformer_mirror_port_side_y(port.get_side()))
      graph_transformer_reverse_port_index(port)

      for edge in port.get_outgoing_edges() {
        for bend_point in edge.get_bend_points().to_array() {
          graph_transformer_mirror_y_vector(bend_point, offset)
        }
        if edge.has_property_kvector_chain(layered_options_junction_points) {
          let junction_points = edge.get_property_kvector_chain(
            layered_options_junction_points,
          )
          for point in junction_points.to_array() {
            graph_transformer_mirror_y_vector(point, offset)
          }
        }
        for label in edge.get_labels() {
          graph_transformer_mirror_y_vector(
            label.get_position(),
            offset - label.get_size().y,
          )
        }
      }

      for label in port.get_labels() {
        graph_transformer_mirror_y_vector(
          label.get_position(),
          port_size.y - label.get_size().y,
        )
      }
    }

    match node.get_type() {
      NodeType::ExternalPort => {
        node.set_property_port_side(
          internal_properties_ext_port_side,
          graph_transformer_mirror_port_side_y(
            node.get_property_port_side(internal_properties_ext_port_side),
          ),
        )
        graph_transformer_mirror_in_layer_constraint_y(node)
      }
      _ => ()
    }

    for label in node.get_labels() {
      graph_transformer_mirror_y_vector(
        label.get_position(),
        node_size.y - label.get_size().y,
      )
    }
  }

  graph_transformer_mirror_y_padding(layered_graph.get_padding())
}

///|
fn graph_transformer_transpose(
  layered_graph : LGraph,
  nodes : Array[LNode],
) -> Unit {
  for node in nodes {
    graph_transformer_transpose_vector(node.get_position())
    graph_transformer_transpose_vector(node.get_size())
    graph_transformer_transpose_padding(node.get_padding())

    for port in node.get_ports() {
      graph_transformer_transpose_vector(port.get_position())
      graph_transformer_transpose_vector(port.get_anchor())
      graph_transformer_transpose_vector(port.get_size())
      port.set_side(graph_transformer_transpose_port_side(port.get_side()))
      graph_transformer_reverse_port_index(port)

      for edge in port.get_outgoing_edges() {
        for bend_point in edge.get_bend_points().to_array() {
          graph_transformer_transpose_vector(bend_point)
        }
        if edge.has_property_kvector_chain(layered_options_junction_points) {
          let junction_points = edge.get_property_kvector_chain(
            layered_options_junction_points,
          )
          for point in junction_points.to_array() {
            graph_transformer_transpose_vector(point)
          }
        }
        for label in edge.get_labels() {
          graph_transformer_transpose_vector(label.get_position())
          graph_transformer_transpose_vector(label.get_size())
        }
      }

      for label in port.get_labels() {
        graph_transformer_transpose_vector(label.get_position())
        graph_transformer_transpose_vector(label.get_size())
      }
    }

    match node.get_type() {
      NodeType::ExternalPort => {
        node.set_property_port_side(
          internal_properties_ext_port_side,
          graph_transformer_transpose_port_side(
            node.get_property_port_side(internal_properties_ext_port_side),
          ),
        )
        graph_transformer_transpose_layer_constraint(node)
      }
      _ => ()
    }

    for label in node.get_labels() {
      graph_transformer_transpose_vector(label.get_position())
      graph_transformer_transpose_vector(label.get_size())
    }
  }

  graph_transformer_transpose_vector(layered_graph.get_offset())
  graph_transformer_transpose_vector(layered_graph.get_size())
  graph_transformer_transpose_padding(layered_graph.get_padding())
}

///|
fn graph_transformer_rotate_90_clockwise(
  layered_graph : LGraph,
  nodes : Array[LNode],
) -> Unit {
  graph_transformer_transpose(layered_graph, nodes)
  graph_transformer_mirror_x(layered_graph, nodes)
}

///|
fn graph_transformer_rotate_90_counter_clockwise(
  layered_graph : LGraph,
  nodes : Array[LNode],
) -> Unit {
  graph_transformer_mirror_x(layered_graph, nodes)
  graph_transformer_transpose(layered_graph, nodes)
}

///|
fn graph_transformer_process_mode(
  layered_graph : LGraph,
  mode : GraphTransformerMode,
) -> Unit {
  let nodes = graph_transformer_collect_nodes(layered_graph)
  let direction_value = layered_graph.get_property_string(direction)

  match mode {
    GraphTransformerMode::ToInputDirection =>
      if direction_value == "LEFT" {
        graph_transformer_mirror_x(layered_graph, nodes)
        graph_transformer_mirror_y(layered_graph, nodes)
      } else if direction_value == "DOWN" {
        graph_transformer_rotate_90_counter_clockwise(layered_graph, nodes)
      } else if direction_value == "UP" {
        graph_transformer_rotate_90_clockwise(layered_graph, nodes)
      }
    GraphTransformerMode::ToInternalLtr =>
      if direction_value == "LEFT" {
        graph_transformer_mirror_x(layered_graph, nodes)
        graph_transformer_mirror_y(layered_graph, nodes)
      } else if direction_value == "DOWN" {
        graph_transformer_rotate_90_clockwise(layered_graph, nodes)
      } else if direction_value == "UP" {
        graph_transformer_rotate_90_counter_clockwise(layered_graph, nodes)
      }
  }
}

///|
fn graph_transformer_process(
  mode : GraphTransformerMode,
  layered_graph : LGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("Graph transformation", 1.0))
  graph_transformer_process_mode(layered_graph, mode)
  monitor.done()
}

///|
pub fn new_graph_transformer_layout_processor(
  mode : GraphTransformerMode,
) -> ILayoutProcessor[LayeredPhases, LGraph] {
  new_layout_processor((layered_graph, progress_monitor) => {
    graph_transformer_process(mode, layered_graph, progress_monitor)
  })
}

///|
pub fn new_direction_preprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_graph_transformer_layout_processor(GraphTransformerMode::ToInputDirection)
}

///|
pub fn new_direction_postprocessor_layout_processor() -> ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_graph_transformer_layout_processor(GraphTransformerMode::ToInternalLtr)
}
