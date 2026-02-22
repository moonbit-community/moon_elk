///|
pub enum GraphTransformerMode {
  ToInternalLtr
  ToInputDirection
}

///|
fn graph_transformer_mode_to_string(mode : GraphTransformerMode) -> String {
  match mode {
    GraphTransformerMode::ToInternalLtr => "TO_INTERNAL_LTR"
    GraphTransformerMode::ToInputDirection => "TO_INPUT_DIRECTION"
  }
}

///|
let graph_transformer_direction_congruency_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.layered.directionCongruency", "READING_DIRECTION",
)

///|
let graph_transformer_node_labels_padding_property : @graph.IProperty[String] = @graph.new_property(
  "org.eclipse.elk.nodeLabels.padding", "[top=5,left=5,bottom=5,right=5]",
)

///|
fn graph_transformer_parse_direction_congruency(
  value : String,
) -> DirectionCongruency {
  if value == "READING_DIRECTION" {
    DirectionCongruency::ReadingDirection
  } else {
    DirectionCongruency::Rotation
  }
}

///|
fn graph_transformer_get_direction_congruency_value(
  layered_graph : LGraph,
) -> String {
  layered_graph.get_property_string(
    graph_transformer_direction_congruency_property,
  )
}

///|
fn graph_transformer_parse_edge_label_side_selection(
  value : String,
) -> EdgeLabelSideSelection {
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
fn graph_transformer_mirror_port_side_x(
  side : @core.PortSide,
) -> @core.PortSide {
  match side {
    @core.PortSide::East => @core.PortSide::West
    @core.PortSide::West => @core.PortSide::East
    _ => side
  }
}

///|
fn graph_transformer_mirror_port_side_y(
  side : @core.PortSide,
) -> @core.PortSide {
  match side {
    @core.PortSide::North => @core.PortSide::South
    @core.PortSide::South => @core.PortSide::North
    _ => side
  }
}

///|
fn graph_transformer_transpose_port_side(
  side : @core.PortSide,
) -> @core.PortSide {
  match side {
    @core.PortSide::North => @core.PortSide::West
    @core.PortSide::West => @core.PortSide::North
    @core.PortSide::South => @core.PortSide::East
    @core.PortSide::East => @core.PortSide::South
    @core.PortSide::SideUndefined => @core.PortSide::SideUndefined
  }
}

///|
fn graph_transformer_mirror_x_vector(
  v : @core.KVector,
  offset : Double,
) -> Unit {
  v.x = offset - v.x
}

///|
fn graph_transformer_mirror_y_vector(
  v : @core.KVector,
  offset : Double,
) -> Unit {
  v.y = offset - v.y
}

///|
fn graph_transformer_transpose_vector(v : @core.KVector) -> Unit {
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
fn graph_transformer_contains_string(
  values : Array[String],
  needle : String,
) -> Bool {
  for value in values {
    if value == needle {
      return true
    }
  }
  false
}

///|
fn graph_transformer_add_unique_string(
  values : Array[String],
  value : String,
) -> Unit {
  if !graph_transformer_contains_string(values, value) {
    values.push(value)
  }
}

///|
fn graph_transformer_mirror_node_label_placement_x_values(
  values : Array[String],
) -> Array[String] {
  if graph_transformer_contains_string(values, "H_LEFT") {
    let mirrored = []
    for value in values {
      if value == "H_LEFT" {
        graph_transformer_add_unique_string(mirrored, "H_RIGHT")
      } else if value != "H_RIGHT" {
        graph_transformer_add_unique_string(mirrored, value)
      }
    }
    mirrored
  } else if graph_transformer_contains_string(values, "H_RIGHT") {
    let mirrored = []
    for value in values {
      if value == "H_RIGHT" {
        graph_transformer_add_unique_string(mirrored, "H_LEFT")
      } else if value != "H_LEFT" {
        graph_transformer_add_unique_string(mirrored, value)
      }
    }
    mirrored
  } else {
    values.copy()
  }
}

///|
fn graph_transformer_mirror_node_label_placement_y_values(
  values : Array[String],
) -> Array[String] {
  if graph_transformer_contains_string(values, "V_TOP") {
    let mirrored = []
    for value in values {
      if value == "V_TOP" {
        graph_transformer_add_unique_string(mirrored, "V_BOTTOM")
      } else if value != "V_BOTTOM" {
        graph_transformer_add_unique_string(mirrored, value)
      }
    }
    mirrored
  } else if graph_transformer_contains_string(values, "V_BOTTOM") {
    let mirrored = []
    for value in values {
      if value == "V_BOTTOM" {
        graph_transformer_add_unique_string(mirrored, "V_TOP")
      } else if value != "V_TOP" {
        graph_transformer_add_unique_string(mirrored, value)
      }
    }
    mirrored
  } else {
    values.copy()
  }
}

///|
fn graph_transformer_transpose_node_label_placement_values(
  values : Array[String],
) -> Array[String] {
  if values.is_empty() {
    return []
  }

  let transposed = []
  if graph_transformer_contains_string(values, "INSIDE") {
    graph_transformer_add_unique_string(transposed, "INSIDE")
  } else {
    graph_transformer_add_unique_string(transposed, "OUTSIDE")
  }

  if !graph_transformer_contains_string(values, "H_PRIORITY") {
    graph_transformer_add_unique_string(transposed, "H_PRIORITY")
  }

  if graph_transformer_contains_string(values, "H_LEFT") {
    graph_transformer_add_unique_string(transposed, "V_TOP")
  } else if graph_transformer_contains_string(values, "H_CENTER") {
    graph_transformer_add_unique_string(transposed, "V_CENTER")
  } else if graph_transformer_contains_string(values, "H_RIGHT") {
    graph_transformer_add_unique_string(transposed, "V_BOTTOM")
  }

  if graph_transformer_contains_string(values, "V_TOP") {
    graph_transformer_add_unique_string(transposed, "H_LEFT")
  } else if graph_transformer_contains_string(values, "V_CENTER") {
    graph_transformer_add_unique_string(transposed, "H_CENTER")
  } else if graph_transformer_contains_string(values, "V_BOTTOM") {
    graph_transformer_add_unique_string(transposed, "H_RIGHT")
  }

  transposed
}

///|
fn graph_transformer_mirror_node_label_placement_x_node(node : LNode) -> Unit {
  if !node.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = node.get_property_string_array(
    @core.node_labels_placement,
  )
  node.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_mirror_node_label_placement_x_values(old_placement),
  )
}

///|
fn graph_transformer_mirror_node_label_placement_x_label(
  label : LLabel,
) -> Unit {
  if !label.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = label.get_property_string_array(
    @core.node_labels_placement,
  )
  label.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_mirror_node_label_placement_x_values(old_placement),
  )
}

