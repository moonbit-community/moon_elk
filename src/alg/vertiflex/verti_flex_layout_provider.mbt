///|
pub struct VertiFlexLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler[
    VertiFlexLayoutPhases,
    @graph.ElkNode,
  ]
  mut node_node_spacing : Double
}

///|
priv suberror VertiFlexLayoutProviderException {
  UnsupportedConfiguration(String)
} derive(Debug, ToJson)

///|
fn vertiflex_raise_unsupported_configuration(
  message : String,
) -> Unit raise VertiFlexLayoutProviderException {
  raise VertiFlexLayoutProviderException::UnsupportedConfiguration(message)
}

///|
fn vertiflex_exception_message(
  err : VertiFlexLayoutProviderException,
) -> String {
  match err {
    VertiFlexLayoutProviderException::UnsupportedConfiguration(message) =>
      message
  }
}

///|
pub fn new_vertiflex_layout_provider() -> VertiFlexLayoutProvider {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      vertiflex_layout_phase_descriptor,
    ),
    node_node_spacing: 0.0,
  }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(vertiflex_algorithm_id, (
    layout_graph,
    progress_monitor,
  ) => new_vertiflex_layout_provider().layout(layout_graph, progress_monitor))
}

///|
fn vertiflex_node_micro_layout_execute(graph : @graph.ElkNode) -> Unit {
  ignore(graph)
}

///|
fn vertiflex_parse_padding(value : String) -> @core.ElkPadding {
  let padding_value = @core.new_elk_padding()
  padding_value.parse(value)
  padding_value
}

///|
fn vertiflex_check_vertical_constraint_validity(
  provider : VertiFlexLayoutProvider,
  root : @graph.ElkNode,
  current_min_constraint : Double,
) -> Unit raise VertiFlexLayoutProviderException {
  let root_height = if @graph.node_has_double_property(
      root, vertiflex_vertical_constraint,
    ) {
    @graph.node_get_double_property(root, vertiflex_vertical_constraint)
  } else {
    current_min_constraint
  }
  let new_min_constraint = root_height +
    @graph.node_height(root) +
    @cmp.maximum(
      vertiflex_internal_node_margins(root).bottom,
      provider.node_node_spacing,
    )
  for edge in @graph.node_outgoing_edges(root) {
    let child = vertiflex_internal_child_of_edge(edge)
    if @graph.node_has_double_property(child, vertiflex_vertical_constraint) &&
      new_min_constraint >
      @graph.node_get_double_property(child, vertiflex_vertical_constraint) +
      vertiflex_internal_node_margins(child).top {
      vertiflex_raise_unsupported_configuration(
        "Invalid vertical constraints. Node \{@graph.node_identifier(child)} has a vertical constraint that is too low for its ancestors.",
      )
    }
  }
  for edge in @graph.node_outgoing_edges(root) {
    vertiflex_check_vertical_constraint_validity(
      provider,
      vertiflex_internal_child_of_edge(edge),
      new_min_constraint,
    )
  }
}

///|
fn vertiflex_set_graph_size(graph : @graph.ElkNode) -> Unit {
  let padding_value = vertiflex_parse_padding(
    @graph.node_get_string_property(graph, vertiflex_padding),
  )
  let mut max_x = 0.0
  let mut max_y = 0.0
  for node in @graph.node_children(graph) {
    let margin = vertiflex_internal_node_margins(node)
    if max_x < @graph.node_x(node) + @graph.node_width(node) + margin.right {
      max_x = @graph.node_x(node) + @graph.node_width(node) + margin.right
    }
    if max_y < @graph.node_y(node) + @graph.node_height(node) + margin.bottom {
      max_y = @graph.node_y(node) + @graph.node_height(node) + margin.bottom
    }
  }
  @graph.node_set_dimensions(
    graph,
    max_x + padding_value.right,
    max_y + padding_value.bottom,
  )
}

///|
pub fn VertiFlexLayoutProvider::assemble_algorithm(
  self : VertiFlexLayoutProvider,
  graph : @graph.ElkNode,
) -> Array[@core.ILayoutProcessor[VertiFlexLayoutPhases, @graph.ElkNode]] {
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
      @graph.node_get_string_property(graph, vertiflex_layout_strategy),
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
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  try
    vertiflex_layout_provider_layout_impl(self, graph, progress_monitor)
  catch {
    err => {
      @core.layout_runtime_report_unsupported_configuration(
        vertiflex_exception_message(err),
      )
      if progress_monitor.is_running() {
        progress_monitor.done()
      }
    }
  } noraise {
    _ => ()
  }
}

///|
fn vertiflex_layout_provider_layout_impl(
  provider : VertiFlexLayoutProvider,
  graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit raise VertiFlexLayoutProviderException {
  vertiflex_internal_reset()
  let algorithm = provider.assemble_algorithm(graph)
  ignore(
    progress_monitor.begin(
      "@common.Tree layout",
      algorithm.length().to_double(),
    ),
  )
  provider.node_node_spacing = @graph.node_get_double_property(
    graph, vertiflex_spacing_node_node,
  )

  if !@graph.node_get_bool_property(graph, vertiflex_omit_node_micro_layout) {
    vertiflex_node_micro_layout_execute(graph)
  }

  match vertiflex_find_root(graph) {
    Some(root) => vertiflex_internal_set_root_node(graph, root)
    None =>
      vertiflex_raise_unsupported_configuration(
        "The given graph is not a tree!",
      )
  }

  for child in @graph.node_children(graph) {
    if @graph.node_incoming_edges(child).length() > 1 {
      vertiflex_raise_unsupported_configuration(
        "The given graph is not an acyclic tree!",
      )
    }
    @graph.node_set_location(child, 0.0, 0.0)
  }

  vertiflex_check_vertical_constraint_validity(
    provider,
    vertiflex_internal_root_node(graph),
    0.0,
  )

  let mut count = 0
  for node in @graph.node_children(graph) {
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
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
