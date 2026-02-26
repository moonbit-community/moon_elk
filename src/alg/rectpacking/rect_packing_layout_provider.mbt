///|
pub struct RectPackingLayoutProvider {
  algorithm_assembler : @core.AlgorithmAssembler[
    RectPackingLayoutPhases,
    @graph.ElkNode,
  ]
}

///|
pub fn new_rectpacking_layout_provider() -> RectPackingLayoutProvider {
  {
    algorithm_assembler: @core.algorithm_assembler_create(
      rectpacking_phase_descriptor,
    ),
  }
}

///|
fn init {
  @core.recursive_graph_layout_engine_register_handler(
    rectpacking_algorithm_id,
    (layout_graph, progress_monitor) => {
      new_rectpacking_layout_provider().layout(layout_graph, progress_monitor)
    },
  )
}

///|
fn rectpacking_parse_padding(value : String) -> @core.Spacing {
  let padding_value = @core.new_elk_padding()
  padding_value.parse(value)
  padding_value
}

///|
fn rectpacking_apply_padding(
  rectangles : Array[@graph.ElkNode],
  padding : @core.Spacing,
) -> Unit {
  for rect in rectangles {
    @graph.node_set_location(
      rect,
      @graph.node_x(rect) + padding.get_left(),
      @graph.node_y(rect) + padding.get_top(),
    )
  }
}

///|
fn rectpacking_get_phase_independent_layout_processor_configuration(
  layout_graph : @graph.ElkNode,
) -> @core.LayoutProcessorConfiguration[RectPackingLayoutPhases, @graph.ElkNode] {
  let configuration = @core.layout_processor_configuration_create(
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

  if @graph.node_get_bool_property(layout_graph, rectpacking_order_by_size) {
    ignore(
      configuration.add_before(
        RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
        rectpacking_intermediate_processor_factory(
          RectpackingIntermediateProcessorStrategy::NODE_SIZE_REORDERER,
        ),
      ),
    )
  }

  if @graph.node_get_bool_property(layout_graph, rectpacking_interactive) {
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
  layout_graph : @graph.ElkNode,
) -> Array[@core.ILayoutProcessor[RectPackingLayoutPhases, @graph.ElkNode]] {
  ignore(self.algorithm_assembler.reset())

  ignore(
    self.algorithm_assembler.set_phase(
      RectPackingLayoutPhases::P1_WIDTH_APPROXIMATION,
      rectpacking_width_approximation_strategy_phase_factory(
        rectpacking_width_approximation_strategy_from_string(
          @graph.node_get_string_property(
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
          @graph.node_get_string_property(
            layout_graph, rectpacking_packing_strategy,
          ),
        ),
      ),
    ),
  )

  ignore(
    self.algorithm_assembler.set_phase(
      RectPackingLayoutPhases::P3_WHITESPACE_ELIMINATION,
      rectpacking_whitespace_elimination_strategy_phase_factory(
        rectpacking_whitespace_elimination_strategy_from_string(
          @graph.node_get_string_property(
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
  layout_graph : @graph.ElkNode,
  progress_monitor : @core.IElkProgressMonitor,
) -> Unit {
  ignore(progress_monitor.begin("Rectangle Packing", 1.0))

  let padding = rectpacking_parse_padding(
    @graph.node_get_string_property(layout_graph, rectpacking_padding),
  )
  let fixed_graph_size = @graph.node_get_bool_property(
    layout_graph, rectpacking_node_size_fixed_graph_size,
  )
  let node_node_spacing = @graph.node_get_double_property(
    layout_graph, rectpacking_spacing_node_node,
  )
  let try_box = @graph.node_get_bool_property(layout_graph, rectpacking_trybox)
  let rectangles = @graph.node_children(layout_graph)
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
      if @graph.node_height(region1) >=
        @graph.node_height(region2) +
        @graph.node_height(region3) +
        node_node_spacing ||
        @graph.node_height(region3) >=
        @graph.node_height(region1) +
        @graph.node_height(region2) +
        node_node_spacing {
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
    real_width = @cmp.maximum(
      real_width,
      @graph.node_x(rect) + @graph.node_width(rect),
    )
    real_height = @cmp.maximum(
      real_height,
      @graph.node_y(rect) + @graph.node_height(rect),
    )
  }

  @core.translate(
    layout_graph,
    @core.new_kvector_xy(
      @graph.node_get_double_property(
        layout_graph, rectpacking_internal_drawing_width,
      ),
      @graph.node_get_double_property(
        layout_graph, rectpacking_internal_drawing_height,
      ),
    ),
    @core.new_kvector_xy(real_width, real_height),
  )

  rectpacking_apply_padding(rectangles, padding)

  if !fixed_graph_size {
    @graph.node_set_dimensions(
      layout_graph,
      @graph.node_get_double_property(
        layout_graph, rectpacking_internal_drawing_width,
      ) +
      padding.get_horizontal(),
      @graph.node_get_double_property(
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
) -> @core.AbstractLayoutProvider {
  @core.new_abstract_layout_provider((graph, monitor) => {
    provider.layout(graph, monitor)
  })
}