///|
fn graph_transformer_mirror_node_label_placement_y_node(node : LNode) -> Unit {
  if !node.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = node.get_property_string_array(
    @core.node_labels_placement,
  )
  node.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_mirror_node_label_placement_y_values(old_placement),
  )
}

///|
fn graph_transformer_mirror_node_label_placement_y_label(
  label : LLabel,
) -> Unit {
  if !label.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = label.get_property_string_array(
    @core.node_labels_placement,
  )
  label.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_mirror_node_label_placement_y_values(old_placement),
  )
}

///|
fn graph_transformer_transpose_node_label_placement_node(node : LNode) -> Unit {
  if !node.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = node.get_property_string_array(
    @core.node_labels_placement,
  )
  node.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_transpose_node_label_placement_values(old_placement),
  )
}

///|
fn graph_transformer_transpose_node_label_placement_label(
  label : LLabel,
) -> Unit {
  if !label.has_property_string_array(@core.node_labels_placement) {
    return
  }
  let old_placement = label.get_property_string_array(
    @core.node_labels_placement,
  )
  label.set_property_string_array(
    @core.node_labels_placement,
    graph_transformer_transpose_node_label_placement_values(old_placement),
  )
}

///|
fn graph_transformer_mirror_alignment_x(node : LNode) -> Unit {
  let old_alignment = node.get_property_string(@core.alignment)
  if old_alignment == "LEFT" {
    node.set_property_string(@core.alignment, "RIGHT")
  } else if old_alignment == "RIGHT" {
    node.set_property_string(@core.alignment, "LEFT")
  }
}

///|
fn graph_transformer_mirror_alignment_y(node : LNode) -> Unit {
  let old_alignment = node.get_property_string(@core.alignment)
  if old_alignment == "TOP" {
    node.set_property_string(@core.alignment, "BOTTOM")
  } else if old_alignment == "BOTTOM" {
    node.set_property_string(@core.alignment, "TOP")
  }
}

