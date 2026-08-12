///|
pub struct ElkLayered {
  runtime : @core.LayoutRuntime
  session : @core.LayoutSession
  phase_registry : LayeredPhaseRegistry
  layout_state : @runtime.LayeredRunState
  components_processor : @components.LayeredComponentsProcessor
  compound_graph_preprocessor : @core.TypedLayoutProcessor[LGraph]
  compound_graph_postprocessor : @core.TypedLayoutProcessor[LGraph]
  mut test_controller : @core.TestController[LGraph]?
}

///|
pub struct ElkLayeredTestExecutionState {
  graphs : Array[LGraph]
  plans : Array[LayeredLayoutPlan]
  mut step : Int
}

///|
pub suberror ElkLayeredTestExecutionException {
  ElkLayeredTestExecutionException(String)
} derive(Debug, ToJson)

///|
fn[T] elk_layered_test_execution_raise(
  message : String,
) -> T raise ElkLayeredTestExecutionException {
  raise ElkLayeredTestExecutionException(message)
}

///|
fn elk_layered_resolve_monitor(
  monitor : @core.IElkProgressMonitor?,
) -> @core.IElkProgressMonitor {
  match monitor {
    Some(value) => value
    None => @core.new_null_elk_progress_monitor()
  }
}

///|
fn elk_layered_is_root(graph : LGraph) -> Bool {
  graph.get_parent_node() is None
}

///|
fn elk_layered_has_nested_graph(node : LNode) -> Bool {
  node.get_nested_graph() is Some(_)
}

///|
let elk_layered_default_min_width = 20.0

///|
let elk_layered_default_min_height = 20.0

///|
fn elk_layered_string_set_contains(
  values : Array[String],
  expected : String,
) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn elk_layered_graph_property_equals(
  left : GraphProperties,
  right : GraphProperties,
) -> Bool {
  match (left, right) {
    (Comments, Comments) => true
    (ExternalPorts, ExternalPorts) => true
    (Hyperedges, Hyperedges) => true
    (Hypernodes, Hypernodes) => true
    (NonFreePorts, NonFreePorts) => true
    (NorthSouthPorts, NorthSouthPorts) => true
    (SelfLoops, SelfLoops) => true
    (CenterLabels, CenterLabels) => true
    (EndLabels, EndLabels) => true
    (Partitions, Partitions) => true
    _ => false
  }
}

///|
fn elk_layered_has_graph_property(
  lgraph : LGraph,
  expected : GraphProperties,
) -> Bool {
  for
    property in lgraph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if elk_layered_graph_property_equals(property, expected) {
      return true
    }
  }
  false
}

///|
fn elk_layered_requires_direction_transform(direction_value : String) -> Bool {
  direction_value == "LEFT" ||
  direction_value == "DOWN" ||
  direction_value == "UP"
}

///|
fn elk_layered_greedy_switch_strategy(
  greedy_switch_type : String,
) -> IntermediateProcessorStrategy {
  if greedy_switch_type == "ONE_SIDED" {
    OneSidedGreedySwitch
  } else {
    TwoSidedGreedySwitch
  }
}

///|
fn elk_layered_cycle_breaking_factory(
  registry : LayeredPhaseRegistry,
  graph : LGraph,
  state : @runtime.LayeredRunState,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  registry.cycle_breaking_phase_factory(graph, strategy, state~)
}

///|
fn elk_layered_layering_factory(
  registry : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  registry.layering_phase_factory(graph, strategy)
}

///|
fn elk_layered_crossing_factory(
  registry : LayeredPhaseRegistry,
  graph : LGraph,
  state : @runtime.LayeredRunState,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  registry.crossing_minimization_phase_factory(graph, strategy, state~)
}

///|
fn elk_layered_node_placement_factory(
  registry : LayeredPhaseRegistry,
  graph : LGraph,
  strategy : String,
) -> @core.LayoutProcessorFactory raise {
  registry.node_placement_phase_factory(graph, strategy)
}

///|
fn elk_layered_is_hierarchy_aware_processor(
  processor : &@core.RunnableLayoutProcessor,
) -> Bool {
  processor.is_hierarchy_aware_layout_processor()
}

