///|
pub enum EdgeRoutingDirection {
  Clockwise
  CounterClockwise
}

///|
fn orthogonal_self_loop_router_port_side_equals(
  left : @core.PortSide,
  right : @core.PortSide,
) -> Bool {
  match (left, right) {
    (@core.PortSide::SideUndefined, @core.PortSide::SideUndefined) => true
    (North, North) => true
    (East, East) => true
    (South, South) => true
    (West, West) => true
    _ => false
  }
}

///|
fn orthogonal_self_loop_router_side_index(side : @core.PortSide) -> Int {
  match side {
    @core.PortSide::SideUndefined => 0
    North => 1
    East => 2
    South => 3
    West => 4
  }
}

///|
fn orthogonal_self_loop_router_occupied_contains(
  occupied_sides : Array[@core.PortSide],
  side : @core.PortSide,
) -> Bool {
  for occupied_side in occupied_sides {
    if orthogonal_self_loop_router_port_side_equals(occupied_side, side) {
      return true
    }
  }
  false
}

///|
fn orthogonal_self_loop_router_require_hyper_loop(
  sl_edge : SelfLoopEdge,
) -> SelfHyperLoop {
  match sl_edge.get_sl_hyper_loop() {
    Some(sl_loop) => sl_loop
    None => {
      @core.layout_runtime_report_unsupported_configuration(
        "self-loop edge has no hyper loop",
      )
      new_self_hyper_loop(new_self_loop_holder(new_l_node()))
    }
  }
}

///|
fn orthogonal_self_loop_router_compute_edge_routing_direction(
  sl_edge : SelfLoopEdge,
) -> EdgeRoutingDirection {
  let source_l_port = sl_edge.get_sl_source().get_l_port()
  let source_port_side = source_l_port.get_side()

  let target_l_port = sl_edge.get_sl_target().get_l_port()
  let target_port_side = target_l_port.get_side()

  if orthogonal_self_loop_router_port_side_equals(
      source_port_side, target_port_side,
    ) {
    if source_l_port.get_id() < target_l_port.get_id() {
      EdgeRoutingDirection::Clockwise
    } else {
      EdgeRoutingDirection::CounterClockwise
    }
  } else if orthogonal_self_loop_router_port_side_equals(
      source_port_side.right(),
      target_port_side,
    ) {
    EdgeRoutingDirection::Clockwise
  } else if orthogonal_self_loop_router_port_side_equals(
      source_port_side.left(),
      target_port_side,
    ) {
    EdgeRoutingDirection::CounterClockwise
  } else {
    let sl_loop = orthogonal_self_loop_router_require_hyper_loop(sl_edge)
    if orthogonal_self_loop_router_occupied_contains(
        sl_loop.get_occupied_port_sides(),
        source_port_side.right(),
      ) {
      EdgeRoutingDirection::Clockwise
    } else {
      EdgeRoutingDirection::CounterClockwise
    }
  }
}

///|
fn orthogonal_self_loop_router_update_new_node_margins_point(
  node_size : @core.KVector,
  new_node_margins : LMargin,
  bend_point : @core.KVector,
) -> Unit {
  new_node_margins.left = @cmp.maximum(new_node_margins.left, -bend_point.x)
  new_node_margins.right = @cmp.maximum(
    new_node_margins.right,
    bend_point.x - node_size.x,
  )
  new_node_margins.top = @cmp.maximum(new_node_margins.top, -bend_point.y)
  new_node_margins.bottom = @cmp.maximum(
    new_node_margins.bottom,
    bend_point.y - node_size.y,
  )
}

///|
fn orthogonal_self_loop_router_update_new_node_margins_labels(
  node_size : @core.KVector,
  new_node_margins : LMargin,
  sl_labels : SelfHyperLoopLabels,
) -> Unit {
  let position = sl_labels.get_position().clone()
  orthogonal_self_loop_router_update_new_node_margins_point(
    node_size, new_node_margins, position,
  )

  ignore(position.add(sl_labels.get_size()))
  orthogonal_self_loop_router_update_new_node_margins_point(
    node_size, new_node_margins, position,
  )
}

