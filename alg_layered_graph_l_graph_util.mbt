///|
pub fn to_node_array(nodes : Array[LNode]) -> Array[LNode] {
  let node_array = []
  for node in nodes {
    node_array.push(node)
  }
  node_array
}

///|
pub fn to_edge_array(edges : Array[LEdge]) -> Array[LEdge] {
  let edge_array = []
  for edge in edges {
    edge_array.push(edge)
  }
  edge_array
}

///|
pub fn to_port_array(ports : Array[LPort]) -> Array[LPort] {
  let port_array = []
  for port in ports {
    port_array.push(port)
  }
  port_array
}

///|
pub fn offset_graphs(
  graphs : Array[LGraph],
  offsetx : Double,
  offsety : Double,
) -> Unit {
  for graph in graphs {
    offset_graph(graph, offsetx, offsety)
  }
}

///|
pub fn offset_graph(graph : LGraph, offsetx : Double, offsety : Double) -> Unit {
  let graph_offset = new_kvector_xy(offsetx, offsety)

  for node in graph.get_layerless_nodes() {
    ignore(node.get_position().add(graph_offset))

    for port in node.get_ports() {
      for edge in port.get_outgoing_edges() {
        ignore(edge.get_bend_points().offset(graph_offset))

        if edge.has_property_kvector_chain(layered_options_junction_points) {
          ignore(
            edge
            .get_property_kvector_chain(layered_options_junction_points)
            .offset(graph_offset),
          )
        }

        for label in edge.get_labels() {
          ignore(label.get_position().add(graph_offset))
        }
      }
    }
  }
}

///|
fn l_graph_util_alignment_ratio(node : LNode) -> Double {
  let alignment_value = node.get_property_string(alignment)
  if alignment_value == alignment_to_string(Alignment::Left) {
    return 0.0
  }
  if alignment_value == alignment_to_string(Alignment::Right) {
    return 1.0
  }
  if alignment_value == alignment_to_string(Alignment::Center) {
    return 0.5
  }

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

///|
pub fn place_nodes_horizontally(layer : Layer, xoffset : Double) -> Unit {
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
    let ratio = l_graph_util_alignment_ratio(node)
    let layer_size = layer.get_size()
    let node_size = node.get_size().x
    let mut xpos = (layer_size.x - node_size) * ratio

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
    let max_x = layer_size.x - right_margin - node_size
    if xpos > max_x {
      xpos = max_x
    }

    node.get_position().x = xoffset + xpos
  }
}

///|
fn l_graph_util_is_vertical_direction(graph : LGraph) -> Bool {
  let direction_value = graph.get_property_string(direction)
  direction_value == direction_to_string(Direction::Upward) ||
  direction_value == direction_to_string(Direction::Downward)
}

///|
pub fn find_max_non_dummy_node_width(
  layer : Layer,
  respect_node_margins : Bool,
) -> Double {
  if l_graph_util_is_vertical_direction(layer.get_graph()) {
    return 0.0
  }

  let mut max_width = 0.0
  for node in layer.get_nodes() {
    match node.get_type() {
      NodeType::Normal => {
        let mut width = node.get_size().x
        if respect_node_margins {
          let margin = node.get_margin()
          width += margin.left + margin.right
        }
        if width > max_width {
          max_width = width
        }
      }
      _ => ()
    }
  }

  max_width
}
