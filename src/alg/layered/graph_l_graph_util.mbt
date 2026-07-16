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
pub(all) suberror LGraphUtilException {
  IllegalStateException(String)
} derive(Debug, ToJson)

///|
fn[T] l_graph_util_raise_illegal_state(
  message : String,
) -> T raise LGraphUtilException {
  raise IllegalStateException(message)
}

///|
pub fn l_graph_util_exception_message(error : LGraphUtilException) -> String {
  match error {
    IllegalStateException(message) => message
  }
}

///|
fn l_graph_util_in_layer_constraint_to_string(
  value : InLayerConstraint,
) -> String {
  match value {
    NoneType => "NONE"
    Top => "TOP"
    Bottom => "BOTTOM"
  }
}

///|
fn l_graph_util_edge_constraint_to_string(value : EdgeConstraint) -> String {
  match value {
    NoneType => "NONE"
    IncomingOnly => "INCOMING_ONLY"
    OutgoingOnly => "OUTGOING_ONLY"
  }
}

///|
fn l_graph_util_port_constraints_equals(
  left : @core.PortConstraints,
  right : @core.PortConstraints,
) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Free, Free) => true
    (FixedSide, FixedSide) => true
    (FixedOrder, FixedOrder) => true
    (FixedRatio, FixedRatio) => true
    (FixedPos, FixedPos) => true
    _ => false
  }
}

///|
pub fn resize_node(
  node : LNode,
  new_size : @core.KVector,
  move_ports : Bool,
  move_labels : Bool,
) -> Unit {
  let old_size = @core.new_kvector_copy(node.get_size())
  let width_ratio = new_size.x / old_size.x
  let height_ratio = new_size.y / old_size.y
  let width_diff = new_size.x - old_size.x
  let height_diff = new_size.y - old_size.y

  if move_ports {
    let fixed_ports = node.get_property_string(@core.port_constraints) ==
      @core.port_constraints_to_string(FixedPos)

    for port in node.get_ports() {
      match port.get_side() {
        North => if !fixed_ports { port.get_position().x *= width_ratio }
        East => {
          port.get_position().x += width_diff
          if !fixed_ports {
            port.get_position().y *= height_ratio
          }
        }
        South => {
          if !fixed_ports {
            port.get_position().x *= width_ratio
          }
          port.get_position().y += height_diff
        }
        West => if !fixed_ports { port.get_position().y *= height_ratio }
        SideUndefined => ()
      }
    }
  }

  if move_labels {
    for label in node.get_labels() {
      let midx = label.get_position().x + label.get_size().x / 2.0
      let midy = label.get_position().y + label.get_size().y / 2.0
      let width_percent = midx / old_size.x
      let height_percent = midy / old_size.y

      if width_percent + height_percent >= 1.0 {
        if width_percent - height_percent > 0.0 && midy >= 0.0 {
          label.get_position().x += width_diff
          label.get_position().y += height_diff * height_percent
        } else if width_percent - height_percent < 0.0 && midx >= 0.0 {
          label.get_position().x += width_diff * width_percent
          label.get_position().y += height_diff
        }
      }
    }
  }

  node.get_size().x = new_size.x
  node.get_size().y = new_size.y
  node.set_property_string_array(@core.node_size_constraints, ["FIXED"])
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
  let graph_offset = @core.new_kvector_xy(offsetx, offsety)

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
  let alignment_value = node.get_property_string(@core.alignment)
  if alignment_value == @core.alignment_to_string(Left) {
    return 0.0
  }
  if alignment_value == @core.alignment_to_string(Right) {
    return 1.0
  }
  if alignment_value == @core.alignment_to_string(Center) {
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
  let direction_value = graph.get_property_string(@core.direction)
  direction_value == @core.direction_to_string(Upward) ||
  direction_value == @core.direction_to_string(Downward)
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
      Normal => {
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
fn l_graph_util_direction_from_string(value : String) -> @core.Direction {
  if value == @core.direction_to_string(Rightward) {
    return Rightward
  }
  if value == @core.direction_to_string(Leftward) {
    return Leftward
  }
  if value == @core.direction_to_string(Downward) {
    return Downward
  }
  if value == @core.direction_to_string(Upward) {
    return Upward
  }
  Undefined
}

///|
fn l_graph_util_direction_equals(
  left : @core.Direction,
  right : @core.Direction,
) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Rightward, Rightward) => true
    (Leftward, Leftward) => true
    (Downward, Downward) => true
    (Upward, Upward) => true
    _ => false
  }
}