///|
fn orthogonal_self_loop_router_initialize_with_max_label_height(
  positions : Array[Array[Double]],
  sl_holder : SelfLoopHolder,
  port_side : @core.PortSide,
) -> Unit {
  let side_positions = positions[orthogonal_self_loop_router_side_index(
      port_side,
    )]
  for sl_loop in sl_holder.get_sl_hyper_loops() {
    match sl_loop.get_sl_labels() {
      Some(sl_labels) =>
        if orthogonal_self_loop_router_port_side_equals(
            sl_labels.get_side(),
            port_side,
          ) {
          let routing_slot = sl_loop.get_routing_slot(port_side)
          side_positions[routing_slot] = @cmp.maximum(
            side_positions[routing_slot],
            sl_labels.get_size().y,
          )
        }
      None => ()
    }
  }
}

///|
fn orthogonal_self_loop_router_compute_baseline_position(
  sl_holder : SelfLoopHolder,
  port_side : @core.PortSide,
  node_self_loop_distance : Double,
) -> Double {
  let l_node = sl_holder.get_l_node()
  let l_margins = l_node.get_margin()
  match port_side {
    North => -l_margins.top - node_self_loop_distance
    East => l_node.get_size().x + l_margins.right + node_self_loop_distance
    South => l_node.get_size().y + l_margins.bottom + node_self_loop_distance
    West => -l_margins.left - node_self_loop_distance
    @core.PortSide::SideUndefined => 0.0
  }
}

///|
fn orthogonal_self_loop_router_compute_positions(
  positions : Array[Array[Double]],
  sl_holder : SelfLoopHolder,
  port_side : @core.PortSide,
  edge_edge_distance : Double,
  edge_label_distance : Double,
  node_self_loop_distance : Double,
) -> Unit {
  let mut curr_pos = orthogonal_self_loop_router_compute_baseline_position(
    sl_holder, port_side, node_self_loop_distance,
  )

  let factor = if orthogonal_self_loop_router_port_side_equals(port_side, North) ||
    orthogonal_self_loop_router_port_side_equals(port_side, West) {
    -1.0
  } else {
    1.0
  }

  let side_positions = positions[orthogonal_self_loop_router_side_index(
      port_side,
    )]
  for slot in 0..<side_positions.length() {
    let mut largest_label_size = side_positions[slot]
    if largest_label_size > 0.0 {
      largest_label_size += edge_label_distance
    }

    side_positions[slot] = curr_pos
    curr_pos += factor * (largest_label_size + edge_edge_distance)
  }
}

///|
fn orthogonal_self_loop_router_compute_routing_slot_positions(
  sl_holder : SelfLoopHolder,
  edge_edge_distance : Double,
  edge_label_distance : Double,
  node_self_loop_distance : Double,
) -> Array[Array[Double]] {
  let positions = []
  let slot_count = sl_holder.get_routing_slot_count()

  for side in @core.port_side_values() {
    let side_positions = []
    for _ in 0..<slot_count[orthogonal_self_loop_router_side_index(side)] {
      side_positions.push(0.0)
    }
    positions.push(side_positions)
  }

  orthogonal_self_loop_router_initialize_with_max_label_height(
    positions,
    sl_holder,
    North,
  )
  orthogonal_self_loop_router_initialize_with_max_label_height(
    positions,
    sl_holder,
    South,
  )

  orthogonal_self_loop_router_compute_positions(
    positions,
    sl_holder,
    North,
    edge_edge_distance,
    edge_label_distance,
    node_self_loop_distance,
  )
  orthogonal_self_loop_router_compute_positions(
    positions,
    sl_holder,
    East,
    edge_edge_distance,
    edge_label_distance,
    node_self_loop_distance,
  )
  orthogonal_self_loop_router_compute_positions(
    positions,
    sl_holder,
    South,
    edge_edge_distance,
    edge_label_distance,
    node_self_loop_distance,
  )
  orthogonal_self_loop_router_compute_positions(
    positions,
    sl_holder,
    West,
    edge_edge_distance,
    edge_label_distance,
    node_self_loop_distance,
  )

  positions
}

///|
fn orthogonal_self_loop_router_get_base_vector(
  port_side : @core.PortSide,
  routing_slot : Int,
  routing_slot_positions : Array[Array[Double]],
) -> @core.KVector {
  let position = routing_slot_positions[orthogonal_self_loop_router_side_index(
      port_side,
    )][routing_slot]
  match port_side {
    North => @core.new_kvector_xy(0.0, position)
    South => @core.new_kvector_xy(0.0, position)
    East => @core.new_kvector_xy(position, 0.0)
    West => @core.new_kvector_xy(position, 0.0)
    @core.PortSide::SideUndefined => @core.new_kvector()
  }
}