///|
fn graph_transformer_transpose_node_properties(node : LNode) -> Unit {
  let min_size = @core.new_kvector()
  min_size.parse(node.get_property_string(@core.node_size_minimum))
  node.set_property_string(
    @core.node_size_minimum,
    @core.new_kvector_xy(min_size.y, min_size.x).to_string(),
  )

  let old_alignment = node.get_property_string(@core.alignment)
  if old_alignment == "LEFT" {
    node.set_property_string(@core.alignment, "TOP")
  } else if old_alignment == "RIGHT" {
    node.set_property_string(@core.alignment, "BOTTOM")
  } else if old_alignment == "TOP" {
    node.set_property_string(@core.alignment, "LEFT")
  } else if old_alignment == "BOTTOM" {
    node.set_property_string(@core.alignment, "RIGHT")
  }

  if node.has_property_kvector(layered_options_position) {
    let position = node.get_property_kvector(layered_options_position)
    graph_transformer_transpose_vector(position)
    node.set_property_kvector(layered_options_position, position)
  }
}

///|
fn graph_transformer_mirror_x_node_labels_padding(
  layered_graph : LGraph,
) -> Unit {
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    layered_graph.get_property_string(
      graph_transformer_node_labels_padding_property,
    ),
  )
  graph_transformer_mirror_x_padding(node_labels_padding)
  layered_graph.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_mirror_y_node_labels_padding(
  layered_graph : LGraph,
) -> Unit {
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    layered_graph.get_property_string(
      graph_transformer_node_labels_padding_property,
    ),
  )
  graph_transformer_mirror_y_padding(node_labels_padding)
  layered_graph.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_transpose_node_labels_padding(
  layered_graph : LGraph,
) -> Unit {
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    layered_graph.get_property_string(
      graph_transformer_node_labels_padding_property,
    ),
  )
  graph_transformer_transpose_padding(node_labels_padding)
  layered_graph.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_mirror_x_node_labels_padding_node(node : LNode) -> Unit {
  if !node.has_property_string(graph_transformer_node_labels_padding_property) {
    return
  }
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    node.get_property_string(graph_transformer_node_labels_padding_property),
  )
  graph_transformer_mirror_x_padding(node_labels_padding)
  node.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_mirror_y_node_labels_padding_node(node : LNode) -> Unit {
  if !node.has_property_string(graph_transformer_node_labels_padding_property) {
    return
  }
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    node.get_property_string(graph_transformer_node_labels_padding_property),
  )
  graph_transformer_mirror_y_padding(node_labels_padding)
  node.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_transpose_node_labels_padding_node(node : LNode) -> Unit {
  if !node.has_property_string(graph_transformer_node_labels_padding_property) {
    return
  }
  let node_labels_padding = @core.new_spacing()
  node_labels_padding.parse(
    node.get_property_string(graph_transformer_node_labels_padding_property),
  )
  graph_transformer_transpose_padding(node_labels_padding)
  node.set_property_string(
    graph_transformer_node_labels_padding_property,
    node_labels_padding.to_string(),
  )
}

