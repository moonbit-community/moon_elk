///|
fn vertiflex_bend_edge_router_route_edges(node : @graph.ElkNode) -> Unit {
  for edge in @graph.node_outgoing_edges(node) {
    let target = vertiflex_internal_child_of_edge(edge)
    let section = vertiflex_first_or_create_edge_section(edge)
    let start_x = @graph.node_x(node) + @graph.node_width(node) / 2.0
    let start_y = @graph.node_y(node) + @graph.node_height(node)
    let end_x = @graph.node_x(target) + @graph.node_width(target) / 2.0
    let end_y = @graph.node_y(target)
    @graph.edge_section_set_start(section, start_x, start_y)

    let spacing = @graph.node_get_double_property(
      match @graph.node_parent(target) {
        Some(parent) => parent
        None => abort("VertiFlex target node must have a parent graph.")
      },
      vertiflex_spacing_node_node,
    )
    let bend_height = vertiflex_internal_edge_bend_height(target)
    let epsilon = 0.0001
    if (bend_height - (end_y - spacing / 2.0)).abs() > epsilon {
      let sections = @graph.edge_sections(edge)
      let second = if sections.length() >= 2 {
        sections[1]
      } else {
        @graph.create_edge_section(edge)
      }
      @graph.edge_section_set_end(section, end_x, bend_height)
      @graph.edge_section_set_start(second, end_x, bend_height)
      @graph.edge_section_set_end(second, end_x, end_y)
      if @graph.edge_section_outgoing_sections(section).is_empty() {
        @graph.edge_section_add_outgoing_section(section, second)
      }
      if @graph.edge_section_incoming_sections(second).is_empty() {
        @graph.edge_section_add_incoming_section(second, section)
      }
    } else {
      @graph.edge_section_set_end(section, end_x, end_y)
    }
    vertiflex_bend_edge_router_route_edges(target)
  }
}

///|
fn vertiflex_bend_edge_router_process(
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let monitor = match progress_monitor {
    Some(existing) => existing
    None => @core.new_null_elk_progress_monitor()
  }
  ignore(monitor.begin("BendEdgeRouter", 1.0))
  if !@graph.node_children(graph).is_empty() {
    vertiflex_bend_edge_router_route_edges(vertiflex_internal_root_node(graph))
  }
  monitor.done()
}

///|
pub fn new_vertiflex_bend_edge_router_layout_phase() -> @core.ILayoutProcessor[
  VertiFlexLayoutPhases,
  @graph.ElkNode,
] {
  @core.new_layout_phase(vertiflex_bend_edge_router_process, _ => None)
}
