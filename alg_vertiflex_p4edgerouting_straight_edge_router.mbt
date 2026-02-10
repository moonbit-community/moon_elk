///|
fn vertiflex_first_or_create_edge_section(edge : ElkEdge) -> ElkEdgeSection {
  let sections = edge_sections(edge)
  if sections.is_empty() {
    create_edge_section(edge)
  } else {
    sections[0]
  }
}

///|
fn vertiflex_straight_edge_router_route_edges(node : ElkNode) -> Unit {
  for edge in node_outgoing_edges(node) {
    let target = vertiflex_internal_child_of_edge(edge)
    let section = vertiflex_first_or_create_edge_section(edge)
    let start_x = node_x(node) + node_width(node) / 2.0
    let start_y = node_y(node) + node_height(node)
    let end_x = node_x(target) + node_width(target) / 2.0
    let end_y = node_y(target)
    edge_section_set_start(section, start_x, start_y)
    edge_section_set_end(section, end_x, end_y)
    vertiflex_straight_edge_router_route_edges(target)
  }
}

///|
fn vertiflex_straight_edge_router_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("StraightEdgeRouter", 1.0))
  if !node_children(graph).is_empty() {
    vertiflex_straight_edge_router_route_edges(
      vertiflex_internal_root_node(graph),
    )
  }
  monitor.done()
}

///|
pub fn new_vertiflex_straight_edge_router_layout_phase() -> ILayoutProcessor[
  VertiFlexLayoutPhases,
  ElkNode,
] {
  new_layout_phase(vertiflex_straight_edge_router_process, _ => None)
}
