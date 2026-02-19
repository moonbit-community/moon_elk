///|
pub fn new_west_to_east_routing_strategy() -> BaseRoutingDirectionStrategy {
  new_base_routing_direction_strategy(WestToEastRoutingStrategyType)
}

///|
fn west_to_east_routing_strategy_get_port_position_on_hyper_node(
  port : LPort,
) -> Double {
  let node = port.get_node().unwrap()
  node.get_position().y + port.get_position().y + port.get_anchor().y
}

///|
fn west_to_east_routing_strategy_get_source_port_side() -> PortSide {
  East
}

///|
fn west_to_east_routing_strategy_get_target_port_side() -> PortSide {
  West
}

///|
fn west_to_east_routing_strategy_calculate_bend_points(
  strategy : BaseRoutingDirectionStrategy,
  segment : HyperEdgeSegment,
  start_pos : Double,
  edge_spacing : Double,
) -> Unit {
  if segment.is_dummy() {
    return
  }

  let segment_x = start_pos +
    segment.get_routing_slot().to_double() * edge_spacing

  for port in segment.get_ports() {
    let source_y = port.get_absolute_anchor().y

    for edge in port.get_outgoing_edges() {
      if edge.is_self_loop() {
        continue
      }

      let target = edge.get_target().unwrap()
      let target_y = target.get_absolute_anchor().y

      if (source_y - target_y).abs() <= orthogonal_routing_generator_tolerance {
        continue
      }

      let mut current_x = segment_x
      let mut current_segment = segment

      let mut bend = new_kvector_xy(current_x, source_y)
      edge.get_bend_points().add_vector(bend)
      strategy.add_junction_point_if_necessary(
        edge, current_segment, bend, true,
      )

      match segment.get_split_partner() {
        Some(split_partner) => {
          let split_y = split_partner.get_incoming_connection_coordinates()[0]

          bend = new_kvector_xy(current_x, split_y)
          edge.get_bend_points().add_vector(bend)
          strategy.add_junction_point_if_necessary(
            edge, current_segment, bend, true,
          )

          current_x = start_pos +
            split_partner.get_routing_slot().to_double() * edge_spacing
          current_segment = split_partner

          bend = new_kvector_xy(current_x, split_y)
          edge.get_bend_points().add_vector(bend)
          strategy.add_junction_point_if_necessary(
            edge, current_segment, bend, true,
          )
        }
        None => ()
      }

      bend = new_kvector_xy(current_x, target_y)
      edge.get_bend_points().add_vector(bend)
      strategy.add_junction_point_if_necessary(
        edge, current_segment, bend, true,
      )
    }
  }
}
