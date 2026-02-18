///|
let mrtree_compaction_levels : Ref[Array[KVector]] = Ref::new([])

///|
fn mrtree_compaction_projection(
  node : MrtreeNode,
  direction_vector : KVector,
) -> Double {
  let position = mrtree_node_position(node)
  direction_vector.dot_product(new_kvector_xy(position.x, position.y))
}

///|
fn mrtree_compaction_insert_sorted(
  nodes : Array[MrtreeNode],
  node : MrtreeNode,
  direction_vector : KVector,
) -> Int {
  let node_projection = mrtree_compaction_projection(node, direction_vector)
  let mut index = 0
  while index < nodes.length() &&
        mrtree_compaction_projection(nodes[index], direction_vector) <=
        node_projection {
    index += 1
  }
  nodes.insert(index, node)
  index
}

///|
fn mrtree_compaction_sorted_remove(
  nodes : Array[MrtreeNode],
  node : MrtreeNode,
) -> Int {
  let mut index = 0
  while index < nodes.length() && nodes[index] != node {
    index += 1
  }
  if index < nodes.length() {
    ignore(nodes.remove(index))
  }
  index
}

///|
fn mrtree_compaction_get_lowest_dependent_node(
  node : MrtreeNode,
  direction_value : String,
) -> MrtreeNode? {
  let constraints = mrtree_node_compact_constraints(node)
  if constraints.is_empty() {
    return None
  }
  if constraints.length() == 1 {
    return Some(constraints[0])
  }

  let mut lowest_constraint = constraints[0]
  for constraint in constraints {
    let constraint_position = mrtree_node_position(constraint)
    let lowest_position = mrtree_node_position(lowest_constraint)
    let constraint_size = mrtree_node_size(constraint)
    let lowest_size = mrtree_node_size(lowest_constraint)
    if direction_value == "LEFT" {
      if constraint_position.x < lowest_position.x {
        lowest_constraint = constraint
      }
    } else if direction_value == "RIGHT" {
      if constraint_position.x + constraint_size.x >
        lowest_position.x + lowest_size.x {
        lowest_constraint = constraint
      }
    } else if direction_value == "UP" {
      if constraint_position.y < lowest_position.y {
        lowest_constraint = constraint
      }
    } else if constraint_position.y + constraint_size.y >
      lowest_position.y + lowest_size.y {
      lowest_constraint = constraint
    }
  }
  Some(lowest_constraint)
}

///|
fn mrtree_compaction_set_up_levels(
  graph : MrtreeGraph,
  direction_value : String,
) -> Unit {
  mrtree_compaction_levels.val = []
  for node in mrtree_graph_nodes(graph) {
    while mrtree_node_tree_level(node) >
          mrtree_compaction_levels.val.length() - 1 {
      mrtree_compaction_levels.val.push(new_kvector_xy(1.0e20, -1.0e20))
    }
    let current_level = mrtree_node_tree_level(node)
    let level = mrtree_compaction_levels.val[current_level]
    let position = mrtree_node_position(node)
    let size = mrtree_node_size(node)
    if mrtree_tree_util_direction_is_horizontal(direction_value) {
      if position.x < level.x {
        level.x = position.x
      }
      if position.x + size.x > level.y {
        level.y = position.x + size.x
      }
    } else {
      if position.y < level.x {
        level.x = position.y
      }
      if position.y + size.y > level.y {
        level.y = position.y + size.y
      }
    }
  }
}