///|
fn ElkLayered::notify_processor_ready(
  self : ElkLayered,
  lgraph : LGraph,
  processor_id : Int,
) -> Unit {
  match self.test_controller {
    Some(controller) =>
      if elk_layered_is_root(lgraph) {
        controller.notify_root_processor_ready(lgraph, processor_id)
      } else {
        controller.notify_processor_ready(lgraph, processor_id)
      }
    None => ()
  }
}

///|
fn ElkLayered::notify_processor_finished(
  self : ElkLayered,
  lgraph : LGraph,
  processor_id : Int,
) -> Unit {
  match self.test_controller {
    Some(controller) =>
      if elk_layered_is_root(lgraph) {
        controller.notify_root_processor_finished(lgraph, processor_id)
      } else {
        controller.notify_processor_finished(lgraph, processor_id)
      }
    None => ()
  }
}

///|
fn elk_layered_collect_algorithm_for_graph(
  registry : LayeredPhaseRegistry,
  lgraph : LGraph,
  state : @runtime.LayeredRunState,
) -> @core.LayoutProcessorPlan raise {
  let layering_strategy = lgraph.get_property_string(
    @options.layered_options_layering_strategy,
  )
  let cycle_breaking_strategy = lgraph.get_property_string(
    @options.layered_options_cycle_breaking_strategy,
  )
  let crossing_strategy = lgraph.get_property_string(
    @options.layered_options_crossing_minimization_strategy,
  )
  let node_promotion_strategy = lgraph.get_property_string(
    @options.layered_options_layering_node_promotion_strategy,
  )
  let compaction_post_strategy = lgraph.get_property_string(
    @options.layered_options_compaction_post_compaction_strategy,
  )
  let high_degree_nodes_treatment = lgraph.get_property_bool(
    @options.layered_options_high_degree_nodes_treatment,
  )
  let semi_interactive_cross_minimization = lgraph.get_property_bool(
    @options.layered_options_crossing_minimization_semi_interactive,
  )
  let layer_unzipping_strategy = lgraph.get_property_string(
    @options.layered_options_layer_unzipping_strategy,
  )
  let wrapping_strategy = lgraph.get_property_string(
    @options.layered_options_wrapping_strategy,
  )
  let node_placement_strategy = lgraph.get_property_string(
    @options.layered_options_node_placement_strategy,
  )
  let direction_value = lgraph.get_property_string(@core.direction)
  let feedback_edges = lgraph.get_property_bool(
    @options.layered_options_feedback_edges,
  )
  let edge_routing_value = lgraph.get_property_string(@core.edge_routing)
  let hierarchy_handling = lgraph.get_property_string(
    @options.layered_options_hierarchy_handling,
  )
  let hierarchical_layout = hierarchy_handling == "INCLUDE_CHILDREN"
  let has_label_manager = lgraph.get_property_i_label_manager(
      @core.label_management_options_label_manager,
    )
    is Some(_)
  let interactive_layout = lgraph.get_property_bool(@core.interactive)
  let generate_position_and_layer_ids = lgraph.get_property_bool(
    @options.layered_options_generate_position_and_layer_ids,
  )
  let greedy_switch_type = if hierarchical_layout {
    lgraph.get_property_string(
      @options.layered_options_crossing_minimization_greedy_switch_hierarchical_type,
    )
  } else {
    lgraph.get_property_string(
      @options.layered_options_crossing_minimization_greedy_switch_type,
    )
  }

  let assembler = @core.algorithm_assembler_create(layered_phase_descriptor)
  ignore(assembler.reset())
  ignore(
    assembler.set_phase(
      @runtime.P1CycleBreaking,
      elk_layered_cycle_breaking_factory(
        registry, lgraph, state, cycle_breaking_strategy,
      ),
    ),
  )
  ignore(
    assembler.set_phase(
      @runtime.P2Layering,
      elk_layered_layering_factory(registry, lgraph, layering_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      @runtime.P3NodeOrdering,
      elk_layered_crossing_factory(registry, lgraph, state, crossing_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      @runtime.P4NodePlacement,
      elk_layered_node_placement_factory(
        registry, lgraph, node_placement_strategy,
      ),
    ),
  )
  ignore(
    assembler.set_phase(
      @runtime.P5EdgeRouting,
      registry.edge_routing_phase_factory(lgraph, edge_routing_value, state~),
    ),
  )
  ignore(
    assembler.add_processor_configuration(
      @core.layout_processor_configuration_create()
      .add_before(
        @runtime.P4NodePlacement,
        registry.intermediate_processor_factory(
          lgraph,
          InnermostNodeMarginCalculator,
        ),
      )
      .add_before(
        @runtime.P4NodePlacement,
        registry.intermediate_processor_factory(
          lgraph,
          LabelAndNodeSizeProcessor,
        ),
      )
      .add_before(
        @runtime.P5EdgeRouting,
        registry.intermediate_processor_factory(
          lgraph,
          LayerSizeAndGraphHeightCalculator,
        ),
      )
      .add_after(
        @runtime.P5EdgeRouting,
        registry.intermediate_processor_factory(lgraph, EndLabelSorter),
      ),
    ),
  )
  if hierarchical_layout {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_after(
          @runtime.P5EdgeRouting,
          registry.intermediate_processor_factory(
            lgraph,
            HierarchicalNodeResizer,
          ),
        ),
      ),
    )
  }
  if feedback_edges {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P1CycleBreaking,
          registry.intermediate_processor_factory(lgraph, PortSideProcessor),
        ),
      ),
    )
  } else {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(lgraph, PortSideProcessor),
        ),
      ),
    )
  }

  if has_label_manager {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create()
        .add_before(
          @runtime.P4NodePlacement,
          registry.intermediate_processor_factory(
            lgraph,
            CenterLabelManagementProcessor,
          ),
        )
        .add_before(
          @runtime.P4NodePlacement,
          registry.intermediate_processor_factory(
            lgraph,
            EndNodePortLabelManagementProcessor,
          ),
        ),
      ),
    )
  }

  if interactive_layout || generate_position_and_layer_ids {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_after(
          @runtime.P5EdgeRouting,
          registry.intermediate_processor_factory(
            lgraph,
            ConstraintsPostprocessor,
          ),
        ),
      ),
    )
  }

  if elk_layered_requires_direction_transform(direction_value) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create()
        .add_before(
          @runtime.P1CycleBreaking,
          registry.intermediate_processor_factory(lgraph, DirectionPreprocessor),
        )
        .add_after(
          @runtime.P5EdgeRouting,
          registry.intermediate_processor_factory(
            lgraph,
            DirectionPostprocessor,
          ),
        ),
      ),
    )
  }

  if elk_layered_has_graph_property(lgraph, Comments) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create()
        .add_before(
          @runtime.P1CycleBreaking,
          registry.intermediate_processor_factory(lgraph, CommentPreprocessor),
        )
        .add_before(
          @runtime.P4NodePlacement,
          registry.intermediate_processor_factory(
            lgraph,
            CommentNodeMarginCalculator,
          ),
        )
        .add_after(
          @runtime.P5EdgeRouting,
          registry.intermediate_processor_factory(lgraph, CommentPostprocessor),
        ),
      ),
    )
  }

  if node_promotion_strategy != "NONE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(lgraph, NodePromotion),
        ),
      ),
    )
  }

  if elk_layered_has_graph_property(lgraph, Partitions) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create()
        .add_before(
          @runtime.P1CycleBreaking,
          registry.intermediate_processor_factory(lgraph, PartitionPreprocessor),
        )
        .add_before(
          @runtime.P2Layering,
          registry.intermediate_processor_factory(lgraph, PartitionMidprocessor),
        )
        .add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(
            lgraph,
            PartitionPostprocessor,
          ),
        ),
      ),
    )
  }

  if compaction_post_strategy != "NONE" && edge_routing_value != "POLYLINE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_after(
          @runtime.P5EdgeRouting,
          registry.intermediate_processor_factory(lgraph, HorizontalCompactor),
        ),
      ),
    )
  }

  if high_degree_nodes_treatment {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(
            lgraph,
            HighDegreeNodeLayerProcessor,
          ),
        ),
      ),
    )
  }

  if semi_interactive_cross_minimization {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(
            lgraph,
            SemiInteractiveCrossMinProcessor,
          ),
        ),
      ),
    )
  }

  if @transform.graph_configurator_activate_greedy_switch_for(lgraph) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P4NodePlacement,
          registry.intermediate_processor_factory(
            lgraph,
            elk_layered_greedy_switch_strategy(greedy_switch_type),
            state~,
          ),
        ),
      ),
    )
  }

  if layer_unzipping_strategy == "ALTERNATING" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P4NodePlacement,
          registry.intermediate_processor_factory(
            lgraph,
            AlternatingLayerUnzipper,
          ),
        ),
      ),
    )
  }

  match wrapping_strategy {
    "SINGLE_EDGE" =>
      ignore(
        assembler.add_processor_configuration(
          @core.layout_processor_configuration_create().add_before(
            @runtime.P4NodePlacement,
            registry.intermediate_processor_factory(
              lgraph,
              SingleEdgeGraphWrapper,
            ),
          ),
        ),
      )
    "MULTI_EDGE" =>
      ignore(
        assembler.add_processor_configuration(
          @core.layout_processor_configuration_create()
          .add_before(
            @runtime.P3NodeOrdering,
            registry.intermediate_processor_factory(
              lgraph,
              BreakingPointInserter,
            ),
          )
          .add_before(
            @runtime.P4NodePlacement,
            registry.intermediate_processor_factory(
              lgraph,
              BreakingPointProcessor,
            ),
          )
          .add_after(
            @runtime.P5EdgeRouting,
            registry.intermediate_processor_factory(
              lgraph,
              BreakingPointRemover,
            ),
          ),
        ),
      )
    _ => ()
  }

  if lgraph.get_property_string(
      @options.layered_options_consider_model_order_strategy,
    ) !=
    "NONE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create().add_before(
          @runtime.P3NodeOrdering,
          registry.intermediate_processor_factory(
            lgraph,
            SortByInputOrderOfModel,
          ),
        ),
      ),
    )
  }

  assembler.build()
}

