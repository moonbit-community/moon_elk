///|
fn mrtree_node_placer_layout_processor_configuration(
  graph : MrtreeGraph,
) -> LayoutProcessorConfiguration[MrtreeTreeLayoutPhases, MrtreeGraph]? {
  ignore(graph)
  Some(
    layout_processor_configuration_create(mrtree_tree_layout_phase_descriptor)
    .before(MrtreeTreeLayoutPhases::P2NodeOrdering)
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::RootProc,
      ),
    )
    .before(MrtreeTreeLayoutPhases::P3NodePlacement)
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::LevelHeight,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::NeighborsProc,
      ),
    )
    .before(MrtreeTreeLayoutPhases::P4EdgeRouting)
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::DirectionProc,
      ),
    )
    .add(
      mrtree_intermediate_processor_factory(
        MrtreeIntermediateProcessorStrategy::NodePositionProc,
      ),
    ),
  )
}

///|
fn mrtree_node_placer_mean_node_width(
  left_node : MrtreeNode?,
  right_node : MrtreeNode?,
  direction_value : String,
) -> Double {
  let mut node_width = 0.0
  match left_node {
    Some(node) =>
      if mrtree_tree_util_direction_is_vertical(direction_value) {
        node_width += mrtree_node_size(node).x / 2.0
      } else {
        node_width += mrtree_node_size(node).y / 2.0
      }
    None => ()
  }
  match right_node {
    Some(node) =>
      if mrtree_tree_util_direction_is_vertical(direction_value) {
        node_width += mrtree_node_size(node).x / 2.0
      } else {
        node_width += mrtree_node_size(node).y / 2.0
      }
    None => ()
  }
  node_width
}

///|
fn mrtree_node_placer_apportion(
  node : MrtreeNode,
  level : Int,
  spacing : Double,
  direction_value : String,
) -> Unit {
  ignore(level)
  let node_children = mrtree_node_children_copy(node)
  let mut leftmost = if node_children.is_empty() {
    None
  } else {
    Some(node_children[0])
  }
  let mut neighbor = match leftmost {
    Some(leftmost_node) => mrtree_node_left_neighbor(leftmost_node)
    None => None
  }
  let mut compare_depth = 1

  while leftmost != None && neighbor != None {
    let mut left_mod_sum = 0.0
    let mut right_mod_sum = 0.0
    let mut ancestor_leftmost = leftmost
    let mut ancestor_neighbor = neighbor
    for _ in 0..<compare_depth {
      ancestor_leftmost = match ancestor_leftmost {
        Some(current_node) => mrtree_node_parent(current_node)
        None => None
      }
      ancestor_neighbor = match ancestor_neighbor {
        Some(current_node) => mrtree_node_parent(current_node)
        None => None
      }
      right_mod_sum += match ancestor_leftmost {
        Some(current_node) => mrtree_node_modifier(current_node)
        None => 0.0
      }
      left_mod_sum += match ancestor_neighbor {
        Some(current_node) => mrtree_node_modifier(current_node)
        None => 0.0
      }
    }

    let prelim_neighbor = match neighbor {
      Some(neighbor_node) => mrtree_node_prelim(neighbor_node)
      None => 0.0
    }
    let prelim_leftmost = match leftmost {
      Some(leftmost_node) => mrtree_node_prelim(leftmost_node)
      None => 0.0
    }
    let mean = mrtree_node_placer_mean_node_width(
      leftmost, neighbor, direction_value,
    )
    let mut move_distance = prelim_neighbor +
      left_mod_sum +
      spacing +
      mean -
      prelim_leftmost -
      right_mod_sum

    if 0.0 < move_distance {
      let mut left_sibling : MrtreeNode? = Some(node)
      let mut left_siblings = 0
      while left_sibling != None && left_sibling != ancestor_neighbor {
        left_siblings += 1
        left_sibling = match left_sibling {
          Some(current_node) => mrtree_node_left_sibling(current_node)
          None => None
        }
      }
      if left_sibling != None {
        let portion = move_distance / left_siblings.to_double()
        left_sibling = Some(node)
        while left_sibling != ancestor_neighbor {
          match left_sibling {
            Some(current_node) => {
              mrtree_node_set_prelim(
                current_node,
                mrtree_node_prelim(current_node) + move_distance,
              )
              mrtree_node_set_modifier(
                current_node,
                mrtree_node_modifier(current_node) + move_distance,
              )
              move_distance -= portion
              left_sibling = mrtree_node_left_sibling(current_node)
            }
            None => ()
          }
        }
      } else {
        return
      }
    }

    compare_depth += 1
    leftmost = match leftmost {
      Some(leftmost_node) =>
        if mrtree_node_is_leaf(leftmost_node) {
          mrtree_tree_util_get_left_most(
            mrtree_node_children_copy(node),
            depth=compare_depth,
          )
        } else {
          let children = mrtree_node_children_copy(leftmost_node)
          if children.is_empty() {
            None
          } else {
            Some(children[0])
          }
        }
      None => None
    }
    neighbor = match leftmost {
      Some(leftmost_node) => mrtree_node_left_neighbor(leftmost_node)
      None => None
    }
  }
}