///|
fn mrtree_compaction_compute_node_constraints(
  graph : MrtreeGraph,
  node_node_spacing : Double,
) -> Unit {
  let direction_value = mrtree_graph_direction(graph)
  let right_direction = if mrtree_tree_util_direction_is_horizontal(
      direction_value,
    ) {
    "DOWN"
  } else {
    "RIGHT"
  }
  let right_direction_vector = mrtree_tree_util_get_direction_vector(
    right_direction,
  )
  let direction_vector = mrtree_tree_util_get_direction_vector(direction_value)

  let actual_nodes = []
  for node in mrtree_graph_nodes(graph) {
    if !mrtree_node_label(node).contains("SUPER_ROOT") {
      actual_nodes.push(node)
    }
    mrtree_node_set_compact_constraints(node, [])
  }

  let points : Array[Triple[MrtreeNode, KVector, Bool]] = []
  for node in actual_nodes {
    let start = new_kvector_copy(mrtree_node_position(node))
    ignore(start.sub_xy(node_node_spacing, node_node_spacing))
    points.push(triple_of(node, start, true))
  }
  for node in actual_nodes {
    let end_point = new_kvector_copy(mrtree_node_position(node))
    let size = mrtree_node_size(node)
    ignore(
      end_point.add_xy(size.x + node_node_spacing, size.y + node_node_spacing),
    )
    points.push(triple_of(node, end_point, false))
  }

  let points_len = points.length()
  for i in 1..<points_len {
    let current = points[i]
    let current_projection = current
      .get_second()
      .dot_product(right_direction_vector)
    let mut j = i
    while j > 0 &&
          current_projection <
          points[j - 1].get_second().dot_product(right_direction_vector) {
      points[j] = points[j - 1]
      j -= 1
    }
    points[j] = current
  }

  let active_nodes = []
  let candidates : Map[MrtreeNode, MrtreeNode] = {}

  for point in points {
    let current_node = point.get_first()
    if point.get_third() {
      let index = mrtree_compaction_insert_sorted(
        active_nodes, current_node, direction_vector,
      )
      if index > 0 {
        candidates[current_node] = active_nodes[index - 1]
      }
      if index + 1 < active_nodes.length() {
        candidates[active_nodes[index + 1]] = current_node
      }
    } else {
      let index = mrtree_compaction_sorted_remove(active_nodes, current_node)
      if index > 0 {
        let left_node = active_nodes[index - 1]
        match candidates.get(current_node) {
          Some(candidate_node) =>
            if left_node == candidate_node {
              mrtree_node_add_compact_constraint(current_node, left_node)
            }
          None => ()
        }
      }
      if index < active_nodes.length() {
        let right_node = active_nodes[index]
        match candidates.get(right_node) {
          Some(candidate_node) =>
            if candidate_node == current_node {
              mrtree_node_add_compact_constraint(right_node, current_node)
            }
          None => ()
        }
      }
    }
  }
}

///|
fn mrtree_compaction_sort_nodes(
  nodes : Array[MrtreeNode],
  direction_value : String,
) -> Unit {
  let direction_vector = mrtree_tree_util_get_direction_vector(direction_value)
  let length = nodes.length()
  for i in 1..<length {
    let current = nodes[i]
    let current_projection = direction_vector.dot_product(
      new_kvector_xy(
        mrtree_node_position(current).x,
        mrtree_node_position(current).y,
      ),
    )
    let mut j = i
    while j > 0 &&
          current_projection <
          direction_vector.dot_product(
            new_kvector_xy(
              mrtree_node_position(nodes[j - 1]).x,
              mrtree_node_position(nodes[j - 1]).y,
            ),
          ) {
      nodes[j] = nodes[j - 1]
      j -= 1
    }
    nodes[j] = current
  }
}