///|
fn elk_layered_collect_all_graphs_bottom_up(root : LGraph) -> Array[LGraph] {
  let collected_graphs : Array[LGraph] = [root]
  let continue_searching_these_graphs : Array[LGraph] = [root]

  while !continue_searching_these_graphs.is_empty() {
    let next_graph = match continue_searching_these_graphs.pop() {
      Some(graph) => graph
      None => break
    }
    for node in next_graph.get_layerless_nodes() {
      if elk_layered_has_nested_graph(node) {
        match node.get_nested_graph() {
          Some(nested_graph) => {
            collected_graphs.push(nested_graph)
            continue_searching_these_graphs.push(nested_graph)
          }
          None => ()
        }
      }
    }
  }

  let reversed_graphs : Array[LGraph] = []
  for i = collected_graphs.length() - 1; i >= 0; i = i - 1 {
    reversed_graphs.push(collected_graphs[i])
  }
  reversed_graphs
}

///|
fn elk_layered_review_and_correct_hierarchical_processors(
  root : LGraph,
  graphs : Array[LGraph],
) -> Unit raise {
  let parent_crossing_strategy = root.get_property_string(
    @options.layered_options_crossing_minimization_strategy,
  )
  for child in graphs {
    let child_crossing_strategy = child.get_property_string(
      @options.layered_options_crossing_minimization_strategy,
    )
    if child_crossing_strategy != parent_crossing_strategy {
      @core.layout_runtime_raise_unsupported_configuration(
        "org.eclipse.elk.core.UnsupportedGraphException: The hierarchy aware processor " +
        child_crossing_strategy +
        " in a child graph is only allowed if the root graph specifies the same hierarchical processor.",
      )
      return
    }
  }

  let root_greedy_switch_hierarchical_type = root.get_property_string(
    @options.layered_options_crossing_minimization_greedy_switch_hierarchical_type,
  )
  for graph in graphs {
    graph.set_property_string(
      @options.layered_options_crossing_minimization_greedy_switch_hierarchical_type,
      root_greedy_switch_hierarchical_type,
    )
  }
}

