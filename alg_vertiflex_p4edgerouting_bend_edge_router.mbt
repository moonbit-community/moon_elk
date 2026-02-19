///|
fn vertiflex_bend_edge_router_route_edges(node : ElkNode) -> Unit {
  for edge in node_outgoing_edges(node) {
    let target = vertiflex_internal_child_of_edge(edge)
    let section = vertiflex_first_or_create_edge_section(edge)
    let start_x = node_x(node) + node_width(node) / 2.0
    let start_y = node_y(node) + node_height(node)
    let end_x = node_x(target) + node_width(target) / 2.0
    let end_y = node_y(target)
    edge_section_set_start(section, start_x, start_y)

    let spacing = node_get_double_property(
      match node_parent(target) {
        Some(parent) => parent
        None => abort("VertiFlex target node must have a parent graph.")
      },
      vertiflex_spacing_node_node,
    )
    let bend_height = vertiflex_internal_edge_bend_height(target)
    let epsilon = 0.0001
    if (bend_height - (end_y - spacing / 2.0)).abs() > epsilon {
      let sections = edge_sections(edge)
      let second = if sections.length() >= 2 {
        sections[1]
      } else {
        create_edge_section(edge)
      }
      edge_section_set_end(section, end_x, bend_height)
      edge_section_set_start(second, end_x, bend_height)
      edge_section_set_end(second, end_x, end_y)
      if edge_section_outgoing_sections(section).is_empty() {
        edge_section_add_outgoing_section(section, second)
      }
      if edge_section_incoming_sections(second).is_empty() {
        edge_section_add_incoming_section(second, section)
      }
    } else {
      edge_section_set_end(section, end_x, end_y)
    }
    vertiflex_bend_edge_router_route_edges(target)
  }
}

///|
fn vertiflex_bend_edge_router_process(
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("BendEdgeRouter", 1.0))
  if !node_children(graph).is_empty() {
    vertiflex_bend_edge_router_route_edges(vertiflex_internal_root_node(graph))
  }
  monitor.done()
}

///|
pub fn new_vertiflex_bend_edge_router_layout_phase() -> ILayoutProcessor[
  VertiFlexLayoutPhases,
  ElkNode,
] {
  new_layout_phase(vertiflex_bend_edge_router_process, _ => None)
}
