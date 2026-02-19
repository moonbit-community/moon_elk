///|
priv struct MrtreeEdgeRouterSideCounts {
  mut side_one : Int
  mut side_two : Int
}

///|
priv struct MrtreeEdgeRouterInOutCounts {
  incoming : Int
  outgoing : Int
}

///|
fn mrtree_edge_router_layout_processor_configuration(
  graph : MrtreeGraph,
) -> @core.LayoutProcessorConfiguration[MrtreeTreeLayoutPhases, MrtreeGraph]? {
  ignore(graph)
  Some(
    @core.layout_processor_configuration_create(
      mrtree_tree_layout_phase_descriptor,
    )
    .before(MrtreeTreeLayoutPhases::P4EdgeRouting)
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::LevelCoords,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::CompactionProc,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::GraphBoundsProc,
      ),
    ),
  )
}

///|
fn mrtree_edge_router_middle_to_middle_edge_route(edge : MrtreeEdge) -> Unit {
  let bend_points = mrtree_edge_bend_points(edge)
  let source = mrtree_edge_source(edge)
  let target = mrtree_edge_target(edge)
  let source_point = @core.new_kvector_xy(
    mrtree_node_position(source).x + mrtree_node_size(source).x / 2.0,
    mrtree_node_position(source).y + mrtree_node_size(source).y / 2.0,
  )
  let target_point = @core.new_kvector_xy(
    mrtree_node_position(target).x + mrtree_node_size(target).x / 2.0,
    mrtree_node_position(target).y + mrtree_node_size(target).y / 2.0,
  )
  bend_points.add_first_vector(source_point)
  bend_points.add_last_vector(target_point)
  mrtree_tree_util_to_node_border(
    source_point,
    bend_points.get(1),
    mrtree_node_size(source),
  )
  mrtree_tree_util_to_node_border(
    target_point,
    bend_points.get(bend_points.size() - 2),
    mrtree_node_size(target),
  )
}

///|
fn mrtree_edge_router_middle_to_middle(graph : MrtreeGraph) -> Unit {
  for edge in mrtree_graph_edges(graph) {
    mrtree_edge_router_middle_to_middle_edge_route(edge)
  }
}