///|
fn elk_layered_resize_graph(lgraph : LGraph) -> Unit raise {
  let size_constraint = lgraph.get_property_string_array(
    @core.node_size_constraints,
  )
  let size_options = lgraph.get_property_string_array(@core.node_size_options)

  let calculated_size = lgraph.get_actual_size()
  let adjusted_size = @core.new_kvector_copy(calculated_size)

  if elk_layered_string_set_contains(size_constraint, "MINIMUM_SIZE") {
    let min_size = @core.new_kvector()
    min_size.parse(lgraph.get_property_string(@core.node_size_minimum))

    if elk_layered_string_set_contains(size_options, "DEFAULT_MINIMUM_SIZE") {
      if min_size.x <= 0.0 {
        min_size.x = elk_layered_default_min_width
      }

      if min_size.y <= 0.0 {
        min_size.y = elk_layered_default_min_height
      }
    }

    adjusted_size.x = if calculated_size.x > min_size.x {
      calculated_size.x
    } else {
      min_size.x
    }
    adjusted_size.y = if calculated_size.y > min_size.y {
      calculated_size.y
    } else {
      min_size.y
    }
  }

  if !lgraph.get_property_bool(@core.node_size_fixed_graph_size) {
    elk_layered_resize_graph_no_really_i_mean_it(
      lgraph, calculated_size, adjusted_size,
    )
  }
}

