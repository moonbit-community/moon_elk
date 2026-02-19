///|
fn vertiflex_absolute_x_placer_find_minimal_x(tree : @graph.ElkNode) -> Double {
  let children_edges = @graph.node_outgoing_edges(tree)
  if children_edges.is_empty() {
    @graph.node_x(tree)
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
    min_subtree_x + @graph.node_x(tree)
  }
}

///|
fn vertiflex_absolute_x_placer_absolute_tree_coords(tree : @graph.ElkNode) -> Unit {
  for edge in @graph.node_outgoing_edges(tree) {
    let child = vertiflex_internal_child_of_edge(edge)
    @graph.node_set_location(child, @graph.node_x(child) + @graph.node_x(tree), @graph.node_y(child))
    vertiflex_absolute_x_placer_absolute_tree_coords(child)
  }
}

///|
fn vertiflex_absolute_x_placer_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("AbsolutPlacer", 1.0))
  if !@graph.node_children(graph).is_empty() {
    let parent = vertiflex_internal_root_node(graph)
    @graph.node_set_location(
      parent,
      @graph.node_x(parent) - vertiflex_absolute_x_placer_find_minimal_x(parent),
      @graph.node_y(parent),
    )
    vertiflex_absolute_x_placer_absolute_tree_coords(parent)
  }
  monitor.done()
}

///|
pub fn new_vertiflex_absolute_x_placer_layout_phase() -> @core.ILayoutProcessor[
  VertiFlexLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(vertiflex_absolute_x_placer_process, _ => None)
}
