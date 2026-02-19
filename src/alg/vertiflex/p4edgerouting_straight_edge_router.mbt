///|
fn vertiflex_first_or_create_edge_section(edge : @graph.ElkEdge) -> @graph.ElkEdgeSection {
  let sections = @graph.edge_sections(edge)
  if sections.is_empty() {
    @graph.create_edge_section(edge)
  } else {
    sections[0]
  }
}

///|
fn vertiflex_straight_edge_router_route_edges(node : @graph.ElkNode) -> Unit {
  for edge in @graph.node_outgoing_edges(node) {
    let target = vertiflex_internal_child_of_edge(edge)
    let section = vertiflex_first_or_create_edge_section(edge)
    let start_x = @graph.node_x(node) + @graph.node_width(node) / 2.0
    let start_y = @graph.node_y(node) + @graph.node_height(node)
    let end_x = @graph.node_x(target) + @graph.node_width(target) / 2.0
    let end_y = @graph.node_y(target)
    @graph.edge_section_set_start(section, start_x, start_y)
    @graph.edge_section_set_end(section, end_x, end_y)
    vertiflex_straight_edge_router_route_edges(target)
  }
}

///|
fn vertiflex_straight_edge_router_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("StraightEdgeRouter", 1.0))
  if !@graph.node_children(graph).is_empty() {
    vertiflex_straight_edge_router_route_edges(
      vertiflex_internal_root_node(graph),
    )
  }
  monitor.done()
}

///|
pub fn new_vertiflex_straight_edge_router_layout_phase() -> @core.ILayoutProcessor[
  VertiFlexLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(vertiflex_straight_edge_router_process, _ => None)
}