///|
fn elk_layered_resize_graph_no_really_i_mean_it(
  lgraph : LGraph,
  old_size : @core.KVector,
  new_size : @core.KVector,
) -> Unit {
  let content_alignment_values = lgraph.get_property_string_array(
    @core.content_alignment,
  )

  if new_size.x > old_size.x {
    if elk_layered_string_set_contains(content_alignment_values, "H_CENTER") {
      lgraph.get_offset().x = lgraph.get_offset().x +
        (new_size.x - old_size.x) / 2.0
    } else if elk_layered_string_set_contains(
        content_alignment_values, "H_RIGHT",
      ) {
      lgraph.get_offset().x = lgraph.get_offset().x + (new_size.x - old_size.x)
    }
  }

  if new_size.y > old_size.y {
    if elk_layered_string_set_contains(content_alignment_values, "V_CENTER") {
      lgraph.get_offset().y = lgraph.get_offset().y +
        (new_size.y - old_size.y) / 2.0
    } else if elk_layered_string_set_contains(
        content_alignment_values, "V_BOTTOM",
      ) {
      lgraph.get_offset().y = lgraph.get_offset().y + (new_size.y - old_size.y)
    }
  }

  if elk_layered_has_graph_property(lgraph, ExternalPorts) &&
    (new_size.x > old_size.x || new_size.y > old_size.y) {
    for node in lgraph.get_layerless_nodes() {
      if node.get_type() is ExternalPort {
        match node.get_property_port_side(internal_properties_ext_port_side) {
          East =>
            node.get_position().x = node.get_position().x +
              (new_size.x - old_size.x)
          South =>
            node.get_position().y = node.get_position().y +
              (new_size.y - old_size.y)
          _ => ()
        }
      }
    }
  }

  let padding = lgraph.get_padding()
  lgraph.get_size().x = new_size.x - padding.left - padding.right
  lgraph.get_size().y = new_size.y - padding.top - padding.bottom
}

///|
fn ElkLayered::layout(
  self : ElkLayered,
  lgraph : LGraph,
  plan : LayeredLayoutPlan,
  monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  let monitor_was_already_running = monitor.is_running()
  if !monitor_was_already_running {
    ignore(monitor.begin("Component Layout", 1.0))
  }

  let algorithm = plan.get_processors()
  let monitor_progress = if algorithm.is_empty() {
    1.0
  } else {
    1.0 / algorithm.length().to_double()
  }

  for processor in algorithm {
    if monitor.is_canceled() || self.session.has_error() {
      return
    }

    self.notify_processor_ready(lgraph, processor.instance_id())
    processor.run(monitor.sub_task(monitor_progress))
    self.notify_processor_finished(lgraph, processor.instance_id())
    if self.session.has_error() {
      return
    }
  }

  for layer in lgraph.get_layers() {
    for node in layer.get_nodes() {
      lgraph.get_layerless_nodes().push(node)
    }
    layer.get_nodes().clear()
  }

  for node in lgraph.get_layerless_nodes() {
    node.set_layer(None)
  }

  lgraph.get_layers().clear()

  if !monitor_was_already_running {
    monitor.done()
  }
}