///|
fn l_graph_util_graph_property_equals(
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
fn l_graph_util_add_graph_property(
  props : Array[GraphProperties],
  property : GraphProperties,
) -> Unit {
  for current in props {
    if l_graph_util_graph_property_equals(current, property) {
      return
    }
  }
  props.push(property)
}

///|
pub fn get_direction(graph : LGraph) -> @core.Direction {
  let direction_value = l_graph_util_direction_from_string(
    graph.get_property_string(@core.direction),
  )
  if l_graph_util_direction_equals(direction_value, Undefined) {
    if graph.get_property_double(layered_options_aspect_ratio) >= 1.0 {
      Rightward
    } else {
      Downward
    }
  } else {
    direction_value
  }
}

///|
pub fn compute_graph_properties(layered_graph : LGraph) -> Unit {
  let props = layered_graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  if !props.is_empty() {
    props.clear()
  }

  let graph_direction = get_direction(layered_graph)
  for node in layered_graph.get_layerless_nodes() {
    if node.get_property_bool(layered_options_comment_box) {
      l_graph_util_add_graph_property(props, Comments)
    } else if node.get_property_bool(layered_options_hypernode) {
      l_graph_util_add_graph_property(props, Hypernodes)
      l_graph_util_add_graph_property(props, Hyperedges)
    } else {
      match node.get_type() {
        ExternalPort => l_graph_util_add_graph_property(props, ExternalPorts)
        _ => ()
      }
    }

    let node_port_constraints = node.get_property_string(@core.port_constraints)
    if node_port_constraints == @core.port_constraints_to_string(Undefined) {
      node.set_property_string(
        @core.port_constraints,
        @core.port_constraints_to_string(Free),
      )
    } else if node_port_constraints != @core.port_constraints_to_string(Free) {
      l_graph_util_add_graph_property(props, NonFreePorts)
    }

    for port in node.get_ports() {
      if port.get_incoming_edges().length() + port.get_outgoing_edges().length() >
        1 {
        l_graph_util_add_graph_property(props, Hyperedges)
      }

      let port_side = port.get_side()
      match graph_direction {
        Upward =>
          match port_side {
            East => l_graph_util_add_graph_property(props, NorthSouthPorts)
            West => l_graph_util_add_graph_property(props, NorthSouthPorts)
            _ => ()
          }
        Downward =>
          match port_side {
            East => l_graph_util_add_graph_property(props, NorthSouthPorts)
            West => l_graph_util_add_graph_property(props, NorthSouthPorts)
            _ => ()
          }
        _ =>
          match port_side {
            North => l_graph_util_add_graph_property(props, NorthSouthPorts)
            South => l_graph_util_add_graph_property(props, NorthSouthPorts)
            _ => ()
          }
      }

      for edge in port.get_outgoing_edges() {
        match edge.get_target() {
          Some(target_port) =>
            match target_port.get_node() {
              Some(target_node) =>
                if target_node.get_handle() == node.get_handle() {
                  l_graph_util_add_graph_property(props, SelfLoops)
                }
              None => ()
            }
          None => ()
        }

        for label in edge.get_labels() {
          let placement = label.get_property_string(@core.edge_labels_placement)
          if placement == @core.edge_label_placement_to_string(Centered) {
            l_graph_util_add_graph_property(props, CenterLabels)
          } else if placement == @core.edge_label_placement_to_string(Head) ||
            placement == @core.edge_label_placement_to_string(Tail) {
            l_graph_util_add_graph_property(props, EndLabels)
          }
        }
      }
    }
  }

  layered_graph.set_property_graph_properties_array(
    internal_properties_graph_properties, props,
  )
}

///|
pub fn get_minimal_model_order(graph : LGraph) -> Int {
  let mut order = @int.MAX_VALUE
  for node in graph.get_layerless_nodes() {
    if node.has_property_int(internal_properties_model_order) {
      order = @cmp.minimum(
        order,
        node.get_property_int(internal_properties_model_order),
      )
    }
  }
  order
}

///|
fn l_graph_util_port_constraints_string_is_side_fixed(
  constraints : String,
) -> Bool {
  constraints != @core.port_constraints_to_string(Free) &&
  constraints != @core.port_constraints_to_string(Undefined)
}

///|
pub fn create_port_for_edge(
  node : LNode,
  end_point : @core.KVector?,
  port_type : PortType,
  layered_graph : LGraph,
) -> LPort {
  let direction = get_direction(layered_graph)
  let merge_ports = layered_graph.get_property_bool(layered_options_merge_edges)
  let node_port_constraints = node.get_property_string(@core.port_constraints)

  if (merge_ports || node.get_property_bool(layered_options_hypernode)) &&
    !l_graph_util_port_constraints_string_is_side_fixed(node_port_constraints) {
    let default_side = @core.port_side_from_direction(direction)
    let collector_side = match port_type {
      Output => default_side
      Input => default_side.opposed()
      Undefined => default_side
    }
    return provide_collector_port(
      layered_graph, node, port_type, collector_side,
    )
  }

  let port = new_l_port()
  port.set_node(Some(node))

  match end_point {
    Some(position) => {
      let port_position = port.get_position()
      port_position.x = position.x - node.get_position().x
      port_position.y = position.y - node.get_position().y
      ignore(
        port_position.bound(0.0, 0.0, node.get_size().x, node.get_size().y),
      )
      port.set_side(calc_port_side(port, direction))
    }
    None => {
      let default_side = @core.port_side_from_direction(direction)
      port.set_side(
        match port_type {
          Output => default_side
          Input => default_side.opposed()
          Undefined => default_side
        },
      )
    }
  }

  let graph_properties = layered_graph.get_property_graph_properties_array(
    internal_properties_graph_properties,
  )
  let port_side = port.get_side()
  match direction {
    Leftward =>
      match port_side {
        North =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        South =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        _ => ()
      }
    Rightward =>
      match port_side {
        North =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        South =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        _ => ()
      }
    Upward =>
      match port_side {
        East =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        West =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        _ => ()
      }
    Downward =>
      match port_side {
        East =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        West =>
          l_graph_util_add_graph_property(graph_properties, NorthSouthPorts)
        _ => ()
      }
    Undefined => ()
  }

  layered_graph.set_property_graph_properties_array(
    internal_properties_graph_properties, graph_properties,
  )
  port
}

///|
fn l_graph_util_port_side_is_defined(side : @core.PortSide) -> Bool {
  match side {
    SideUndefined => false
    _ => true
  }
}

///|
fn calc_port_side(port : LPort, direction : @core.Direction) -> @core.PortSide {
  let node = match port.get_node() {
    Some(value) => value
    None => return SideUndefined
  }
  let node_width = node.get_size().x
  let node_height = node.get_size().y
  if node_width <= 0.0 && node_height <= 0.0 {
    return SideUndefined
  }

  let xpos = port.get_position().x
  let ypos = port.get_position().y
  let width = port.get_size().x
  let height = port.get_size().y

  match direction {
    Leftward =>
      if xpos < 0.0 {
        return West
      } else if xpos + width > node_width {
        return East
      }
    Rightward =>
      if xpos < 0.0 {
        return West
      } else if xpos + width > node_width {
        return East
      }
    Upward =>
      if ypos < 0.0 {
        return North
      } else if ypos + height > node_height {
        return South
      }
    Downward =>
      if ypos < 0.0 {
        return North
      } else if ypos + height > node_height {
        return South
      }
    Undefined => ()
  }

  let width_percent = (xpos + width / 2.0) / node_width
  let height_percent = (ypos + height / 2.0) / node_height
  if width_percent + height_percent <= 1.0 &&
    width_percent - height_percent <= 0.0 {
    West
  } else if width_percent + height_percent >= 1.0 &&
    width_percent - height_percent >= 0.0 {
    East
  } else if height_percent < 1.0 / 2.0 {
    North
  } else {
    South
  }
}

///|
fn calc_port_offset(port : LPort, side : @core.PortSide) -> Double {
  let node = match port.get_node() {
    Some(value) => value
    None => return 0.0
  }
  match side {
    North => -(port.get_position().y + port.get_size().y)
    East => port.get_position().x - node.get_size().x
    South => port.get_position().y - node.get_size().y
    West => -(port.get_position().x + port.get_size().x)
    SideUndefined => 0.0
  }
}

///|
fn center_point(
  point : @core.KVector,
  boundary : @core.KVector,
  side : @core.PortSide,
) -> Unit {
  match side {
    North => {
      point.x = boundary.x / 2.0
      point.y = 0.0
    }
    East => {
      point.x = boundary.x
      point.y = boundary.y / 2.0
    }
    South => {
      point.x = boundary.x / 2.0
      point.y = boundary.y
    }
    West => {
      point.x = 0.0
      point.y = boundary.y / 2.0
    }
    SideUndefined => ()
  }
}

///|
pub fn provide_collector_port(
  _layered_graph : LGraph,
  node : LNode,
  port_type : PortType,
  side : @core.PortSide,
) -> LPort {
  let maybe_port = match port_type {
    Input => {
      for inport in node.get_ports() {
        if inport.get_property_bool(internal_properties_input_collect) {
          return inport
        }
      }
      let created = new_l_port()
      created.set_property_bool(internal_properties_input_collect, true)
      Some(created)
    }
    Output => {
      for outport in node.get_ports() {
        if outport.get_property_bool(internal_properties_output_collect) {
          return outport
        }
      }
      let created = new_l_port()
      created.set_property_bool(internal_properties_output_collect, true)
      Some(created)
    }
    Undefined => None
  }
  let port = maybe_port.unwrap()
  port.set_node(Some(node))
  port.set_side(side)
  center_point(port.get_position(), node.get_size(), side)
  port
}

///|
pub fn initialize_port(
  port : LPort,
  port_constraints : @core.PortConstraints,
  direction : @core.Direction,
  anchor_pos : @core.KVector?,
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
      North => {
        let node_width = match port.get_node() {
          Some(node) => node.get_size().x
          None => 0.0
        }
        if node_width > 0.0 {
          ratio = port.get_position().x / node_width
        }
      }
      South => {
        let node_width = match port.get_node() {
          Some(node) => node.get_size().x
          None => 0.0
        }
        if node_width > 0.0 {
          ratio = port.get_position().x / node_width
        }
      }
      East => {
        let node_height = match port.get_node() {
          Some(node) => node.get_size().y
          None => 0.0
        }
        if node_height > 0.0 {
          ratio = port.get_position().y / node_height
        }
      }
      West => {
        let node_height = match port.get_node() {
          Some(node) => node.get_size().y
          None => 0.0
        }
        if node_height > 0.0 {
          ratio = port.get_position().y / node_height
        }
      }
      SideUndefined => ()
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
          North => port_anchor.x = port_size.x / 2.0
          East => {
            port_anchor.x = port_size.x
            port_anchor.y = port_size.y / 2.0
          }
          South => {
            port_anchor.x = port_size.x / 2.0
            port_anchor.y = port_size.y
          }
          West => port_anchor.y = port_size.y / 2.0
          SideUndefined => ()
        }
      } else {
        port_anchor.x = port_size.x / 2.0
        port_anchor.y = port_size.y / 2.0
      }
  }
}

