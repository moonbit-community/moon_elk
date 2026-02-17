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

///|
fn l_graph_util_port_side_is_defined(side : PortSide) -> Bool {
  match side {
    PortSide::SideUndefined => false
    _ => true
  }
}

///|
fn calc_port_side(port : LPort, direction : Direction) -> PortSide {
  let node = match port.get_node() {
    Some(value) => value
    None => return PortSide::SideUndefined
  }
  let node_width = node.get_size().x
  let node_height = node.get_size().y
  if node_width <= 0.0 && node_height <= 0.0 {
    return PortSide::SideUndefined
  }

  let xpos = port.get_position().x
  let ypos = port.get_position().y
  let width = port.get_size().x
  let height = port.get_size().y

  match direction {
    Direction::Leftward =>
      if xpos < 0.0 {
        return PortSide::West
      } else if xpos + width > node_width {
        return PortSide::East
      }
    Direction::Rightward =>
      if xpos < 0.0 {
        return PortSide::West
      } else if xpos + width > node_width {
        return PortSide::East
      }
    Direction::Upward =>
      if ypos < 0.0 {
        return PortSide::North
      } else if ypos + height > node_height {
        return PortSide::South
      }
    Direction::Downward =>
      if ypos < 0.0 {
        return PortSide::North
      } else if ypos + height > node_height {
        return PortSide::South
      }
    Direction::Undefined => ()
  }

  let width_percent = (xpos + width / 2.0) / node_width
  let height_percent = (ypos + height / 2.0) / node_height
  if width_percent + height_percent <= 1.0 &&
    width_percent - height_percent <= 0.0 {
    PortSide::West
  } else if width_percent + height_percent >= 1.0 &&
    width_percent - height_percent >= 0.0 {
    PortSide::East
  } else if height_percent < 1.0 / 2.0 {
    PortSide::North
  } else {
    PortSide::South
  }
}

///|
fn calc_port_offset(port : LPort, side : PortSide) -> Double {
  let node = match port.get_node() {
    Some(value) => value
    None => return 0.0
  }
  match side {
    PortSide::North => -(port.get_position().y + port.get_size().y)
    PortSide::East => port.get_position().x - node.get_size().x
    PortSide::South => port.get_position().y - node.get_size().y
    PortSide::West => -(port.get_position().x + port.get_size().x)
    PortSide::SideUndefined => 0.0
  }
}

///|
fn center_point(point : KVector, boundary : KVector, side : PortSide) -> Unit {
  match side {
    PortSide::North => {
      point.x = boundary.x / 2.0
      point.y = 0.0
    }
    PortSide::East => {
      point.x = boundary.x
      point.y = boundary.y / 2.0
    }
    PortSide::South => {
      point.x = boundary.x / 2.0
      point.y = boundary.y
    }
    PortSide::West => {
      point.x = 0.0
      point.y = boundary.y / 2.0
    }
    PortSide::SideUndefined => ()
  }
}

///|
pub fn provide_collector_port(
  _layered_graph : LGraph,
  node : LNode,
  port_type : PortType,
  side : PortSide,
) -> LPort {
  let port = match port_type {
    PortType::Input => {
      for inport in node.get_ports() {
        if inport.get_property_bool(internal_properties_input_collect) {
          return inport
        }
      }
      let created = new_l_port()
      created.set_property_bool(internal_properties_input_collect, true)
      created
    }
    PortType::Output => {
      for outport in node.get_ports() {
        if outport.get_property_bool(internal_properties_output_collect) {
          return outport
        }
      }
      let created = new_l_port()
      created.set_property_bool(internal_properties_output_collect, true)
      created
    }
    PortType::Undefined => abort("Port type must be INPUT or OUTPUT.")
  }
  port.set_node(Some(node))
  port.set_side(side)
  center_point(port.get_position(), node.get_size(), side)
  port
}