///|
fn ElkLayered::hierarchical_layout(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor,
) -> Unit raise {
  let graphs = elk_layered_collect_all_graphs_bottom_up(lgraph)
  elk_layered_review_and_correct_hierarchical_processors(lgraph, graphs)

  let algorithms : Array[Array[&@core.RunnableLayoutProcessor]] = []
  let processor_indices : Array[Int] = []
  let mut total_work = 0

  for graph in graphs {
    let algorithm = graph_configurator_prepare_graph_for_layout(
      self.phase_registry,
      graph,
      self.layout_state,
    ).get_processors()
    total_work = total_work + algorithm.length()
    algorithms.push(algorithm)
    processor_indices.push(0)
  }

  ignore(monitor.begin("Recursive hierarchical layout", total_work.to_double()))

  if graphs.is_empty() {
    monitor.done()
    return
  }

  let root_index = graphs.length() - 1
  while processor_indices[root_index] < algorithms[root_index].length() {
    for i = 0; i < graphs.length(); i = i + 1 {
      let graph = graphs[i]
      let algorithm = algorithms[i]

      while processor_indices[i] < algorithm.length() {
        if monitor.is_canceled() || self.session.has_error() {
          return
        }

        let processor_index = processor_indices[i]
        let processor = algorithm[processor_index]

        processor_indices[i] = processor_index + 1

        if !elk_layered_is_hierarchy_aware_processor(processor) {
          self.notify_processor_ready(graph, processor.instance_id())
          processor.run(monitor.sub_task(1.0))
          self.notify_processor_finished(graph, processor.instance_id())
          if self.session.has_error() {
            return
          }
          continue
        }

        if elk_layered_is_root(graph) {
          self.notify_processor_ready(graph, processor.instance_id())
          processor.run(monitor.sub_task(1.0))
          self.notify_processor_finished(graph, processor.instance_id())
          if self.session.has_error() {
            return
          }
        }

        break
      }
    }
  }

  monitor.done()
}