///|
fn mrtree_edge_router_sort_nodes_by_level_axis(
  nodes : Array[MrtreeNode],
  direction_value : String,
) -> Unit {
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_value = if mrtree_tree_util_direction_is_horizontal(
        direction_value,
      ) {
      mrtree_node_position(current).y
    } else {
      mrtree_node_position(current).x
    }
    let mut j = i
    while j > 0 {
      let prev_value = if mrtree_tree_util_direction_is_horizontal(
          direction_value,
        ) {
        mrtree_node_position(nodes[j - 1]).y
      } else {
        mrtree_node_position(nodes[j - 1]).x
      }
      if current_value >= prev_value {
        break
      }
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_edge_router_average_tree_middle(
  graph : MrtreeGraph,
  direction_value : String,
) -> Double {
  let nodes = mrtree_graph_nodes(graph)
  if nodes.is_empty() {
    return 0.0
  }
  let mut sum = 0.0
  for node in nodes {
    if mrtree_tree_util_direction_is_horizontal(direction_value) {
      sum += mrtree_node_position(node).y + mrtree_node_size(node).y / 2.0
    } else {
      sum += mrtree_node_position(node).x + mrtree_node_size(node).x / 2.0
    }
  }
  sum / nodes.length().to_double()
}

///|
fn mrtree_edge_router_max_side_position(
  graph : MrtreeGraph,
  direction_value : String,
  side_edges : Int,
  node_bendpoint_padding : Double,
  upper_side : Bool,
) -> Double {
  let mut value = if upper_side { -1.0e20 } else { 1.0e20 }
  for node in mrtree_graph_nodes(graph) {
    if mrtree_tree_util_direction_is_horizontal(direction_value) {
      let candidate = if upper_side {
        mrtree_node_position(node).y +
        mrtree_node_size(node).y +
        node_bendpoint_padding * side_edges.to_double()
      } else {
        mrtree_node_position(node).y -
        node_bendpoint_padding * side_edges.to_double()
      }
      value = if upper_side {
        if candidate > value {
          candidate
        } else {
          value
        }
      } else if candidate < value {
        candidate
      } else {
        value
      }
    } else {
      let candidate = if upper_side {
        mrtree_node_position(node).x +
        mrtree_node_size(node).x +
        node_bendpoint_padding * side_edges.to_double()
      } else {
        mrtree_node_position(node).x -
        node_bendpoint_padding * side_edges.to_double()
      }
      value = if upper_side {
        if candidate > value {
          candidate
        } else {
          value
        }
      } else if candidate < value {
        candidate
      } else {
        value
      }
    }
  }
  value
}

///|
fn mrtree_edge_router_handle_cycle_inducing_edge(
  edge : MrtreeEdge,
  direction_value : String,
  graph : MrtreeGraph,
  side_counts : MrtreeEdgeRouterSideCounts,
  node_bendpoint_padding : Double,
  edge_end_texture_padding : Double,
  in_out_counts : MrtreeEdgeRouterInOutCounts,
) -> MrtreeEdgeRouterSideCounts {
  let mut side_one_edges = side_counts.side_one
  let mut side_two_edges = side_counts.side_two

  let source = mrtree_edge_source(edge)
  let target = mrtree_edge_target(edge)
  let middle_tree = mrtree_edge_router_average_tree_middle(
    graph, direction_value,
  )

  let source_center = if mrtree_tree_util_direction_is_horizontal(
      direction_value,
    ) {
    mrtree_node_position(source).y + mrtree_node_size(source).y / 2.0
  } else {
    mrtree_node_position(source).x + mrtree_node_size(source).x / 2.0
  }

  let bend_tmp = if source_center > middle_tree {
    side_two_edges += 1
    mrtree_edge_router_max_side_position(
      graph, direction_value, side_two_edges, node_bendpoint_padding, true,
    )
  } else {
    side_one_edges += 1
    mrtree_edge_router_max_side_position(
      graph, direction_value, side_one_edges, node_bendpoint_padding, false,
    )
  }

  let bends = mrtree_edge_bend_points(edge)
  if direction_value == "LEFT" {
    bends.add_xy(
      mrtree_node_level_min(source) - node_bendpoint_padding,
      bend_tmp,
    )
    bends.add_xy(
      mrtree_node_position(target).x +
      mrtree_node_size(target).x +
      node_bendpoint_padding +
      edge_end_texture_padding,
      bend_tmp,
    )
    bends.add_xy(
      mrtree_node_position(target).x +
      mrtree_node_size(target).x +
      node_bendpoint_padding +
      edge_end_texture_padding,
      mrtree_node_position(target).y + mrtree_node_size(target).y / 2.0,
    )
    bends.add_xy(
      mrtree_node_position(target).x + mrtree_node_size(target).x,
      mrtree_node_position(target).y + mrtree_node_size(target).y / 2.0,
    )
  } else if direction_value == "RIGHT" {
    bends.add_xy(
      mrtree_node_level_max(source) + node_bendpoint_padding,
      mrtree_node_position(source).y + mrtree_node_size(source).y / 2.0,
    )
    bends.add_xy(
      mrtree_node_position(source).x +
      mrtree_node_size(source).x +
      node_bendpoint_padding,
      bend_tmp,
    )
    bends.add_xy(
      mrtree_node_position(target).x -
      node_bendpoint_padding -
      edge_end_texture_padding,
      bend_tmp,
    )
    bends.add_xy(
      mrtree_node_position(target).x -
      node_bendpoint_padding -
      edge_end_texture_padding,
      mrtree_node_position(target).y + mrtree_node_size(target).y / 2.0,
    )
    bends.add_xy(
      mrtree_node_position(target).x,
      mrtree_node_position(target).y + mrtree_node_size(target).y / 2.0,
    )
  } else if direction_value == "UP" {
    bends.add_xy(
      bend_tmp,
      mrtree_node_level_min(source) - node_bendpoint_padding,
    )
    bends.add_xy(
      bend_tmp,
      mrtree_node_position(target).y +
      mrtree_node_size(target).y +
      node_bendpoint_padding +
      edge_end_texture_padding,
    )
    bends.add_xy(
      mrtree_node_position(target).x + mrtree_node_size(target).x / 2.0,
      mrtree_node_position(target).y +
      mrtree_node_size(target).y +
      node_bendpoint_padding +
      edge_end_texture_padding,
    )
    bends.add_xy(
      mrtree_node_position(target).x + mrtree_node_size(target).x / 2.0,
      mrtree_node_position(target).y +
      mrtree_node_size(target).y +
      node_bendpoint_padding,
    )
  } else {
    if bends.size() > 0 {
      bends.get(bends.size() - 1).y = mrtree_node_level_max(source) +
        node_bendpoint_padding * in_out_counts.outgoing.to_double()
    }
    bends.add_xy(
      bend_tmp,
      mrtree_node_level_max(source) +
      node_bendpoint_padding * in_out_counts.outgoing.to_double(),
    )
    bends.add_xy(
      bend_tmp,
      mrtree_node_position(target).y -
      node_bendpoint_padding * in_out_counts.incoming.to_double() -
      edge_end_texture_padding,
    )
  }

  { side_one: side_one_edges, side_two: side_two_edges }
}

///|
fn mrtree_edge_router_avoid_overlap_set_start_points(
  graph : MrtreeGraph,
  direction_value : String,
  node_bendpoint_padding : Double,
) -> Unit {
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_label(node) == "SUPER_ROOT" {
      continue
    }

    let outgoing_edges = mrtree_tree_util_get_all_outgoing_edges(node, graph)
    let length = outgoing_edges.length()
    for i in 1..<length {
      let current = outgoing_edges[i]
      let current_value = if mrtree_tree_util_direction_is_horizontal(
          direction_value,
        ) {
        mrtree_tree_util_get_first_point(current).y
      } else {
        mrtree_tree_util_get_first_point(current).x
      }
      let mut j = i
      while j > 0 {
        let previous_value = if mrtree_tree_util_direction_is_horizontal(
            direction_value,
          ) {
          mrtree_tree_util_get_first_point(outgoing_edges[j - 1]).y
        } else {
          mrtree_tree_util_get_first_point(outgoing_edges[j - 1]).x
        }
        if current_value >= previous_value {
          break
        }
        outgoing_edges[j] = outgoing_edges[j - 1]
        j -= 1
      }
      outgoing_edges[j] = current
    }

    let num = outgoing_edges.length()
    for i in 0..<num {
      let edge = outgoing_edges[i]
      if mrtree_node_compact_level_ascension(node) &&
        !mrtree_tree_util_is_cycle_inducing(edge, graph) {
        continue
      }
      let interpolation = if num == 1 {
        0.5
      } else {
        (i + 1).to_double() / (num + 1).to_double()
      }

      if direction_value == "LEFT" {
        let level_end_coord = mrtree_node_level_min(node)
        let y = mrtree_node_position(node).y +
          mrtree_node_size(node).y * interpolation
        mrtree_edge_bend_points(edge).add_first_xy(
          @cmp.minimum(
            level_end_coord,
            mrtree_node_position(node).x - node_bendpoint_padding,
          ),
          y,
        )
        mrtree_edge_bend_points(edge).add_first_xy(
          mrtree_node_position(node).x,
          y,
        )
      } else if direction_value == "RIGHT" {
        let level_end_coord = mrtree_node_level_max(node) +
          node_bendpoint_padding
        let y = mrtree_node_position(node).y +
          mrtree_node_size(node).y * interpolation
        mrtree_edge_bend_points(edge).add_first_xy(level_end_coord, y)
        mrtree_edge_bend_points(edge).add_first_xy(
          mrtree_node_position(node).x + mrtree_node_size(node).x,
          y,
        )
      } else if direction_value == "UP" {
        let level_end_coord = mrtree_node_level_min(node)
        let x = mrtree_node_position(node).x +
          mrtree_node_size(node).x * interpolation
        mrtree_edge_bend_points(edge).add_first_xy(
          x,
          @cmp.minimum(
            mrtree_node_position(node).y - node_bendpoint_padding,
            level_end_coord,
          ),
        )
        mrtree_edge_bend_points(edge).add_first_xy(
          x,
          mrtree_node_position(node).y,
        )
      } else {
        let level_end_coord = mrtree_node_level_max(node) +
          node_bendpoint_padding
        let x = mrtree_node_position(node).x +
          mrtree_node_size(node).x * interpolation
        mrtree_edge_bend_points(edge).add_first_xy(x, level_end_coord)
        mrtree_edge_bend_points(edge).add_first_xy(
          x,
          mrtree_node_position(node).y + mrtree_node_size(node).y,
        )
      }
    }
  }
}

///|
fn mrtree_edge_router_avoid_overlap_set_end_points(
  graph : MrtreeGraph,
  direction_value : String,
  node_bendpoint_padding : Double,
  edge_end_texture_padding : Double,
) -> Unit {
  let steep_end_edge_threshold_distance = 50.0
  let steep_end_edge_ratio = 5.3
  let steep_end_edge_sample_height = 40.0

  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_label(node) == "SUPER_ROOT" {
      continue
    }

    let incoming_edges = mrtree_tree_util_get_all_incoming_edges(node, graph)
    let length = incoming_edges.length()
    for i in 1..<length {
      let current = incoming_edges[i]
      let current_value = if mrtree_tree_util_direction_is_horizontal(
          direction_value,
        ) {
        mrtree_tree_util_get_last_point(current).y
      } else {
        mrtree_tree_util_get_last_point(current).x
      }
      let mut j = i
      while j > 0 {
        let previous_value = if mrtree_tree_util_direction_is_horizontal(
            direction_value,
          ) {
          mrtree_tree_util_get_last_point(incoming_edges[j - 1]).y
        } else {
          mrtree_tree_util_get_last_point(incoming_edges[j - 1]).x
        }
        if current_value >= previous_value {
          break
        }
        incoming_edges[j] = incoming_edges[j - 1]
        j -= 1
      }
      incoming_edges[j] = current
    }

    let num = incoming_edges.length()
    for i in 0..<num {
      let edge = incoming_edges[i]
      let interpolation = if num == 1 {
        0.5
      } else {
        (i + 1).to_double() / (num + 1).to_double()
      }
      let bends = mrtree_edge_bend_points(edge)

      if direction_value == "LEFT" {
        let level_start_coord = mrtree_node_level_max(node)
        if mrtree_node_position(node).x +
          mrtree_node_size(node).x +
          edge_end_texture_padding <
          level_start_coord {
          bends.add_xy(
            level_start_coord + node_bendpoint_padding,
            mrtree_node_position(node).y +
            mrtree_node_size(node).y * interpolation,
          )
        } else if bends.size() > 0 {
          let last = bends.get(bends.size() - 1)
          let next_x = mrtree_node_position(node).x +
            mrtree_node_size(node).x / 2.0
          let next_y = mrtree_node_position(node).y +
            mrtree_node_size(node).y / 2.0
          if edge_end_texture_padding > 0.0 &&
            (last.y - next_y).abs() /
            ((last.x - next_x).abs() / steep_end_edge_sample_height) >
            steep_end_edge_threshold_distance {
            if next_y > last.y {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x +
                edge_end_texture_padding / steep_end_edge_ratio,
                mrtree_node_position(node).y +
                mrtree_node_size(node).y * interpolation -
                edge_end_texture_padding / 2.0,
              )
            } else {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x +
                edge_end_texture_padding / steep_end_edge_ratio,
                mrtree_node_position(node).y +
                mrtree_node_size(node).y * interpolation +
                edge_end_texture_padding / 2.0,
              )
            }
          }
        }
        bends.add_xy(
          mrtree_node_position(node).x + mrtree_node_size(node).x,
          mrtree_node_position(node).y +
          mrtree_node_size(node).y * interpolation,
        )
      } else if direction_value == "RIGHT" {
        let level_start_coord = mrtree_node_level_min(node)
        if mrtree_node_position(node).x - edge_end_texture_padding >
          level_start_coord {
          bends.add_xy(
            level_start_coord - node_bendpoint_padding,
            mrtree_node_position(node).y +
            mrtree_node_size(node).y * interpolation,
          )
        } else if bends.size() > 0 {
          let last = bends.get(bends.size() - 1)
          let next_x = mrtree_node_position(node).x +
            mrtree_node_size(node).x / 2.0
          let next_y = mrtree_node_position(node).y +
            mrtree_node_size(node).y / 2.0
          if edge_end_texture_padding > 0.0 &&
            (last.y - next_y).abs() /
            ((last.x - next_x).abs() / steep_end_edge_sample_height) >
            steep_end_edge_threshold_distance {
            if next_y > last.y {
              bends.add_xy(
                mrtree_node_position(node).x -
                edge_end_texture_padding / steep_end_edge_ratio,
                mrtree_node_position(node).y +
                mrtree_node_size(node).y * interpolation -
                edge_end_texture_padding / 2.0,
              )
            } else {
              bends.add_xy(
                mrtree_node_position(node).x -
                edge_end_texture_padding / steep_end_edge_ratio,
                mrtree_node_position(node).y +
                mrtree_node_size(node).y * interpolation +
                edge_end_texture_padding / 2.0,
              )
            }
          }
        }
        bends.add_xy(
          mrtree_node_position(node).x,
          mrtree_node_position(node).y +
          mrtree_node_size(node).y * interpolation,
        )
      } else if direction_value == "UP" {
        let level_start_coord = mrtree_node_level_max(node)
        if mrtree_node_position(node).y +
          mrtree_node_size(node).y +
          edge_end_texture_padding <
          level_start_coord {
          bends.add_xy(
            mrtree_node_position(node).x +
            mrtree_node_size(node).x * interpolation,
            level_start_coord + node_bendpoint_padding,
          )
        } else if bends.size() > 0 {
          let last = bends.get(bends.size() - 1)
          let next_x = mrtree_node_position(node).x +
            mrtree_node_size(node).x / 2.0
          let next_y = mrtree_node_position(node).y +
            mrtree_node_size(node).y / 2.0
          if edge_end_texture_padding > 0.0 &&
            (last.x - next_x).abs() /
            ((last.y - next_y).abs() / steep_end_edge_sample_height) >
            steep_end_edge_threshold_distance {
            if next_x > last.x {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x * interpolation -
                edge_end_texture_padding / 2.0,
                mrtree_node_position(node).y +
                edge_end_texture_padding / steep_end_edge_ratio +
                mrtree_node_size(node).y,
              )
            } else {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x * interpolation +
                edge_end_texture_padding / 2.0,
                mrtree_node_position(node).y +
                edge_end_texture_padding / steep_end_edge_ratio +
                mrtree_node_size(node).y,
              )
            }
          }
        }
        bends.add_xy(
          mrtree_node_position(node).x +
          mrtree_node_size(node).x * interpolation,
          mrtree_node_position(node).y + mrtree_node_size(node).y,
        )
      } else {
        let level_start_coord = mrtree_node_level_min(node)
        if mrtree_tree_util_is_cycle_inducing(edge, graph) {
          bends.add_xy(
            mrtree_node_position(node).x +
            mrtree_node_size(node).x * interpolation,
            bends.get(bends.size() - 1).y,
          )
        } else if mrtree_node_position(node).y - edge_end_texture_padding >
          level_start_coord {
          bends.add_xy(
            mrtree_node_position(node).x +
            mrtree_node_size(node).x * interpolation,
            level_start_coord - node_bendpoint_padding,
          )
        } else if bends.size() > 0 {
          let last = bends.get(bends.size() - 1)
          let next_x = mrtree_node_position(node).x +
            mrtree_node_size(node).x / 2.0
          let next_y = mrtree_node_position(node).y +
            mrtree_node_size(node).y / 2.0
          if edge_end_texture_padding > 0.0 &&
            (last.x - next_x).abs() /
            ((last.y - next_y).abs() / steep_end_edge_sample_height) >
            steep_end_edge_threshold_distance {
            if next_x > last.x {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x * interpolation -
                edge_end_texture_padding / 2.0,
                mrtree_node_position(node).y -
                edge_end_texture_padding / steep_end_edge_ratio,
              )
            } else {
              bends.add_xy(
                mrtree_node_position(node).x +
                mrtree_node_size(node).x * interpolation +
                edge_end_texture_padding / 2.0,
                mrtree_node_position(node).y -
                edge_end_texture_padding / steep_end_edge_ratio,
              )
            }
          }
        }
        bends.add_xy(
          mrtree_node_position(node).x +
          mrtree_node_size(node).x * interpolation,
          mrtree_node_position(node).y,
        )
      }
    }
  }
}