///|
fn orthogonal_self_loop_router_adjust_vector_for_label_side(
  port_side_component : @core.KVector,
  label_side : @core.PortSide,
  label_size : @core.KVector,
) -> Unit {
  match label_side {
    North => port_side_component.y -= label_size.y / 2.0
    South => port_side_component.y += label_size.y / 2.0
    West => port_side_component.x -= label_size.x / 2.0
    East => port_side_component.x += label_size.x / 2.0
    @core.PortSide::SideUndefined => ()
  }
}

///|
fn orthogonal_self_loop_router_add_outer_bend_point(
  sl_edge : SelfLoopEdge,
  sl_port : SelfLoopPort,
  routing_slot_positions : Array[Array[Double]],
  bend_points : @core.KVectorChain,
) -> Unit {
  let sl_loop = orthogonal_self_loop_router_require_hyper_loop(sl_edge)
  let l_port = sl_port.get_l_port()
  let port_side = l_port.get_side()
  let result = orthogonal_self_loop_router_get_base_vector(
    port_side,
    sl_loop.get_routing_slot(port_side),
    routing_slot_positions,
  )

  let anchor = l_port.get_position().clone().add(l_port.get_anchor())
  match port_side {
    North => result.x += anchor.x
    South => result.x += anchor.x
    East => result.y += anchor.y
    West => result.y += anchor.y
    @core.PortSide::SideUndefined => ()
  }

  bend_points.add_last_vector(result)
}

///|
fn orthogonal_self_loop_router_add_corner_bend_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  routing_slot_positions : Array[Array[Double]],
  bend_points : @core.KVectorChain,
) -> Unit {
  let source_port = sl_edge.get_sl_source().get_l_port()
  let target_port = sl_edge.get_sl_target().get_l_port()
  if orthogonal_self_loop_router_port_side_equals(
      source_port.get_side(),
      target_port.get_side(),
    ) {
    return
  }

  let sl_loop = orthogonal_self_loop_router_require_hyper_loop(sl_edge)
  let inline = sl_edge.is_inline()
  let mut label_side = @core.PortSide::SideUndefined
  let mut label_size = @core.new_kvector()
  if inline {
    match sl_loop.get_sl_labels() {
      Some(sl_labels) => {
        label_side = sl_edge.get_label_side()
        label_size = sl_labels.get_size()
      }
      None => ()
    }
  }

  let mut curr_port_side = source_port.get_side()
  while !orthogonal_self_loop_router_port_side_equals(
          curr_port_side,
          target_port.get_side(),
        ) {
    let next_port_side = match routing_direction {
      EdgeRoutingDirection::Clockwise => curr_port_side.right()
      EdgeRoutingDirection::CounterClockwise => curr_port_side.left()
    }

    let curr_component = orthogonal_self_loop_router_get_base_vector(
      curr_port_side,
      sl_loop.get_routing_slot(curr_port_side),
      routing_slot_positions,
    )
    let next_component = orthogonal_self_loop_router_get_base_vector(
      next_port_side,
      sl_loop.get_routing_slot(next_port_side),
      routing_slot_positions,
    )

    if inline &&
      !orthogonal_self_loop_router_port_side_equals(
        label_side,
        @core.PortSide::SideUndefined,
      ) {
      if orthogonal_self_loop_router_port_side_equals(
          curr_port_side, label_side,
        ) {
        orthogonal_self_loop_router_adjust_vector_for_label_side(
          curr_component, label_side, label_size,
        )
      } else if orthogonal_self_loop_router_port_side_equals(
          next_port_side, label_side,
        ) {
        orthogonal_self_loop_router_adjust_vector_for_label_side(
          next_component, label_side, label_size,
        )
      }
    }

    bend_points.add_last_vector(curr_component.add(next_component))
    curr_port_side = next_port_side
  }
}

///|
fn orthogonal_self_loop_router_compute_orthogonal_bend_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  routing_slot_positions : Array[Array[Double]],
) -> @core.KVectorChain {
  let bend_points = @core.new_kvector_chain()
  orthogonal_self_loop_router_add_outer_bend_point(
    sl_edge,
    sl_edge.get_sl_source(),
    routing_slot_positions,
    bend_points,
  )
  orthogonal_self_loop_router_add_corner_bend_points(
    sl_edge, routing_direction, routing_slot_positions, bend_points,
  )
  orthogonal_self_loop_router_add_outer_bend_point(
    sl_edge,
    sl_edge.get_sl_target(),
    routing_slot_positions,
    bend_points,
  )
  bend_points
}

