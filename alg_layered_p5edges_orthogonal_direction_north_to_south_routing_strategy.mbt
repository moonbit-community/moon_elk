///|
pub fn new_north_to_south_routing_strategy() -> BaseRoutingDirectionStrategy {
  new_base_routing_direction_strategy(NorthToSouthRoutingStrategyType)
}

///|
fn north_to_south_routing_strategy_get_port_position_on_hyper_node(
  port : LPort,
) -> Double {
  let node = port.get_node().unwrap()
  node.get_position().x + port.get_position().x + port.get_anchor().x
}

///|
fn north_to_south_routing_strategy_get_source_port_side() -> PortSide {
  South
}

///|
fn north_to_south_routing_strategy_get_target_port_side() -> PortSide {
  North
}

///|
fn north_to_south_routing_strategy_calculate_bend_points(
  strategy : BaseRoutingDirectionStrategy,
  segment : HyperEdgeSegment,
  start_pos : Double,
  edge_spacing : Double,
) -> Unit {
  if segment.is_dummy() {
    return
  }

  let segment_y = start_pos +
    segment.get_routing_slot().to_double() * edge_spacing

  for port in segment.get_ports() {
    let source_x = port.get_absolute_anchor().x

    for edge in port.get_outgoing_edges() {
      if edge.is_self_loop() {
        continue
      }

      let target = edge.get_target().unwrap()
      let target_x = target.get_absolute_anchor().x

      if (source_x - target_x).abs() <= orthogonal_routing_generator_tolerance {
        continue
      }

      let mut current_y = segment_y
      let mut current_segment = segment

      let mut bend = new_kvector_xy(source_x, current_y)
      edge.get_bend_points().add_vector(bend)
      strategy.add_junction_point_if_necessary(
        edge, current_segment, bend, false,
      )

      match segment.get_split_partner() {
        Some(split_partner) => {
          let split_x = split_partner.get_incoming_connection_coordinates()[0]

          bend = new_kvector_xy(split_x, current_y)
          edge.get_bend_points().add_vector(bend)
          strategy.add_junction_point_if_necessary(
            edge, current_segment, bend, false,
          )

          current_y = start_pos +
            split_partner.get_routing_slot().to_double() * edge_spacing
          current_segment = split_partner

          bend = new_kvector_xy(split_x, current_y)
          edge.get_bend_points().add_vector(bend)
          strategy.add_junction_point_if_necessary(
            edge, current_segment, bend, false,
          )
        }
        None => ()
      }

      bend = new_kvector_xy(target_x, current_y)
      edge.get_bend_points().add_vector(bend)
      strategy.add_junction_point_if_necessary(
        edge, current_segment, bend, false,
      )
    }
  }
}