///|
pub fn create_external_port_dummy(
  property_holder : LPort,
  ext_port_constraints : @core.PortConstraints,
  port_side : @core.PortSide,
  net_flow : Int,
  port_node_size : @core.KVector?,
  port_position : @core.KVector?,
  port_size : @core.KVector,
  layout_direction : @core.Direction,
  layered_graph : LGraph,
) -> LNode raise LGraphUtilException {
  let mut final_external_port_side = port_side

  let dummy = new_l_node(graph=Some(layered_graph))
  dummy.set_type(ExternalPort)
  dummy.set_property_kvector(internal_properties_ext_port_size, port_size)
  dummy.set_property_string(
    @core.port_constraints,
    @core.port_constraints_to_string(FixedPos),
  )
  let port_border_offset = property_holder.get_property_double(
    layered_options_port_border_offset,
  )
  dummy.set_property_double(
    layered_options_port_border_offset, port_border_offset,
  )

  let dummy_port = new_l_port()
  dummy_port.set_node(Some(dummy))

  if !ext_port_constraints.is_side_fixed() {
    if l_graph_util_direction_equals(layout_direction, Undefined) {
      l_graph_util_raise_illegal_state(
        "Layout direction must not be UNDEFINED.",
      )
    }
    if net_flow >= 0 {
      final_external_port_side = @core.port_side_from_direction(
        layout_direction,
      )
    } else {
      final_external_port_side = @core.port_side_from_direction(
        layout_direction,
      ).opposed()
    }
    property_holder.set_side(final_external_port_side)
  }

  let anchor = if property_holder.is_explicitly_supplied_port_anchor() {
    @core.new_kvector_copy(property_holder.get_anchor())
  } else {
    @core.new_kvector_xy(port_size.x / 2.0, port_size.y / 2.0)
  }
  let explicit_anchor = property_holder.is_explicitly_supplied_port_anchor()

  match final_external_port_side {
    West => {
      dummy.set_property_string(
        layered_options_layering_layer_constraint,
        layer_constraint_to_string(FirstSeparate),
      )
      dummy.set_property_string(
        internal_properties_edge_constraint,
        l_graph_util_edge_constraint_to_string(OutgoingOnly),
      )
      dummy.get_size().y = port_size.y
      if port_border_offset < 0.0 {
        dummy.get_size().x = -port_border_offset
      }
      dummy_port.set_side(East)
      if !explicit_anchor {
        anchor.x = port_size.x
      }
      anchor.x -= port_size.x
    }
    East => {
      dummy.set_property_string(
        layered_options_layering_layer_constraint,
        layer_constraint_to_string(LastSeparate),
      )
      dummy.set_property_string(
        internal_properties_edge_constraint,
        l_graph_util_edge_constraint_to_string(IncomingOnly),
      )
      dummy.get_size().y = port_size.y
      if port_border_offset < 0.0 {
        dummy.get_size().x = -port_border_offset
      }
      dummy_port.set_side(West)
      if !explicit_anchor {
        anchor.x = 0.0
      }
    }
    North => {
      dummy.set_property_string(
        internal_properties_in_layer_constraint,
        l_graph_util_in_layer_constraint_to_string(Top),
      )
      dummy.get_size().x = port_size.x
      if port_border_offset < 0.0 {
        dummy.get_size().y = -port_border_offset
      }
      dummy_port.set_side(South)
      if !explicit_anchor {
        anchor.y = port_size.y
      }
      anchor.y -= port_size.y
    }
    South => {
      dummy.set_property_string(
        internal_properties_in_layer_constraint,
        l_graph_util_in_layer_constraint_to_string(Bottom),
      )
      dummy.get_size().x = port_size.x
      if port_border_offset < 0.0 {
        dummy.get_size().y = -port_border_offset
      }
      dummy_port.set_side(North)
      if !explicit_anchor {
        anchor.y = 0.0
      }
    }
    SideUndefined =>
      l_graph_util_raise_illegal_state(
        "Unexpected external port side UNDEFINED.",
      )
  }

  ignore(dummy_port.get_position().set(anchor))
  dummy.set_property_kvector(layered_options_port_anchor, anchor)

  if ext_port_constraints.is_order_fixed() {
    let mut information_about_order = 0.0

    if l_graph_util_port_constraints_equals(ext_port_constraints, FixedOrder) &&
      property_holder.has_property_int(layered_options_port_index) {
      let port_index = property_holder
        .get_property_int(layered_options_port_index)
        .to_double()
      match final_external_port_side {
        North => information_about_order = port_index
        East => information_about_order = port_index
        South => information_about_order = -1.0 * port_index
        West => information_about_order = -1.0 * port_index
        SideUndefined => ()
      }
    } else {
      let current_port_position = match port_position {
        Some(position) => position
        None =>
          l_graph_util_raise_illegal_state(
            "Expected external port position for ordered port constraints.",
          )
      }
      match final_external_port_side {
        West => {
          information_about_order = current_port_position.y
          if ext_port_constraints.is_ratio_fixed() {
            let size = match port_node_size {
              Some(value) => value
              None =>
                l_graph_util_raise_illegal_state(
                  "Expected port node size for fixed ratio constraints.",
                )
            }
            information_about_order /= size.y
          }
        }
        East => {
          information_about_order = current_port_position.y
          if ext_port_constraints.is_ratio_fixed() {
            let size = match port_node_size {
              Some(value) => value
              None =>
                l_graph_util_raise_illegal_state(
                  "Expected port node size for fixed ratio constraints.",
                )
            }
            information_about_order /= size.y
          }
        }
        North => {
          information_about_order = current_port_position.x
          if ext_port_constraints.is_ratio_fixed() {
            let size = match port_node_size {
              Some(value) => value
              None =>
                l_graph_util_raise_illegal_state(
                  "Expected port node size for fixed ratio constraints.",
                )
            }
            information_about_order /= size.x
          }
        }
        South => {
          information_about_order = current_port_position.x
          if ext_port_constraints.is_ratio_fixed() {
            let size = match port_node_size {
              Some(value) => value
              None =>
                l_graph_util_raise_illegal_state(
                  "Expected port node size for fixed ratio constraints.",
                )
            }
            information_about_order /= size.x
          }
        }
        SideUndefined => ()
      }
    }

    dummy.set_property_double(
      internal_properties_port_ratio_or_position, information_about_order,
    )
  }

  dummy.set_property_port_side(
    internal_properties_ext_port_side, final_external_port_side,
  )
  dummy
}

