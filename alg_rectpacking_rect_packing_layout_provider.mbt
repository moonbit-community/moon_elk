///|
pub struct RectPackingLayoutProvider {
  algorithm_assembler : AlgorithmAssembler[RectPackingLayoutPhases, ElkNode]
}

///|
pub fn new_rectpacking_layout_provider() -> RectPackingLayoutProvider {
  {
    algorithm_assembler: algorithm_assembler_create(
      rectpacking_phase_descriptor,
    ),
  }
}

///|
fn rectpacking_parse_padding(value : String) -> Spacing {
  let padding_value = new_elk_padding()
  padding_value.parse(value)
  padding_value
}

///|
fn rectpacking_apply_padding(
  rectangles : Array[ElkNode],
  padding : Spacing,
) -> Unit {
  for rect in rectangles {
    node_set_location(
      rect,
      node_x(rect) + padding.get_left(),
      node_y(rect) + padding.get_top(),
    )
  }
}

///|
fn rectpacking_get_phase_independent_layout_processor_configuration(
  layout_graph : ElkNode,
) -> LayoutProcessorConfiguration[RectPackingLayoutPhases, ElkNode] {
  let configuration = layout_processor_configuration_create(
    rectpacking_phase_descriptor,
  )

  ignore(
    configuration.add_before(
      RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
      rectpacking_intermediate_processor_factory(
        RectpackingIntermediateProcessorStrategy::MIN_SIZE_PRE_PROCESSOR,
      ),
    ),
  )

  ignore(
    configuration.add_before(
      RectPackingLayoutPhases::P2_PACKING,
      rectpacking_intermediate_processor_factory(
        RectpackingIntermediateProcessorStrategy::MIN_SIZE_POST_PROCESSOR,
      ),
    ),
  )

  if node_get_bool_property(layout_graph, rectpacking_order_by_size) {
    ignore(
      configuration.add_before(
        RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
        rectpacking_intermediate_processor_factory(
          RectpackingIntermediateProcessorStrategy::NODE_SIZE_REORDERER,
        ),
      ),
    )
  }

  if node_get_bool_property(layout_graph, rectpacking_interactive) {
    ignore(
      configuration.add_before(
        RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
        rectpacking_intermediate_processor_factory(
          RectpackingIntermediateProcessorStrategy::INTERACTIVE_NODE_REORDERER,
        ),
      ),
    )
  }

  configuration
}

///|
pub fn RectPackingLayoutProvider::assemble_algorithm(
  self : RectPackingLayoutProvider,
  layout_graph : ElkNode,
) -> Array[ILayoutProcessor[RectPackingLayoutPhases, ElkNode]] {
  ignore(self.algorithm_assembler.reset())

  ignore(
    self.algorithm_assembler.set_phase(
      RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
      rectpacking_width_approximation_strategy_phase_factory(
        rectpacking_width_approximation_strategy_from_string(
          node_get_string_property(
            layout_graph, rectpacking_width_approximation_strategy,
          ),
        ),
      ),
    ),
  )

  ignore(
    self.algorithm_assembler.set_phase(
      RectPackingLayoutPhases::P2_PACKING,
      rectpacking_packing_strategy_phase_factory(
        rectpacking_packing_strategy_from_string(
          node_get_string_property(layout_graph, rectpacking_packing_strategy),
        ),
      ),
    ),
  )

  ignore(
    self.algorithm_assembler.set_phase(
      RectPackingLayoutPhases::P3_WHITESPACE_ELIMINATION,
      rectpacking_whitespace_elimination_strategy_phase_factory(
        rectpacking_whitespace_elimination_strategy_from_string(
          node_get_string_property(
            layout_graph, rectpacking_white_space_elimination_strategy,
          ),
        ),
      ),
    ),
  )

  ignore(
    self.algorithm_assembler.add_processor_configuration(
      rectpacking_get_phase_independent_layout_processor_configuration(
        layout_graph,
      ),
    ),
  )

  self.algorithm_assembler.build(layout_graph)
}

///|
pub fn RectPackingLayoutProvider::layout(
  self : RectPackingLayoutProvider,
  layout_graph : ElkNode,
  progress_monitor : IElkProgressMonitor,
) -> Unit {
  ignore(progress_monitor.begin("Rectangle Packing", 1.0))

  let padding = rectpacking_parse_padding(
    node_get_string_property(layout_graph, rectpacking_padding),
  )
  let fixed_graph_size = node_get_bool_property(
    layout_graph, rectpacking_node_size_fixed_graph_size,
  )
  let node_node_spacing = node_get_double_property(
    layout_graph, rectpacking_spacing_node_node,
  )
  let try_box = node_get_bool_property(layout_graph, rectpacking_trybox)
  let rectangles = node_children(layout_graph)
  ignore(node_node_spacing)

  let mut stackable = false
  if try_box && rectangles.length() >= 3 {
    let mut region2 = rectangles[0]
    let mut region3 = rectangles[1]
    let mut counter = 0
    while counter + 2 < rectangles.length() {
      let region1 = region2
      region2 = region3
      region3 = rectangles[counter + 2]
      if node_height(region1) >=
        node_height(region2) + node_height(region3) + node_node_spacing ||
        node_height(region3) >=
        node_height(region1) + node_height(region2) + node_node_spacing {
        stackable = true
        break
      } else {
        counter += 1
      }
    }
  } else {
    stackable = true
  }
  ignore(stackable)

  let algorithm = self.assemble_algorithm(layout_graph)

  for processor in algorithm {
    if progress_monitor.is_canceled() {
      return
    }
    processor.process(layout_graph, progress_monitor.sub_task(1.0))
  }

  let mut real_width = 0.0
  let mut real_height = 0.0
  for rect in rectangles {
    real_width = @math.maximum(real_width, node_x(rect) + node_width(rect))
    real_height = @math.maximum(real_height, node_y(rect) + node_height(rect))
  }

  translate(
    layout_graph,
    new_kvector_xy(
      node_get_double_property(layout_graph, rectpacking_internal_drawing_width),
      node_get_double_property(
        layout_graph, rectpacking_internal_drawing_height,
      ),
    ),
    new_kvector_xy(real_width, real_height),
  )

  rectpacking_apply_padding(rectangles, padding)

  if !fixed_graph_size {
    node_set_dimensions(
      layout_graph,
      node_get_double_property(layout_graph, rectpacking_internal_drawing_width) +
      padding.get_horizontal(),
      node_get_double_property(
        layout_graph, rectpacking_internal_drawing_height,
      ) +
      padding.get_vertical(),
    )
  }

  progress_monitor.done()
}

///|
pub fn rectpacking_layout_provider_as_layout_provider(
  provider : RectPackingLayoutProvider,
) -> AbstractLayoutProvider {
  new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
