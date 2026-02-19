///|
fn vertiflex_absolute_x_placer_find_minimal_x(tree : ElkNode) -> Double {
  let children_edges = node_outgoing_edges(tree)
  if children_edges.is_empty() {
    node_x(tree)
  } else {
    let mut min_subtree_x = 0.0
    for edge in children_edges {
      let test_x = vertiflex_absolute_x_placer_find_minimal_x(
        vertiflex_internal_child_of_edge(edge),
      )
      if test_x < min_subtree_x {
        min_subtree_x = test_x
      }
    }
    min_subtree_x + node_x(tree)
  }
}

///|
fn vertiflex_absolute_x_placer_absolute_tree_coords(tree : ElkNode) -> Unit {
  for edge in node_outgoing_edges(tree) {
    let child = vertiflex_internal_child_of_edge(edge)
    node_set_location(child, node_x(child) + node_x(tree), node_y(child))
    vertiflex_absolute_x_placer_absolute_tree_coords(child)
  }
}

///|
fn vertiflex_absolute_x_placer_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("AbsolutPlacer", 1.0))
  if !node_children(graph).is_empty() {
    let parent = vertiflex_internal_root_node(graph)
    node_set_location(
      parent,
      node_x(parent) - vertiflex_absolute_x_placer_find_minimal_x(parent),
      node_y(parent),
    )
    vertiflex_absolute_x_placer_absolute_tree_coords(parent)
  }
  monitor.done()
}

///|
pub fn new_vertiflex_absolute_x_placer_layout_phase() -> ILayoutProcessor[
  VertiFlexLayoutPhases,
  ElkNode,
] {
  new_layout_phase(vertiflex_absolute_x_placer_process, _ => None)
}