///|
fn graph_transformer_transpose_edge_label_placement(
  layered_graph : LGraph,
) -> Unit {
  let old_side = graph_transformer_parse_edge_label_side_selection(
    layered_graph.get_property_string(
      layered_options_edge_labels_side_selection,
    ),
  )
  layered_graph.set_property_string(
    layered_options_edge_labels_side_selection,
    edge_label_side_selection_to_string(
      EdgeLabelSideSelection::transpose(old_side),
    ),
  )
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
    graph_transformer_mirror_x_node_labels_padding_node(node)
    graph_transformer_mirror_node_label_placement_x_node(node)

    if node.has_property_kvector(layered_options_position) {
      let position = node.get_property_kvector(layered_options_position)
      graph_transformer_mirror_x_vector(position, offset - node_size.x)
      node.set_property_kvector(layered_options_position, position)
    }

    graph_transformer_mirror_alignment_x(node)

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
      graph_transformer_mirror_node_label_placement_x_label(label)
      graph_transformer_mirror_x_vector(
        label.get_position(),
        node_size.x - label.get_size().x,
      )
    }
  }

  graph_transformer_mirror_x_padding(layered_graph.get_padding())
  graph_transformer_mirror_x_node_labels_padding(layered_graph)
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
    graph_transformer_mirror_y_node_labels_padding_node(node)
    graph_transformer_mirror_node_label_placement_y_node(node)

    if node.has_property_kvector(layered_options_position) {
      let position = node.get_property_kvector(layered_options_position)
      graph_transformer_mirror_y_vector(position, offset - node_size.y)
      node.set_property_kvector(layered_options_position, position)
    }

    graph_transformer_mirror_alignment_y(node)

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
      graph_transformer_mirror_node_label_placement_y_label(label)
      graph_transformer_mirror_y_vector(
        label.get_position(),
        node_size.y - label.get_size().y,
      )
    }
  }

  graph_transformer_mirror_y_padding(layered_graph.get_padding())
  graph_transformer_mirror_y_node_labels_padding(layered_graph)
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
    graph_transformer_transpose_node_labels_padding_node(node)
    graph_transformer_transpose_node_label_placement_node(node)
    graph_transformer_transpose_node_properties(node)

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
      graph_transformer_transpose_node_label_placement_label(label)
      graph_transformer_transpose_vector(label.get_size())
      graph_transformer_transpose_vector(label.get_position())
    }
  }

  graph_transformer_transpose_edge_label_placement(layered_graph)
  graph_transformer_transpose_vector(layered_graph.get_offset())
  graph_transformer_transpose_vector(layered_graph.get_size())
  graph_transformer_transpose_padding(layered_graph.get_padding())
  graph_transformer_transpose_node_labels_padding(layered_graph)
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
  let direction_value = layered_graph.get_property_string(@core.direction)
  let congruency = graph_transformer_parse_direction_congruency(
    graph_transformer_get_direction_congruency_value(layered_graph),
  )

  if congruency is DirectionCongruency::ReadingDirection {
    if direction_value == "LEFT" {
      graph_transformer_mirror_x(layered_graph, nodes)
    } else if direction_value == "DOWN" {
      graph_transformer_transpose(layered_graph, nodes)
    } else if direction_value == "UP" {
      if mode is GraphTransformerMode::ToInternalLtr {
        graph_transformer_transpose(layered_graph, nodes)
        graph_transformer_mirror_y(layered_graph, nodes)
      } else {
        graph_transformer_mirror_y(layered_graph, nodes)
        graph_transformer_transpose(layered_graph, nodes)
      }
    }
  } else if mode is GraphTransformerMode::ToInternalLtr {
    if direction_value == "LEFT" {
      graph_transformer_mirror_x(layered_graph, nodes)
      graph_transformer_mirror_y(layered_graph, nodes)
    } else if direction_value == "DOWN" {
      graph_transformer_rotate_90_clockwise(layered_graph, nodes)
    } else if direction_value == "UP" {
      graph_transformer_rotate_90_counter_clockwise(layered_graph, nodes)
    }
  } else if direction_value == "LEFT" {
    graph_transformer_mirror_x(layered_graph, nodes)
    graph_transformer_mirror_y(layered_graph, nodes)
  } else if direction_value == "DOWN" {
    graph_transformer_rotate_90_counter_clockwise(layered_graph, nodes)
  } else if direction_value == "UP" {
    graph_transformer_rotate_90_clockwise(layered_graph, nodes)
  }
}

///|
fn graph_transformer_process(
  mode : GraphTransformerMode,
  layered_graph : LGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(
    monitor.begin(
      "Graph transformation (" + graph_transformer_mode_to_string(mode) + ")",
      1.0,
    ),
  )
  graph_transformer_process_mode(layered_graph, mode)
  monitor.done()
}

///|
pub fn new_graph_transformer_layout_processor(
  mode : GraphTransformerMode,
) -> @core.ILayoutProcessor[LayeredPhases, LGraph] {
  @core.new_layout_processor((layered_graph, progress_monitor) => {
    graph_transformer_process(mode, layered_graph, progress_monitor)
  })
}

///|
pub fn new_direction_preprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_graph_transformer_layout_processor(GraphTransformerMode::ToInternalLtr)
}

///|
pub fn new_direction_postprocessor_layout_processor() -> @core.ILayoutProcessor[
  LayeredPhases,
  LGraph,
] {
  new_graph_transformer_layout_processor(GraphTransformerMode::ToInputDirection)
}
