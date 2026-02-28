///|
fn vertiflex_node_y_placer_set_y_levels(
  node : @graph.ElkNode,
  min_height : Double,
  layer_distance : Double,
  node_node_spacing : Double,
) -> Unit {
  let constrained_min_height = if @graph.node_has_double_property(
      node, vertiflex_vertical_constraint,
    ) {
    @graph.node_get_double_property(node, vertiflex_vertical_constraint)
  } else {
    min_height
  }
  @graph.node_set_location(node, @graph.node_x(node), constrained_min_height)
  let margins = vertiflex_internal_node_margins(node)
  let new_min_height = constrained_min_height +
    layer_distance +
    @graph.node_height(node) +
    @cmp.maximum(margins.bottom, node_node_spacing)
  for edge in @graph.node_outgoing_edges(node) {
    let child = vertiflex_internal_child_of_edge(edge)
    vertiflex_node_y_placer_set_y_levels(
      child, new_min_height, layer_distance, node_node_spacing,
    )
  }
}

///|
fn vertiflex_node_y_placer_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("YPlacer", 1.0))

  let layer_distance = @graph.node_get_double_property(
    graph, vertiflex_layer_distance,
  )
  let node_node_spacing = @graph.node_get_double_property(
    graph, vertiflex_spacing_node_node,
  )
  if !@graph.node_children(graph).is_empty() {
    let parent = vertiflex_internal_root_node(graph)
    vertiflex_node_y_placer_set_y_levels(
      parent, 0.0, layer_distance, node_node_spacing,
    )
  }
  monitor.done()
}

///|
pub fn new_vertiflex_node_y_placer_layout_phase() -> @core.ILayoutProcessor[
  VertiFlexLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(vertiflex_node_y_placer_process, _ => None)
}
