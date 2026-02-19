///|
pub enum RoutingDirectionStrategyType {
  WestToEastRoutingStrategyType
  NorthToSouthRoutingStrategyType
  SouthToNorthRoutingStrategyType
}

///|
let base_routing_direction_strategy_junction_points : @graph.IProperty[
  @core.KVectorChain,
] = @graph.new_property(
  "org.eclipse.elk.junctionPoints",
  @core.new_kvector_chain(),
)

///|
fn base_routing_direction_strategy_has_created_junction_point(
  created_junction_points : Array[@core.KVector],
  point : @core.KVector,
) -> Bool {
  for created_point in created_junction_points {
    if created_point.equals(point) {
      return true
    }
  }
  false
}

///|
pub struct BaseRoutingDirectionStrategy {
  strategy_type : RoutingDirectionStrategyType
  created_junction_points : Array[@core.KVector]
}

///|
pub fn new_base_routing_direction_strategy(
  strategy_type : RoutingDirectionStrategyType,
) -> BaseRoutingDirectionStrategy {
  { strategy_type, created_junction_points: [] }
}

///|
pub fn base_routing_direction_strategy_for_routing_direction(
  direction : RoutingDirection,
) -> BaseRoutingDirectionStrategy {
  match direction {
    WestToEast => new_west_to_east_routing_strategy()
    NorthToSouth => new_north_to_south_routing_strategy()
    SouthToNorth => new_south_to_north_routing_strategy()
  }
}

///|
pub fn BaseRoutingDirectionStrategy::add_junction_point_if_necessary(
  self : BaseRoutingDirectionStrategy,
  edge : LEdge,
  segment : HyperEdgeSegment,
  pos : @core.KVector,
  vertical : Bool,
) -> Unit {
  let p = if vertical { pos.y } else { pos.x }

  if base_routing_direction_strategy_has_created_junction_point(
      self.created_junction_points,
      pos,
    ) {
    return
  }

  let point_inside_edge_segment = p > segment.get_start_coordinate() &&
    p < segment.get_end_coordinate()

  let mut point_at_segment_boundary = false
  let incoming_connection_coordinates = segment.get_incoming_connection_coordinates()
  let outgoing_connection_coordinates = segment.get_outgoing_connection_coordinates()

  if !incoming_connection_coordinates.is_empty() &&
    !outgoing_connection_coordinates.is_empty() {
    point_at_segment_boundary = point_at_segment_boundary ||
      (
        (p - incoming_connection_coordinates[0]).abs() <
        orthogonal_routing_generator_tolerance &&
        (p - outgoing_connection_coordinates[0]).abs() <
        orthogonal_routing_generator_tolerance
      )

    point_at_segment_boundary = point_at_segment_boundary ||
      (
        (p -
        incoming_connection_coordinates[incoming_connection_coordinates.length() -
        1]).abs() <
        orthogonal_routing_generator_tolerance &&
        (p -
        outgoing_connection_coordinates[outgoing_connection_coordinates.length() -
        1]).abs() <
        orthogonal_routing_generator_tolerance
      )
  }

  if point_inside_edge_segment || point_at_segment_boundary {
    let junction_points = if edge.has_property_kvector_chain(
        base_routing_direction_strategy_junction_points,
      ) {
      edge.get_property_kvector_chain(
        base_routing_direction_strategy_junction_points,
      )
    } else {
      let chain = @core.new_kvector_chain()
      edge.set_property_kvector_chain(
        base_routing_direction_strategy_junction_points, chain,
      )
      chain
    }

    let junction_point = @core.new_kvector_copy(pos)
    junction_points.add_vector(junction_point)
    self.created_junction_points.push(junction_point)
  }
}

///|
pub fn BaseRoutingDirectionStrategy::get_created_junction_points(
  self : BaseRoutingDirectionStrategy,
) -> Array[@core.KVector] {
  self.created_junction_points
}

///|
pub fn BaseRoutingDirectionStrategy::clear_created_junction_points(
  self : BaseRoutingDirectionStrategy,
) -> Unit {
  self.created_junction_points.clear()
}

///|
pub fn BaseRoutingDirectionStrategy::get_port_position_on_hyper_node(
  self : BaseRoutingDirectionStrategy,
  port : LPort,
) -> Double {
  match self.strategy_type {
    WestToEastRoutingStrategyType =>
      west_to_east_routing_strategy_get_port_position_on_hyper_node(port)
    NorthToSouthRoutingStrategyType =>
      north_to_south_routing_strategy_get_port_position_on_hyper_node(port)
    SouthToNorthRoutingStrategyType =>
      south_to_north_routing_strategy_get_port_position_on_hyper_node(port)
  }
}

///|
pub fn BaseRoutingDirectionStrategy::get_source_port_side(
  self : BaseRoutingDirectionStrategy,
) -> @core.PortSide {
  match self.strategy_type {
    WestToEastRoutingStrategyType =>
      west_to_east_routing_strategy_get_source_port_side()
    NorthToSouthRoutingStrategyType =>
      north_to_south_routing_strategy_get_source_port_side()
    SouthToNorthRoutingStrategyType =>
      south_to_north_routing_strategy_get_source_port_side()
  }
}

///|
pub fn BaseRoutingDirectionStrategy::get_target_port_side(
  self : BaseRoutingDirectionStrategy,
) -> @core.PortSide {
  match self.strategy_type {
    WestToEastRoutingStrategyType =>
      west_to_east_routing_strategy_get_target_port_side()
    NorthToSouthRoutingStrategyType =>
      north_to_south_routing_strategy_get_target_port_side()
    SouthToNorthRoutingStrategyType =>
      south_to_north_routing_strategy_get_target_port_side()
  }
}

///|
pub fn BaseRoutingDirectionStrategy::calculate_bend_points(
  self : BaseRoutingDirectionStrategy,
  segment : HyperEdgeSegment,
  start_pos : Double,
  edge_spacing : Double,
) -> Unit {
  match self.strategy_type {
    WestToEastRoutingStrategyType =>
      west_to_east_routing_strategy_calculate_bend_points(
        self, segment, start_pos, edge_spacing,
      )
    NorthToSouthRoutingStrategyType =>
      north_to_south_routing_strategy_calculate_bend_points(
        self, segment, start_pos, edge_spacing,
      )
    SouthToNorthRoutingStrategyType =>
      south_to_north_routing_strategy_calculate_bend_points(
        self, segment, start_pos, edge_spacing,
      )
  }
}
