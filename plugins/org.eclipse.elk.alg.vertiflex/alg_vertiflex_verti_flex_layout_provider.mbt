///|
pub struct VertiFlexLayoutProvider {
  algorithm_assembler : AlgorithmAssembler[VertiFlexLayoutPhases, ElkNode]
  mut node_node_spacing : Double
}

///|
pub fn new_vertiflex_layout_provider() -> VertiFlexLayoutProvider {
  {
    algorithm_assembler: algorithm_assembler_create(
      vertiflex_layout_phase_descriptor,
    ),
    node_node_spacing: 0.0,
  }
}

///|
fn vertiflex_node_micro_layout_execute(graph : ElkNode) -> Unit {
  ignore(graph)
}

///|
fn vertiflex_parse_padding(value : String) -> ElkPadding {
  let padding_value = new_elk_padding()
  padding_value.parse(value)
  padding_value
}

///|
fn vertiflex_check_vertical_constraint_validity(
  provider : VertiFlexLayoutProvider,
  root : ElkNode,
  current_min_constraint : Double,
) -> Unit {
  let root_height = if node_has_double_property(
      root, vertiflex_vertical_constraint,
    ) {
    node_get_double_property(root, vertiflex_vertical_constraint)
  } else {
    current_min_constraint
  }
  let new_min_constraint = root_height +
    node_height(root) +
    @math.maximum(
      vertiflex_internal_node_margins(root).bottom,
      provider.node_node_spacing,
    )
  for edge in node_outgoing_edges(root) {
    let child = vertiflex_internal_child_of_edge(edge)
    if node_has_double_property(child, vertiflex_vertical_constraint) &&
      new_min_constraint >
      node_get_double_property(child, vertiflex_vertical_constraint) +
      vertiflex_internal_node_margins(child).top {
      abort(
        "Invalid vertical constraints. Node \{node_identifier(child)} has a vertical constraint that is too low for its ancestors.",
      )
    }
  }
  for edge in node_outgoing_edges(root) {
    vertiflex_check_vertical_constraint_validity(
      provider,
      vertiflex_internal_child_of_edge(edge),
      new_min_constraint,
    )
  }
}

///|
fn vertiflex_set_graph_size(graph : ElkNode) -> Unit {
  let padding_value = vertiflex_parse_padding(
    node_get_string_property(graph, vertiflex_padding),
  )
  let mut max_x = 0.0
  let mut max_y = 0.0
  for node in node_children(graph) {
    let margin = vertiflex_internal_node_margins(node)
    if max_x < node_x(node) + node_width(node) + margin.right {
      max_x = node_x(node) + node_width(node) + margin.right
    }
    if max_y < node_y(node) + node_height(node) + margin.bottom {
      max_y = node_y(node) + node_height(node) + margin.bottom
    }
  }
  node_set_dimensions(
    graph,
    max_x + padding_value.right,
    max_y + padding_value.bottom,
  )
}

///|
pub fn VertiFlexLayoutProvider::assemble_algorithm(
  self : VertiFlexLayoutProvider,
  graph : ElkNode,
) -> Array[ILayoutProcessor[VertiFlexLayoutPhases, ElkNode]] {
  ignore(self.algorithm_assembler.reset())
  ignore(
    self.algorithm_assembler.set_phase(
      VertiFlexLayoutPhases::P1_NODE_Y_PLACEMENT,
      vertiflex_node_y_placer_phase_factory(
        NodeYPlacerStrategy::SIMPLE_Y_PLACING,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      VertiFlexLayoutPhases::P2_NODE_RELATIVE_PLACEMENT,
      vertiflex_relative_x_placer_phase_factory(
        RelativeXPlacerStrategy::SIMPLE_X_PLACING,
      ),
    ),
  )
  ignore(
    self.algorithm_assembler.set_phase(
      VertiFlexLayoutPhases::P3_NODE_ABSOLUTE_PLACEMENT,
      vertiflex_absolute_x_placer_phase_factory(
        AbsoluteXPlacerStrategy::ABSOLUTE_XPLACING,
      ),
    ),
  )
  let router_strategy = match
    vertiflex_edge_routing_strategy_from_string(
      node_get_string_property(graph, vertiflex_layout_strategy),
    ) {
    BEND => EdgerouterStrategy::BEND_ROUTING
    STRAIGHT => EdgerouterStrategy::DIRECT_ROUTING
  }
  ignore(
    self.algorithm_assembler.set_phase(
      VertiFlexLayoutPhases::P4_EDGE_ROUTING,
      vertiflex_edgerouter_phase_factory(router_strategy),
    ),
  )
  self.algorithm_assembler.build(graph)
}

///|
pub fn VertiFlexLayoutProvider::layout(
  self : VertiFlexLayoutProvider,
  graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  vertiflex_internal_reset()
  let algorithm = self.assemble_algorithm(graph)
  ignore(progress_monitor.begin("Tree layout", algorithm.length().to_double()))
  self.node_node_spacing = node_get_double_property(
    graph, vertiflex_spacing_node_node,
  )

  if !node_get_bool_property(graph, vertiflex_omit_node_micro_layout) {
    vertiflex_node_micro_layout_execute(graph)
  }

  match vertiflex_find_root(graph) {
    Some(root) => vertiflex_internal_set_root_node(graph, root)
    None => abort("The given graph is not a tree!")
  }

  for child in node_children(graph) {
    if node_incoming_edges(child).length() > 1 {
      abort("The given graph is not an acyclic tree!")
    }
    node_set_location(child, 0.0, 0.0)
  }

  vertiflex_check_vertical_constraint_validity(
    self,
    vertiflex_internal_root_node(graph),
    0.0,
  )

  let mut count = 0
  for node in node_children(graph) {
    vertiflex_internal_set_node_model_order(node, count)
    count += 1
  }

  for processor in algorithm {
    processor.process(graph, progress_monitor.sub_task(1.0))
  }
  vertiflex_set_graph_size(graph)
  progress_monitor.done()
}

///|
pub fn vertiflex_layout_provider_as_layout_provider(
  provider : VertiFlexLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