///|
fn mrtree_compaction_processor_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Process compaction", 1.0))
    None => ()
  }

  if !mrtree_graph_compaction(graph) {
    return
  }

  let direction_value = mrtree_graph_direction(graph)
  let node_node_spacing = mrtree_graph_spacing_node_node(graph)

  mrtree_compaction_set_up_levels(graph, direction_value)
  mrtree_compaction_compute_node_constraints(
    graph,
    node_node_spacing / 2.0 / 2.0,
  )

  let nodes = mrtree_graph_nodes(graph).copy()
  mrtree_compaction_sort_nodes(nodes, direction_value)

  for node in nodes {
    if !mrtree_node_root(node) {
      let dependent_node = mrtree_compaction_get_lowest_dependent_node(
        node, direction_value,
      )
      let parent_node = mrtree_tree_util_get_lowest_parent(node, graph)
      let mut new_pos = 0.0
      let mut new_pos_size = 0.0

      match dependent_node {
        Some(dependent) => {
          let dependent_position = mrtree_node_position(dependent)
          match parent_node {
            Some(parent) => {
              let parent_position = mrtree_node_position(parent)
              let parent_size = mrtree_node_size(parent)
              let node_size = mrtree_node_size(node)
              let dependent_size = mrtree_node_size(dependent)
              if direction_value == "LEFT" {
                new_pos = dependent_position.x - node_node_spacing - node_size.x
                if parent_position.x - node_node_spacing - node_size.x < new_pos {
                  new_pos = parent_position.x - node_node_spacing - node_size.x
                }
                new_pos_size = new_pos + node_size.x
              } else if direction_value == "RIGHT" {
                new_pos = dependent_position.x +
                  dependent_size.x +
                  node_node_spacing
                if parent_position.x + node_node_spacing > new_pos {
                  new_pos = parent_position.x +
                    parent_size.x +
                    node_node_spacing
                }
                new_pos_size = new_pos + node_size.x
              } else if direction_value == "UP" {
                new_pos = dependent_position.y - node_node_spacing - node_size.y
                if parent_position.y - node_node_spacing - node_size.y < new_pos {
                  new_pos = parent_position.y - node_node_spacing - node_size.y
                }
                new_pos_size = new_pos + node_size.y
              } else {
                new_pos = dependent_position.y +
                  dependent_size.y +
                  node_node_spacing
                if parent_position.y + node_node_spacing > new_pos {
                  new_pos = parent_position.y +
                    parent_size.y +
                    node_node_spacing
                }
                new_pos_size = new_pos + node_size.y
              }
            }
            None => ()
          }
        }
        None =>
          match parent_node {
            Some(parent) => {
              let parent_position = mrtree_node_position(parent)
              let parent_size = mrtree_node_size(parent)
              let node_size = mrtree_node_size(node)
              if direction_value == "LEFT" {
                new_pos = parent_position.x - node_node_spacing - node_size.x
                new_pos_size = new_pos + node_size.x
              } else if direction_value == "RIGHT" {
                new_pos = parent_position.x + parent_size.x + node_node_spacing
                new_pos_size = new_pos + node_size.x
              } else if direction_value == "UP" {
                new_pos = parent_position.y - node_node_spacing - node_size.y
                new_pos_size = new_pos + node_size.y
              } else {
                new_pos = parent_position.y + parent_size.y + node_node_spacing
                new_pos_size = new_pos + node_size.y
              }
            }
            None => ()
          }
      }

      if mrtree_graph_edge_routing_mode(graph) is
        MrtreeEdgeRoutingMode::AVOID_OVERLAP {
        let mut level_index : Int? = None
        for i in 0..<mrtree_compaction_levels.val.length() {
          let level = mrtree_compaction_levels.val[i]
          if level.x <= new_pos && level.y >= new_pos_size {
            level_index = Some(i)
            break
          }
        }

        if level_index != None {
          if mrtree_tree_util_direction_is_horizontal(direction_value) {
            mrtree_node_position(node).x = new_pos
          } else {
            mrtree_node_position(node).y = new_pos
          }
        } else if direction_value == "LEFT" || direction_value == "UP" {
          for i in 1..<mrtree_compaction_levels.val.length() {
            if mrtree_compaction_levels.val[i].x <= new_pos {
              level_index = Some(i)
              break
            }
          }
        } else {
          for i in 1..<mrtree_compaction_levels.val.length() {
            if mrtree_compaction_levels.val[i].x >= new_pos {
              level_index = Some(i)
              break
            }
          }
        }

        match level_index {
          Some(index) => {
            let forced_pos = mrtree_compaction_levels.val[index].x
            if mrtree_tree_util_direction_is_horizontal(direction_value) {
              mrtree_node_position(node).x = forced_pos
            } else {
              mrtree_node_position(node).y = forced_pos
            }
            if index > 0 && index != mrtree_node_tree_level(node) {
              mrtree_node_set_compact_level_ascension(node, true)
              mrtree_node_set_tree_level(node, index)
            }
          }
          None => ()
        }
      } else if mrtree_tree_util_direction_is_horizontal(direction_value) {
        mrtree_node_position(node).x = new_pos
      } else {
        mrtree_node_position(node).y = new_pos
      }
    }
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_compaction_processor_layout_processor() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_processor(mrtree_compaction_processor_process)
}