///|
fn orthogonal_self_loop_router_place_labels(
  sl_loop : SelfHyperLoop,
  sl_labels : SelfHyperLoopLabels,
  routing_slot_positions : Array[Array[Double]],
  edge_label_distance : Double,
) -> Unit {
  let label_side = sl_labels.get_side()
  let mut label_position = routing_slot_positions[orthogonal_self_loop_router_side_index(
      label_side,
    )][sl_loop.get_routing_slot(label_side)]

  match label_side {
    North => {
      label_position -= edge_label_distance + sl_labels.get_size().y
      sl_labels.get_position().y = label_position
    }
    South => {
      label_position += edge_label_distance
      sl_labels.get_position().y = label_position
    }
    West => {
      label_position -= edge_label_distance + sl_labels.get_size().x
      sl_labels.get_position().x = label_position
    }
    East => {
      label_position += edge_label_distance
      sl_labels.get_position().x = label_position
    }
    @core.PortSide::SideUndefined => ()
  }
}

///|
fn orthogonal_self_loop_router_default_modify_bend_points(
  sl_edge : SelfLoopEdge,
  routing_direction : EdgeRoutingDirection,
  bend_points : @core.KVectorChain,
) -> @core.KVectorChain {
  ignore(sl_edge)
  ignore(routing_direction)
  bend_points
}

///|
pub fn orthogonal_self_loop_router_route_with_modifier(
  sl_holder : SelfLoopHolder,
  modify_bend_points : (SelfLoopEdge, EdgeRoutingDirection, @core.KVectorChain) -> @core.KVectorChain,
) -> Unit {
  let l_node = sl_holder.get_l_node()
  let node_size = l_node.get_size()
  let node_margins = l_node.get_margin()

  let edge_edge_distance = get_individual_or_inherited(
    l_node, @core.spacing_edge_edge,
  )
  let edge_label_distance = get_individual_or_inherited(
    l_node, @core.spacing_edge_label,
  )
  let node_self_loop_distance = get_individual_or_inherited(
    l_node, @core.spacing_node_self_loop,
  )

  let new_node_margins = new_l_margin()
  new_node_margins.set_spacing(node_margins)

  let routing_slot_positions = orthogonal_self_loop_router_compute_routing_slot_positions(
    sl_holder, edge_edge_distance, edge_label_distance, node_self_loop_distance,
  )

  for sl_loop in sl_holder.get_sl_hyper_loops() {
    for sl_edge in sl_loop.get_sl_edges() {
      let l_edge = sl_edge.get_l_edge()
      let routing_direction = orthogonal_self_loop_router_compute_edge_routing_direction(
        sl_edge,
      )

      let bend_points = orthogonal_self_loop_router_compute_orthogonal_bend_points(
        sl_edge, routing_direction, routing_slot_positions,
      )
      let modified_bend_points = modify_bend_points(
        sl_edge, routing_direction, bend_points,
      )

      l_edge.get_bend_points().clear()
      l_edge.get_bend_points().add_all(modified_bend_points.to_array())
      for bend_point in modified_bend_points.to_array() {
        orthogonal_self_loop_router_update_new_node_margins_point(
          node_size, new_node_margins, bend_point,
        )
      }
    }

    match sl_loop.get_sl_labels() {
      Some(sl_labels) => {
        orthogonal_self_loop_router_place_labels(
          sl_loop, sl_labels, routing_slot_positions, edge_label_distance,
        )
        orthogonal_self_loop_router_update_new_node_margins_labels(
          node_size, new_node_margins, sl_labels,
        )
      }
      None => ()
    }
  }

  node_margins.set_spacing(new_node_margins)
}

///|
pub fn orthogonal_self_loop_router_route_self_loops(
  sl_holder : SelfLoopHolder,
) -> Unit {
  orthogonal_self_loop_router_route_with_modifier(
    sl_holder, orthogonal_self_loop_router_default_modify_bend_points,
  )
}

///|
pub fn new_orthogonal_self_loop_router() -> AbstractSelfLoopRouter {
  new_abstract_self_loop_router(orthogonal_self_loop_router_route_self_loops)
}