///|
fn mrtree_edge_router_avoid_overlap_special_edges(
  graph : MrtreeGraph,
  direction_value : String,
  node_bendpoint_padding : Double,
  edge_end_texture_padding : Double,
) -> Unit {
  let mut side_counts = { side_one: 0, side_two: 0 }
  let node_gaps : Map[Int, MrtreeMultiLevelEdgeNodeNodeGap] = {}

  let mut max_level = 0
  for node in mrtree_graph_nodes(graph) {
    let level = mrtree_node_tree_level(node) + 1
    if level > max_level {
      max_level = level
    }
  }
  let outs_per_level = []
  let ins_per_level = []
  for _ in 0..<max_level {
    outs_per_level.push(0)
    ins_per_level.push(0)
  }

  let distinct_edges = mrtree_graph_edges(graph).copy()
  for edge in distinct_edges {
    let source_level = mrtree_node_tree_level(mrtree_edge_source(edge))
    let target_level = mrtree_node_tree_level(mrtree_edge_target(edge))
    let level_diff = target_level - source_level

    if level_diff > 1 {
      let mut current_level = source_level + 1
      while current_level < target_level {
        let next_level_nodes = []
        for node in mrtree_graph_nodes(graph) {
          if mrtree_node_tree_level(node) == current_level {
            next_level_nodes.push(node)
          }
        }
        mrtree_edge_router_sort_nodes_by_level_axis(
          next_level_nodes, direction_value,
        )

        let mut index = 0
        for i in 0..<next_level_nodes.length() {
          let interpolation = (current_level - source_level).to_double() /
            (target_level - source_level).to_double()
          let source_position = mrtree_node_position(mrtree_edge_source(edge))
          let target_position = mrtree_node_position(mrtree_edge_target(edge))
          let interpolation_value = if mrtree_tree_util_direction_is_horizontal(
              direction_value,
            ) {
            source_position.y * (1.0 - interpolation) +
            target_position.y * interpolation
          } else {
            source_position.x * (1.0 - interpolation) +
            target_position.x * interpolation
          }
          let current_position = if mrtree_tree_util_direction_is_horizontal(
              direction_value,
            ) {
            mrtree_node_position(next_level_nodes[i]).y
          } else {
            mrtree_node_position(next_level_nodes[i]).x
          }
          if current_position > interpolation_value {
            index = i
            break
          }
          index = i + 1
        }

        if !next_level_nodes.is_empty() {
          let start = if mrtree_edge_bend_points(edge).size() == 0 {
            @core.new_kvector_copy(
              mrtree_node_position(mrtree_edge_source(edge)),
            )
          } else {
            mrtree_edge_bend_points(edge).get(
              mrtree_edge_bend_points(edge).size() - 1,
            )
          }
          let last_node = next_level_nodes[next_level_nodes.length() - 1]
          let first_node = next_level_nodes[0]
          let last = @core.new_kvector_copy(mrtree_node_position(last_node))
          ignore(last.add(mrtree_node_size(last_node)))
          let first = @core.new_kvector_copy(mrtree_node_position(first_node))
          ignore(first.add(mrtree_node_size(first_node)))

          if mrtree_tree_util_direction_is_horizontal(direction_value) {
            if index >= next_level_nodes.length() - 1 &&
              start.y > last.y &&
              mrtree_node_position(mrtree_edge_target(edge)).y > last.y {
              continue
            }
            if index <= 0 &&
              start.y < first.x &&
              mrtree_node_position(mrtree_edge_target(edge)).y < first.y {
              continue
            }
          } else {
            if index >= next_level_nodes.length() - 1 &&
              start.x > last.x &&
              mrtree_node_position(mrtree_edge_target(edge)).x > last.x {
              continue
            }
            if index <= 0 &&
              start.x < first.x &&
              mrtree_node_position(mrtree_edge_target(edge)).x < first.x {
              continue
            }
          }
        }

        let bend1 = @core.new_kvector()
        let bend2 = @core.new_kvector()
        mrtree_edge_bend_points(edge).add_vector(bend1)
        mrtree_edge_bend_points(edge).add_vector(bend2)
        let bend_triple = @core.triple_of(bend1, bend2, edge)
        let key = mrtree_tree_util_get_unique_long(current_level, index)

        let gap = match node_gaps.get(key) {
          Some(existing) => {
            existing.add_bend_points(bend_triple)
            existing
          }
          None => {
            let created = new_mrtree_multi_level_edge_node_node_gap(
              if index == 0 {
                None
              } else {
                Some(next_level_nodes[index - 1])
              },
              if index == next_level_nodes.length() {
                None
              } else {
                Some(next_level_nodes[index])
              },
              bend_triple,
              graph,
            )
            node_gaps[key] = created
            created
          }
        }

        if !mrtree_tree_util_direction_is_horizontal(direction_value) {
          if gap.on_first_node_side() {
            match gap.neighbor_two() {
              Some(neighbor_two) =>
                if mrtree_node_position(neighbor_two).x <=
                  mrtree_graph_graph_xmin(graph) {
                  side_counts.side_one += 1
                }
              None => ()
            }
          }
          if gap.on_last_node_side() {
            match gap.neighbor_one() {
              Some(neighbor_one) =>
                if mrtree_node_position(neighbor_one).x +
                  mrtree_node_size(neighbor_one).x >=
                  mrtree_graph_graph_xmax(graph) {
                  side_counts.side_two += 1
                }
              None => ()
            }
          }
        } else {
          if gap.on_first_node_side() {
            match gap.neighbor_two() {
              Some(neighbor_two) =>
                if mrtree_node_position(neighbor_two).y <=
                  mrtree_graph_graph_ymin(graph) {
                  side_counts.side_one += 1
                }
              None => ()
            }
          }
          if gap.on_last_node_side() {
            match gap.neighbor_one() {
              Some(neighbor_one) =>
                if mrtree_node_position(neighbor_one).y +
                  mrtree_node_size(neighbor_one).y >=
                  mrtree_graph_graph_ymax(graph) {
                  side_counts.side_two += 1
                }
              None => ()
            }
          }
        }
        current_level += 1
      }
    } else if level_diff == 0 {
      mrtree_edge_router_middle_to_middle_edge_route(edge)
    } else if level_diff < 0 {
      outs_per_level[source_level] += 1
      ins_per_level[target_level] += 1
      side_counts = mrtree_edge_router_handle_cycle_inducing_edge(
        edge,
        direction_value,
        graph,
        side_counts,
        node_bendpoint_padding,
        edge_end_texture_padding,
        {
          incoming: ins_per_level[target_level],
          outgoing: outs_per_level[source_level],
        },
      )
    }
  }
}