///|
fn mrtree_node_placer_first_walk(
  current_node : MrtreeNode,
  level : Int,
  spacing : Double,
  direction_value : String,
) -> Unit {
  mrtree_node_set_modifier(current_node, 0.0)
  let left_sibling = mrtree_node_left_sibling(current_node)

  if mrtree_node_is_leaf(current_node) {
    match left_sibling {
      Some(left_node) => {
        let prelim = mrtree_node_prelim(left_node) +
          spacing +
          mrtree_node_placer_mean_node_width(
            Some(left_node),
            Some(current_node),
            direction_value,
          )
        mrtree_node_set_prelim(current_node, prelim)
      }
      None => mrtree_node_set_prelim(current_node, 0.0)
    }
  } else {
    let children = mrtree_node_children_copy(current_node)
    for child in children {
      mrtree_node_placer_first_walk(child, level + 1, spacing, direction_value)
    }

    let node_children = mrtree_node_children_copy(current_node)
    let left_most = node_children[0]
    let right_most = node_children[node_children.length() - 1]
    let midpoint = (
        mrtree_node_prelim(right_most) + mrtree_node_prelim(left_most)
      ) /
      2.0

    match left_sibling {
      Some(left_node) => {
        let prelim = mrtree_node_prelim(left_node) +
          spacing +
          mrtree_node_placer_mean_node_width(
            Some(left_node),
            Some(current_node),
            direction_value,
          )
        mrtree_node_set_prelim(current_node, prelim)
        mrtree_node_set_modifier(current_node, prelim - midpoint)
        mrtree_node_placer_apportion(
          current_node, level, spacing, direction_value,
        )
      }
      None => mrtree_node_set_prelim(current_node, midpoint)
    }
  }
}

///|
fn mrtree_node_placer_second_walk(
  node : MrtreeNode?,
  ycoor : Double,
  modsum : Double,
  spacing : Double,
) -> Unit {
  match node {
    Some(current_node) => {
      let xtemp = mrtree_node_prelim(current_node) + modsum
      let ytemp = ycoor + mrtree_node_level_height(current_node) / 2.0
      mrtree_node_set_xcoor(current_node, xtemp.round().to_int())
      mrtree_node_set_ycoor(current_node, ytemp.round().to_int())

      if !mrtree_node_is_leaf(current_node) {
        let children = mrtree_node_children_copy(current_node)
        if !children.is_empty() {
          mrtree_node_placer_second_walk(
            Some(children[0]),
            ycoor + mrtree_node_level_height(current_node) + spacing,
            modsum + mrtree_node_modifier(current_node),
            spacing,
          )
        }
      }
      if mrtree_node_right_sibling(current_node) != None {
        mrtree_node_placer_second_walk(
          mrtree_node_right_sibling(current_node),
          ycoor,
          modsum,
          spacing,
        )
      }
    }
    None => ()
  }
}

///|
fn mrtree_node_placer_process(
  graph : MrtreeGraph,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  match progress_monitor {
    Some(monitor) => ignore(monitor.begin("Processor order nodes", 2.0))
    None => ()
  }

  let spacing = mrtree_graph_spacing_node_node(graph)
  let mut direction_value = mrtree_graph_direction(graph)
  if direction_value == "UNDEFINED" {
    direction_value = "DOWN"
    mrtree_graph_set_direction(graph, direction_value)
  }

  let roots = []
  for node in mrtree_graph_nodes(graph) {
    if mrtree_node_root(node) {
      roots.push(node)
    }
  }
  if roots.is_empty() {
    match progress_monitor {
      Some(monitor) => monitor.done()
      None => ()
    }
    return
  }
  let root = roots[0]

  mrtree_node_placer_first_walk(root, 0, spacing, direction_value)
  match progress_monitor {
    Some(monitor) => monitor.worked(1.0)
    None => ()
  }

  mrtree_node_placer_second_walk(
    Some(root),
    0.0 - mrtree_node_level_height(root) / 2.0,
    0.0,
    spacing,
  )
  match progress_monitor {
    Some(monitor) => monitor.worked(1.0)
    None => ()
  }

  match progress_monitor {
    Some(monitor) => monitor.done()
    None => ()
  }
}

///|
pub fn new_mrtree_node_placer_layout_phase() -> ILayoutProcessor[
  MrtreeTreeLayoutPhases,
  MrtreeGraph,
] {
  new_layout_phase(
    mrtree_node_placer_process, mrtree_node_placer_layout_processor_configuration,
  )
}