///|
fn ElkLayered::layout_test(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Unit raise {
  for i = 0; i < state.graphs.length(); i = i + 1 {
    let lgraph = state.graphs[i]
    let processor = state.plans[i].get_processors()[state.step]
    self.notify_processor_ready(lgraph, processor.instance_id())
    processor.run(Some(@core.new_null_elk_progress_monitor()))
    self.notify_processor_finished(lgraph, processor.instance_id())
  }
}

///|
pub fn new_elk_layered(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  phase_registry : LayeredPhaseRegistry,
) -> ElkLayered {
  {
    runtime,
    session,
    phase_registry,
    layout_state: @runtime.new_layered_run_state(),
    components_processor: @components.new_layered_components_processor(),
    compound_graph_preprocessor: @compound.new_compound_graph_preprocessor_layout_processor(),
    compound_graph_postprocessor: @compound.new_compound_graph_postprocessor_layout_processor(),
    test_controller: None,
  }
}

///|
fn ElkLayered::do_layout_inner(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  let actual_monitor = elk_layered_resolve_monitor(monitor)
  ignore(actual_monitor.begin("Layered layout", 1.0))

  let components = self.components_processor.split(lgraph)
  if components.length() == 1 {
    let plan = graph_configurator_prepare_graph_for_layout(
      self.phase_registry,
      components[0],
      self.layout_state,
    )
    self.layout(components[0], plan, actual_monitor)
  } else {
    let comp_work = 1.0 / components.length().to_double()
    for comp in components {
      if actual_monitor.is_canceled() {
        return
      }
      let comp_monitor = match actual_monitor.sub_task(comp_work) {
        Some(sub_monitor) => sub_monitor
        None => actual_monitor
      }
      let plan = graph_configurator_prepare_graph_for_layout(
        self.phase_registry,
        comp,
        self.layout_state,
      )
      self.layout(comp, plan, comp_monitor)
      if self.session.has_error() {
        actual_monitor.done()
        return
      }
    }
  }
  if self.session.has_error() {
    actual_monitor.done()
    return
  }

  self.components_processor.combine(components, lgraph)
  elk_layered_resize_graph(lgraph)
  actual_monitor.done()
}

///|
pub fn ElkLayered::do_layout(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  self.layout_state.clear()
  try self.do_layout_inner(lgraph, monitor) catch {
    error => {
      self.layout_state.clear()
      raise error
    }
  } noraise {
    _ => ()
  }
  self.layout_state.clear()
}

///|
fn ElkLayered::do_compound_layout_inner(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  let actual_monitor = elk_layered_resolve_monitor(monitor)
  ignore(actual_monitor.begin("Layered layout", 2.0))

  self.notify_processor_ready(
    lgraph,
    self.compound_graph_preprocessor.instance_id(),
  )
  self.compound_graph_preprocessor.process(lgraph, actual_monitor.sub_task(1.0))
  self.notify_processor_finished(
    lgraph,
    self.compound_graph_preprocessor.instance_id(),
  )
  if self.session.has_error() {
    actual_monitor.done()
    return
  }

  let hierarchy_monitor = match actual_monitor.sub_task(1.0) {
    Some(sub_monitor) => sub_monitor
    None => actual_monitor
  }
  self.hierarchical_layout(lgraph, hierarchy_monitor)
  if self.session.has_error() {
    actual_monitor.done()
    return
  }

  self.notify_processor_ready(
    lgraph,
    self.compound_graph_postprocessor.instance_id(),
  )
  self.compound_graph_postprocessor.process(
    lgraph,
    actual_monitor.sub_task(1.0),
  )
  self.notify_processor_finished(
    lgraph,
    self.compound_graph_postprocessor.instance_id(),
  )
  if self.session.has_error() {
    actual_monitor.done()
    return
  }

  actual_monitor.done()
}

///|
pub fn ElkLayered::do_compound_layout(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit raise {
  self.layout_state.clear()
  try self.do_compound_layout_inner(lgraph, monitor) catch {
    error => {
      self.layout_state.clear()
      raise error
    }
  } noraise {
    _ => ()
  }
  self.layout_state.clear()
}

///|
pub fn ElkLayeredTestExecutionState::get_graphs(
  self : ElkLayeredTestExecutionState,
) -> Array[LGraph] {
  self.graphs
}

///|
pub fn ElkLayeredTestExecutionState::get_step(
  self : ElkLayeredTestExecutionState,
) -> Int {
  self.step
}

///|
pub fn ElkLayered::prepare_layout_test(
  self : ElkLayered,
  lgraph : LGraph,
) -> ElkLayeredTestExecutionState raise {
  let graphs = self.components_processor.split(lgraph)
  let plans = graphs.map(graph => {
    graph_configurator_prepare_graph_for_layout(
      self.phase_registry,
      graph,
      self.layout_state,
    )
  })
  { graphs, plans, step: 0 }
}

///|
pub fn ElkLayered::is_layout_test_finished(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Bool {
  ignore(self)
  if state.graphs.is_empty() {
    return true
  }
  let algorithm = state.plans[0].get_processors()
  state.step >= algorithm.length()
}

///|
pub fn ElkLayered::run_layout_test_until(
  self : ElkLayered,
  phase : &@core.RunnableLayoutProcessor,
  state : ElkLayeredTestExecutionState,
  inclusive? : Bool = true,
) -> Unit raise {
  if state.graphs.is_empty() {
    return
  }
  let algorithm = state.plans[0].get_processors()
  let mut phase_exists = false
  let mut phase_index = state.step

  for i = state.step; i < algorithm.length() && !phase_exists; i = i + 1 {
    if algorithm[i].instance_id() == phase.instance_id() {
      phase_exists = true
      if inclusive {
        phase_index = i + 1
      } else {
        phase_index = i
      }
    } else {
      phase_index = i + 1
    }
  }

  if !phase_exists {
    println("Given processor not part of the remaining algorithm.")
  }

  while state.step < phase_index {
    self.layout_test(state)
    state.step += 1
  }
}

///|
pub fn ElkLayered::run_layout_test_step(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Unit raise {
  if self.is_layout_test_finished(state) {
    elk_layered_test_execution_raise("Current layout test run has finished.")
  }
  if state.graphs.is_empty() {
    return
  }

  self.layout_test(state)
  state.step += 1
}

///|
pub fn ElkLayered::get_layout_test_configuration(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Array[&@core.RunnableLayoutProcessor] {
  ignore(self)
  if state.graphs.is_empty() {
    return []
  }
  state.plans[0].get_processors()
}

///|
pub fn ElkLayered::set_test_controller(
  self : ElkLayered,
  test_controller : @core.TestController[LGraph]?,
) -> Unit {
  self.test_controller = test_controller
}