///|
fn mrtree_edge_router_avoid_overlap(graph : MrtreeGraph) -> Unit {
  let node_bendpoint_padding = mrtree_graph_spacing_edge_node(graph)
  let edge_end_texture_padding = mrtree_graph_edge_end_texture_length(graph)
  let direction_value = mrtree_graph_direction(graph)

  mrtree_edge_router_avoid_overlap_set_start_points(
    graph, direction_value, node_bendpoint_padding,
  )
  mrtree_edge_router_avoid_overlap_special_edges(
    graph, direction_value, node_bendpoint_padding, edge_end_texture_padding,
  )
  mrtree_edge_router_avoid_overlap_set_end_points(
    graph, direction_value, node_bendpoint_padding, edge_end_texture_padding,
  )
}

///|
fn mrtree_edge_router_process(
  graph : MrtreeGraph,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Edge routing", 1.0))
    None => ()
  }

  match mrtree_graph_edge_routing_mode(graph) {
    MrtreeEdgeRoutingMode::MIDDLE_TO_MIDDLE =>
      mrtree_edge_router_middle_to_middle(graph)
    MrtreeEdgeRoutingMode::AVOID_OVERLAP => {
      mrtree_edge_router_avoid_overlap(graph)
      for edge in mrtree_graph_edges(graph) {
        if mrtree_edge_bend_points(edge).size() < 2 {
          mrtree_edge_router_middle_to_middle_edge_route(edge)
        }
      }
    }
    MrtreeEdgeRoutingMode::NONE => ()
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_edge_router_layout_phase() -> @core.ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  @core.new_layout_phase(
    mrtree_edge_router_process, mrtree_edge_router_layout_processor_configuration,
  )
}