///|
pub fn get_external_port_position(
  graph : LGraph,
  port_dummy : LNode,
  port_width : Double,
  port_height : Double,
) -> @core.KVector {
  let port_position = @core.new_kvector_copy(port_dummy.get_position())
  port_position.x += port_dummy.get_size().x / 2.0
  port_position.y += port_dummy.get_size().y / 2.0
  let port_offset = port_dummy.get_property_double(
    layered_options_port_border_offset,
  )

  let graph_size = graph.get_size()
  let padding = graph.get_padding()
  let graph_offset = graph.get_offset()

  match port_dummy.get_property_port_side(internal_properties_ext_port_side) {
    North => {
      port_position.x += padding.left + graph_offset.x - port_width / 2.0
      port_position.y = -port_height - port_offset
      port_dummy.get_position().y = -(padding.top + port_offset + graph_offset.y)
    }
    East => {
      port_position.x = graph_size.x +
        padding.left +
        padding.right +
        port_offset
      port_position.y += padding.top + graph_offset.y - port_height / 2.0
      port_dummy.get_position().x = graph_size.x +
        padding.right +
        port_offset -
        graph_offset.x
    }
    South => {
      port_position.x += padding.left + graph_offset.x - port_width / 2.0
      port_position.y = graph_size.y +
        padding.top +
        padding.bottom +
        port_offset
      port_dummy.get_position().y = graph_size.y +
        padding.bottom +
        port_offset -
        graph_offset.y
    }
    West => {
      port_position.x = -port_width - port_offset
      port_position.y += padding.top + graph_offset.y - port_height / 2.0
      port_dummy.get_position().x = -(padding.left +
        port_offset +
        graph_offset.x)
    }
    SideUndefined => ()
  }

  port_position
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
  point : @core.KVector,
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

///|
pub fn get_individual_or_inherited(
  node : LNode,
  property : @graph.IProperty[Double],
) -> Double {
  if node.has_property_double(property) {
    node.get_property_double(property)
  } else {
    node.get_graph().get_property_double(property)
  }
}
