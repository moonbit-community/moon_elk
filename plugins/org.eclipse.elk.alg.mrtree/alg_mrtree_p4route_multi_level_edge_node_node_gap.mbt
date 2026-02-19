///|
pub struct MrtreeMultiLevelEdgeNodeNodeGap {
  neighbor_one : MrtreeNode?
  neighbor_two : MrtreeNode?
  bend_points : Array[Triple[KVector, KVector, MrtreeEdge]]
  direction_value : String
  node_bendpoint_padding : Double
  mut on_first_node_side : Bool
  mut on_last_node_side : Bool
}

///|
fn mrtree_multi_level_gap_update_bend_points(
  gap : MrtreeMultiLevelEdgeNodeNodeGap,
) -> Unit {
  let count = gap.bend_points.length()
  let mut index = 0
  for bend_triple in gap.bend_points {
    let interpolation = (index + 1).to_double() / (count + 1).to_double()
    let bend1 = new_kvector()
    let bend2 = new_kvector()
    let mut bend_tmp = 0.0

    match (gap.neighbor_one, gap.neighbor_two) {
      (None, None) => return
      (Some(neighbor_one), None) => {
        gap.on_last_node_side = true
        if gap.direction_value == "LEFT" {
          bend_tmp = mrtree_node_position(neighbor_one).y +
            mrtree_node_size(neighbor_one).y +
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "RIGHT" {
          bend_tmp = mrtree_node_position(neighbor_one).y +
            mrtree_node_size(neighbor_one).y +
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "UP" {
          bend_tmp = mrtree_node_position(neighbor_one).x +
            mrtree_node_size(neighbor_one).x +
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
        } else {
          bend_tmp = mrtree_node_position(neighbor_one).x +
            mrtree_node_size(neighbor_one).x +
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
        }
      }
      (Some(neighbor_one), Some(neighbor_two)) =>
        if gap.direction_value == "LEFT" {
          bend_tmp = mrtree_node_position(neighbor_two).y * interpolation +
            (
              mrtree_node_position(neighbor_one).y +
              mrtree_node_size(neighbor_one).y
            ) *
            (1.0 - interpolation)
          bend1.x = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "RIGHT" {
          bend_tmp = mrtree_node_position(neighbor_two).y * interpolation +
            (
              mrtree_node_position(neighbor_one).y +
              mrtree_node_size(neighbor_one).y
            ) *
            (1.0 - interpolation)
          bend1.x = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "UP" {
          bend_tmp = mrtree_node_position(neighbor_two).x * interpolation +
            (
              mrtree_node_position(neighbor_one).x +
              mrtree_node_size(neighbor_one).x
            ) *
            (1.0 - interpolation)
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
        } else {
          bend_tmp = mrtree_node_position(neighbor_two).x * interpolation +
            (
              mrtree_node_position(neighbor_one).x +
              mrtree_node_size(neighbor_one).x
            ) *
            (1.0 - interpolation)
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_min(neighbor_one) -
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_max(neighbor_one) +
            gap.node_bendpoint_padding
        }
      (None, Some(neighbor_two)) => {
        gap.on_first_node_side = true
        if gap.direction_value == "LEFT" {
          bend_tmp = mrtree_node_position(neighbor_two).y -
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = mrtree_node_level_max(neighbor_two) +
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_min(neighbor_two) -
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "RIGHT" {
          bend_tmp = mrtree_node_position(neighbor_two).y -
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = mrtree_node_level_min(neighbor_two) -
            gap.node_bendpoint_padding
          bend1.y = bend_tmp
          bend2.x = mrtree_node_level_max(neighbor_two) +
            gap.node_bendpoint_padding
          bend2.y = bend_tmp
        } else if gap.direction_value == "UP" {
          bend_tmp = mrtree_node_position(neighbor_two).x -
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_max(neighbor_two) +
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_min(neighbor_two) -
            gap.node_bendpoint_padding
        } else {
          bend_tmp = mrtree_node_position(neighbor_two).x -
            gap.node_bendpoint_padding * (index + 1).to_double()
          bend1.x = bend_tmp
          bend1.y = mrtree_node_level_min(neighbor_two) -
            gap.node_bendpoint_padding
          bend2.x = bend_tmp
          bend2.y = mrtree_node_level_max(neighbor_two) +
            gap.node_bendpoint_padding
        }
      }
    }

    let first_bend = bend_triple.get_first()
    first_bend.x = bend1.x
    first_bend.y = bend1.y
    let second_bend = bend_triple.get_second()
    second_bend.x = bend2.x
    second_bend.y = bend2.y
    index += 1
  }
}

///|
pub fn new_mrtree_multi_level_edge_node_node_gap(
  neighbor_one : MrtreeNode?,
  neighbor_two : MrtreeNode?,
  bend_triple : Triple[KVector, KVector, MrtreeEdge],
  graph : MrtreeGraph,
) -> MrtreeMultiLevelEdgeNodeNodeGap {
  let gap = {
    neighbor_one,
    neighbor_two,
    bend_points: [bend_triple],
    direction_value: mrtree_graph_direction(graph),
    node_bendpoint_padding: mrtree_graph_spacing_edge_node(graph),
    on_first_node_side: false,
    on_last_node_side: false,
  }
  mrtree_multi_level_gap_update_bend_points(gap)
  gap
}

///|
pub fn MrtreeMultiLevelEdgeNodeNodeGap::add_bend_points(
  self : MrtreeMultiLevelEdgeNodeNodeGap,
  new_bends : Triple[KVector, KVector, MrtreeEdge],
) -> Unit {
  self.bend_points.push(new_bends)

  let length = self.bend_points.length()
  for i in 1..<length {
    let current = self.bend_points[i]
    let current_edge = current.get_third()
    let current_target = mrtree_edge_target(current_edge)
    let current_value = if mrtree_tree_util_direction_is_horizontal(
        self.direction_value,
      ) {
      mrtree_node_position(current_target).y
    } else {
      mrtree_node_position(current_target).x
    }
    let mut j = i
    while j > 0 {
      let prev_edge = self.bend_points[j - 1].get_third()
      let prev_target = mrtree_edge_target(prev_edge)
      let prev_value = if mrtree_tree_util_direction_is_horizontal(
          self.direction_value,
        ) {
        mrtree_node_position(prev_target).y
      } else {
        mrtree_node_position(prev_target).x
      }
      if current_value >= prev_value {
        break
      }
      self.bend_points[j] = self.bend_points[j - 1]
      j -= 1
    }
    self.bend_points[j] = current
  }

  mrtree_multi_level_gap_update_bend_points(self)
}

///|
pub fn MrtreeMultiLevelEdgeNodeNodeGap::neighbor_one(
  self : MrtreeMultiLevelEdgeNodeNodeGap,
) -> MrtreeNode? {
  self.neighbor_one
}

///|
pub fn MrtreeMultiLevelEdgeNodeNodeGap::neighbor_two(
  self : MrtreeMultiLevelEdgeNodeNodeGap,
) -> MrtreeNode? {
  self.neighbor_two
}

///|
pub fn MrtreeMultiLevelEdgeNodeNodeGap::on_first_node_side(
  self : MrtreeMultiLevelEdgeNodeNodeGap,
) -> Bool {
  self.on_first_node_side
}

///|
pub fn MrtreeMultiLevelEdgeNodeNodeGap::on_last_node_side(
  self : MrtreeMultiLevelEdgeNodeNodeGap,
) -> Bool {
  self.on_last_node_side
}