///|
pub fn initialize_port(
  port : LPort,
  port_constraints : PortConstraints,
  direction : Direction,
  anchor_pos : KVector?,
) -> Unit {
  let mut port_side = port.get_side()

  if !l_graph_util_port_side_is_defined(port_side) &&
    port_constraints.is_side_fixed() {
    port_side = calc_port_side(port, direction)
    port.set_side(port_side)

    let position = port.get_position()
    if !port.has_property_double(layered_options_port_border_offset) &&
      l_graph_util_port_side_is_defined(port_side) &&
      (position.x != 0.0 || position.y != 0.0) {
      port.set_property_double(
        layered_options_port_border_offset,
        calc_port_offset(port, port_side),
      )
    }
  }

  if port_constraints.is_ratio_fixed() {
    let mut ratio = 0.0
    match port_side {
      PortSide::North => {
        let node_width = match port.get_node() {
          Some(node) => node.get_size().x
          None => 0.0
        }
        if node_width > 0.0 {
          ratio = port.get_position().x / node_width
        }
      }
      PortSide::South => {
        let node_width = match port.get_node() {
          Some(node) => node.get_size().x
          None => 0.0
        }
        if node_width > 0.0 {
          ratio = port.get_position().x / node_width
        }
      }
      PortSide::East => {
        let node_height = match port.get_node() {
          Some(node) => node.get_size().y
          None => 0.0
        }
        if node_height > 0.0 {
          ratio = port.get_position().y / node_height
        }
      }
      PortSide::West => {
        let node_height = match port.get_node() {
          Some(node) => node.get_size().y
          None => 0.0
        }
        if node_height > 0.0 {
          ratio = port.get_position().y / node_height
        }
      }
      PortSide::SideUndefined => ()
    }
    port.set_property_double(internal_properties_port_ratio_or_position, ratio)
  }

  let port_size = port.get_size()
  let port_anchor = port.get_anchor()
  match anchor_pos {
    Some(anchor) => {
      port_anchor.x = anchor.x
      port_anchor.y = anchor.y
      port.set_explicitly_supplied_port_anchor(true)
    }
    None =>
      if port_constraints.is_side_fixed() &&
        l_graph_util_port_side_is_defined(port_side) {
        match port_side {
          PortSide::North => port_anchor.x = port_size.x / 2.0
          PortSide::East => {
            port_anchor.x = port_size.x
            port_anchor.y = port_size.y / 2.0
          }
          PortSide::South => {
            port_anchor.x = port_size.x / 2.0
            port_anchor.y = port_size.y
          }
          PortSide::West => port_anchor.y = port_size.y / 2.0
          PortSide::SideUndefined => ()
        }
      } else {
        port_anchor.x = port_size.x / 2.0
        port_anchor.y = port_size.y / 2.0
      }
  }
}

///|
pub fn is_descendant_l_node(child : LNode, parent : LNode) -> Bool {
  let mut current = child
  let mut next = current.get_graph().get_parent_node()
  while true {
    match next {
      Some(node) => {
        current = node
        if current.get_handle() == parent.get_handle() {
          return true
        }
        next = current.get_graph().get_parent_node()
      }
      None => break
    }
  }
  false
}

///|
pub fn change_coord_system(
  point : KVector,
  old_graph : LGraph,
  new_graph : LGraph,
) -> Unit {
  let mut graph = old_graph
  let mut node : LNode? = None
  while true {
    ignore(point.add(graph.get_offset()))
    node = graph.get_parent_node()
    match node {
      Some(value) => {
        let padding = graph.get_padding()
        ignore(point.add_xy(padding.left, padding.top))
        ignore(point.add(value.get_position()))
        graph = value.get_graph()
      }
      None => break
    }
  }

  graph = new_graph
  while true {
    ignore(point.sub(graph.get_offset()))
    node = graph.get_parent_node()
    match node {
      Some(value) => {
        let padding = graph.get_padding()
        ignore(point.sub_xy(padding.left, padding.top))
        ignore(point.sub(value.get_position()))
        graph = value.get_graph()
      }
      None => break
    }
  }
}
