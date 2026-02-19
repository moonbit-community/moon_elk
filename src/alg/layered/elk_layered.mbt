///|
pub struct ElkLayered {
  components_processor : LayeredComponentsProcessor
  compound_graph_preprocessor : @core.ILayoutProcessor[LayeredPhases, LGraph]
  compound_graph_postprocessor : @core.ILayoutProcessor[LayeredPhases, LGraph]
  mut test_controller : @core.TestController[LGraph]?
}

///|
pub struct ElkLayeredTestExecutionState {
  graphs : Array[LGraph]
  mut step : Int
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
fn elk_layered_parse_edge_routing(value : String) -> @core.EdgeRouting {
  for routing in @core.edge_routing_values() {
    if @core.edge_routing_to_string(routing) == value {
      return routing
    }
  }
  RoutingUndefined
}

///|
fn elk_layered_greedy_switch_strategy(
  greedy_switch_type : String,
) -> IntermediateProcessorStrategy {
  if greedy_switch_type == "ONE_SIDED" {
    IntermediateProcessorStrategy::OneSidedGreedySwitch
  } else {
    IntermediateProcessorStrategy::TwoSidedGreedySwitch
  }
}

///|
fn elk_layered_cycle_breaking_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "DEPTH_FIRST" =>
      @core.new_layout_processor_factory(21001, 0, () => {
        new_depth_first_cycle_breaker_layout_phase()
      })
    "INTERACTIVE" =>
      @core.new_layout_processor_factory(21002, 0, () => {
        new_interactive_cycle_breaker_layout_phase()
      })
    "MODEL_ORDER" =>
      @core.new_layout_processor_factory(21003, 0, () => {
        new_model_order_cycle_breaker_layout_phase()
      })
    "GREEDY_MODEL_ORDER" =>
      @core.new_layout_processor_factory(21004, 0, () => {
        new_greedy_model_order_cycle_breaker_layout_phase()
      })
    "SCC_CONNECTIVITY" =>
      @core.new_layout_processor_factory(21005, 0, () => {
        new_sc_connectivity_cycle_breaker_layout_phase()
      })
    "SCC_NODE_TYPE" =>
      @core.new_layout_processor_factory(21006, 0, () => {
        new_scc_node_type_cycle_breaker_layout_phase()
      })
    "DFS_NODE_ORDER" =>
      @core.new_layout_processor_factory(21007, 0, () => {
        new_dfs_node_order_cycle_breaker_layout_phase()
      })
    "BFS_NODE_ORDER" =>
      @core.new_layout_processor_factory(21008, 0, () => {
        new_bfs_node_order_cycle_breaker_layout_phase()
      })
    _ =>
      @core.new_layout_processor_factory(21000, 0, () => {
        new_greedy_cycle_breaker_layout_phase()
      })
  }
}

///|
fn elk_layered_layering_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "LONGEST_PATH" =>
      @core.new_layout_processor_factory(22001, 1, () => {
        new_longest_path_layerer_layout_phase()
      })
    "LONGEST_PATH_SOURCE" =>
      @core.new_layout_processor_factory(22002, 1, () => {
        new_longest_path_source_layerer_layout_phase()
      })
    "COFFMAN_GRAHAM" =>
      @core.new_layout_processor_factory(22003, 1, () => {
        new_coffman_graham_layerer_layout_phase()
      })
    "INTERACTIVE" =>
      @core.new_layout_processor_factory(22004, 1, () => {
        new_interactive_layerer_layout_phase()
      })
    "STRETCH_WIDTH" =>
      @core.new_layout_processor_factory(22005, 1, () => {
        new_stretch_width_layerer_layout_phase()
      })
    "MIN_WIDTH" =>
      @core.new_layout_processor_factory(22006, 1, () => {
        new_min_width_layerer_layout_phase()
      })
    "BF_MODEL_ORDER" =>
      @core.new_layout_processor_factory(22007, 1, () => {
        new_breadth_first_model_order_layerer_layout_phase()
      })
    "DF_MODEL_ORDER" =>
      @core.new_layout_processor_factory(22008, 1, () => {
        new_depth_first_model_order_layerer_layout_phase()
      })
    _ =>
      @core.new_layout_processor_factory(22000, 1, () => {
        new_network_simplex_layerer_layout_phase()
      })
  }
}

///|
fn elk_layered_crossing_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "NONE" =>
      @core.new_layout_processor_factory(24002, 2, () => {
        new_no_crossing_minimizer_layout_phase()
      })
    "INTERACTIVE" =>
      @core.new_layout_processor_factory(24003, 2, () => {
        new_interactive_crossing_minimizer_layout_phase()
      })
    "MEDIAN_LAYER_SWEEP" =>
      @core.new_layout_processor_factory(24001, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(CrossMinType::Median)
      })
    _ =>
      @core.new_layout_processor_factory(24000, 2, () => {
        new_layer_sweep_crossing_minimizer_layout_phase(
          CrossMinType::Barycenter,
        )
      })
  }
}

///|
fn elk_layered_node_placement_factory(
  strategy : String,
) -> @core.ILayoutProcessorFactory[LayeredPhases, LGraph] {
  match strategy {
    "SIMPLE" =>
      @core.new_layout_processor_factory(24100, 3, () => {
        new_simple_node_placer_layout_phase()
      })
    "INTERACTIVE" =>
      @core.new_layout_processor_factory(24101, 3, () => {
        new_interactive_node_placer_layout_phase()
      })
    "LINEAR_SEGMENTS" =>
      @core.new_layout_processor_factory(24102, 3, () => {
        new_linear_segments_node_placer_layout_phase()
      })
    "BRANDES_KOEPF" =>
      @core.new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
    "NETWORK_SIMPLEX" =>
      @core.new_layout_processor_factory(24104, 3, () => {
        new_network_simplex_placer_layout_phase()
      })
    _ =>
      @core.new_layout_processor_factory(24103, 3, () => {
        new_bk_node_placer_layout_phase()
      })
  }
}

///|
fn elk_layered_is_hierarchy_aware_processor(
  processor : @core.ILayoutProcessor[LayeredPhases, LGraph],
) -> Bool {
  processor.is_hierarchy_aware_layout_processor()
}

///|
fn[P] ElkLayered::notify_processor_ready(
  self : ElkLayered,
  lgraph : LGraph,
  processor : @core.ILayoutProcessor[P, LGraph],
) -> Unit {
  match self.test_controller {
    Some(controller) =>
      if elk_layered_is_root(lgraph) {
        controller.notify_root_processor_ready(lgraph, processor)
      } else {
        controller.notify_processor_ready(lgraph, processor)
      }
    None => ()
  }
}

///|
fn[P] ElkLayered::notify_processor_finished(
  self : ElkLayered,
  lgraph : LGraph,
  processor : @core.ILayoutProcessor[P, LGraph],
) -> Unit {
  match self.test_controller {
    Some(controller) =>
      if elk_layered_is_root(lgraph) {
        controller.notify_root_processor_finished(lgraph, processor)
      } else {
        controller.notify_processor_finished(lgraph, processor)
      }
    None => ()
  }
}

///|
fn elk_layered_collect_algorithm_for_graph(
  lgraph : LGraph,
) -> Array[@core.ILayoutProcessor[LayeredPhases, LGraph]] {
  let layering_strategy = lgraph.get_property_string(
    layered_options_layering_strategy,
  )
  let cycle_breaking_strategy = lgraph.get_property_string(
    layered_options_cycle_breaking_strategy,
  )
  let crossing_strategy = lgraph.get_property_string(
    layered_options_crossing_minimization_strategy,
  )
  let node_promotion_strategy = lgraph.get_property_string(
    layered_options_layering_node_promotion_strategy,
  )
  let compaction_post_strategy = lgraph.get_property_string(
    layered_options_compaction_post_compaction_strategy,
  )
  let high_degree_nodes_treatment = lgraph.get_property_bool(
    layered_options_high_degree_nodes_treatment,
  )
  let semi_interactive_cross_minimization = lgraph.get_property_bool(
    layered_options_crossing_minimization_semi_interactive,
  )
  let layer_unzipping_strategy = lgraph.get_property_string(
    layered_options_layer_unzipping_strategy,
  )
  let wrapping_strategy = lgraph.get_property_string(
    layered_options_wrapping_strategy,
  )
  let node_placement_strategy = lgraph.get_property_string(
    layered_options_node_placement_strategy,
  )
  let direction_value = lgraph.get_property_string(@core.direction)
  let feedback_edges = lgraph.get_property_bool(layered_options_feedback_edges)
  let edge_routing_value = lgraph.get_property_string(@core.edge_routing)
  let hierarchy_handling = lgraph.get_property_string(
    layered_options_hierarchy_handling,
  )
  let hierarchical_layout = hierarchy_handling == "INCLUDE_CHILDREN"
  let has_label_manager = lgraph.get_property_i_label_manager(
      @core.label_management_options_label_manager,
    )
    is Some(_)
  let interactive_layout = lgraph.get_property_bool(@core.interactive)
  let generate_position_and_layer_ids = lgraph.get_property_bool(
    layered_options_generate_position_and_layer_ids,
  )
  let greedy_switch_type = if hierarchical_layout {
    lgraph.get_property_string(
      layered_options_crossing_minimization_greedy_switch_hierarchical_type,
    )
  } else {
    lgraph.get_property_string(
      layered_options_crossing_minimization_greedy_switch_type,
    )
  }

  let assembler = @core.algorithm_assembler_create(layered_phase_descriptor)
  ignore(assembler.reset())
  ignore(
    assembler.set_phase(
      LayeredPhases::P1CycleBreaking,
      elk_layered_cycle_breaking_factory(cycle_breaking_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P2Layering,
      elk_layered_layering_factory(layering_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P3NodeOrdering,
      elk_layered_crossing_factory(crossing_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P4NodePlacement,
      elk_layered_node_placement_factory(node_placement_strategy),
    ),
  )
  ignore(
    assembler.set_phase(
      LayeredPhases::P5EdgeRouting,
      edge_router_factory_factory_for(
        elk_layered_parse_edge_routing(edge_routing_value),
      ),
    ),
  )
  ignore(
    assembler.add_processor_configuration(
      @core.layout_processor_configuration_create(layered_phase_descriptor)
      .add_before(
        LayeredPhases::P4NodePlacement,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::InnermostNodeMarginCalculator,
        ),
      )
      .add_before(
        LayeredPhases::P4NodePlacement,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::LabelAndNodeSizeProcessor,
        ),
      )
      .add_before(
        LayeredPhases::P5EdgeRouting,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::LayerSizeAndGraphHeightCalculator,
        ),
      )
      .add_after(
        LayeredPhases::P5EdgeRouting,
        layered_intermediate_processor_factory(
          IntermediateProcessorStrategy::EndLabelSorter,
        ),
      ),
    ),
  )
  if hierarchical_layout {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::HierarchicalNodeResizer,
          ),
        ),
      ),
    )
  }
  if feedback_edges {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P1CycleBreaking,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::PortSideProcessor,
          ),
        ),
      ),
    )
  } else {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::PortSideProcessor,
          ),
        ),
      ),
    )
  }

  if has_label_manager {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor)
        .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::CenterLabelManagementProcessor,
          ),
        )
        .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::EndNodePortLabelManagementProcessor,
          ),
        ),
      ),
    )
  }

  if interactive_layout || generate_position_and_layer_ids {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::ConstraintsPostprocessor,
          ),
        ),
      ),
    )
  }

  if elk_layered_requires_direction_transform(direction_value) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor)
        .add_before(
          LayeredPhases::P1CycleBreaking,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::DirectionPreprocessor,
          ),
        )
        .add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::DirectionPostprocessor,
          ),
        ),
      ),
    )
  }

  if elk_layered_has_graph_property(lgraph, GraphProperties::Comments) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor)
        .add_before(
          LayeredPhases::P1CycleBreaking,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::CommentPreprocessor,
          ),
        )
        .add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::CommentNodeMarginCalculator,
          ),
        )
        .add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::CommentPostprocessor,
          ),
        ),
      ),
    )
  }

  if node_promotion_strategy != "NONE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::NodePromotion,
          ),
        ),
      ),
    )
  }

  if elk_layered_has_graph_property(lgraph, GraphProperties::Partitions) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor)
        .add_before(
          LayeredPhases::P1CycleBreaking,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::PartitionPreprocessor,
          ),
        )
        .add_before(
          LayeredPhases::P2Layering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::PartitionMidprocessor,
          ),
        )
        .add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::PartitionPostprocessor,
          ),
        ),
      ),
    )
  }

  if compaction_post_strategy != "NONE" && edge_routing_value != "POLYLINE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_after(
          LayeredPhases::P5EdgeRouting,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::HorizontalCompactor,
          ),
        ),
      ),
    )
  }

  if high_degree_nodes_treatment {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::HighDegreeNodeLayerProcessor,
          ),
        ),
      ),
    )
  }

  if semi_interactive_cross_minimization {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::SemiInteractiveCrossMinProcessor,
          ),
        ),
      ),
    )
  }

  if graph_configurator_activate_greedy_switch_for(lgraph) {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            elk_layered_greedy_switch_strategy(greedy_switch_type),
          ),
        ),
      ),
    )
  }

  if layer_unzipping_strategy == "ALTERNATING" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P4NodePlacement,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::AlternatingLayerUnzipper,
          ),
        ),
      ),
    )
  }

  match wrapping_strategy {
    "SINGLE_EDGE" =>
      ignore(
        assembler.add_processor_configuration(
          @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
            LayeredPhases::P4NodePlacement,
            layered_intermediate_processor_factory(
              IntermediateProcessorStrategy::SingleEdgeGraphWrapper,
            ),
          ),
        ),
      )
    "MULTI_EDGE" =>
      ignore(
        assembler.add_processor_configuration(
          @core.layout_processor_configuration_create(layered_phase_descriptor)
          .add_before(
            LayeredPhases::P3NodeOrdering,
            layered_intermediate_processor_factory(
              IntermediateProcessorStrategy::BreakingPointInserter,
            ),
          )
          .add_before(
            LayeredPhases::P4NodePlacement,
            layered_intermediate_processor_factory(
              IntermediateProcessorStrategy::BreakingPointProcessor,
            ),
          )
          .add_after(
            LayeredPhases::P5EdgeRouting,
            layered_intermediate_processor_factory(
              IntermediateProcessorStrategy::BreakingPointRemover,
            ),
          ),
        ),
      )
    _ => ()
  }

  if lgraph.get_property_string(layered_options_consider_model_order_strategy) !=
    "NONE" {
    ignore(
      assembler.add_processor_configuration(
        @core.layout_processor_configuration_create(layered_phase_descriptor).add_before(
          LayeredPhases::P3NodeOrdering,
          layered_intermediate_processor_factory(
            IntermediateProcessorStrategy::SortByInputOrderOfModel,
          ),
        ),
      ),
    )
  }

  assembler.build(lgraph)
}

///|
fn elk_layered_collect_all_graphs_bottom_up(root : LGraph) -> Array[LGraph] {
  let collected_graphs : Array[LGraph] = [root]
  let continue_searching_these_graphs : Array[LGraph] = [root]

  while !continue_searching_these_graphs.is_empty() {
    let next_graph = match continue_searching_these_graphs.pop() {
      Some(graph) => graph
      None => abort("elk layered graph stack unexpectedly empty")
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
) -> Unit {
  let parent_crossing_strategy = root.get_property_string(
    layered_options_crossing_minimization_strategy,
  )
  for child in graphs {
    let child_crossing_strategy = child.get_property_string(
      layered_options_crossing_minimization_strategy,
    )
    if child_crossing_strategy != parent_crossing_strategy {
      abort(
        "org.eclipse.elk.core.UnsupportedGraphException: The hierarchy aware processor " +
        child_crossing_strategy +
        " in a child graph is only allowed if the root graph specifies the same hierarchical processor.",
      )
    }
  }

  let root_greedy_switch_hierarchical_type = root.get_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type,
  )
  for graph in graphs {
    graph.set_property_string(
      layered_options_crossing_minimization_greedy_switch_hierarchical_type, root_greedy_switch_hierarchical_type,
    )
  }
}

///|
fn elk_layered_resize_graph(lgraph : LGraph) -> Unit {
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
  monitor : @core.IElkProgressMonitor,
) -> Unit {
  let monitor_was_already_running = monitor.is_running()
  if !monitor_was_already_running {
    ignore(monitor.begin("Component Layout", 1.0))
  }

  let algorithm = lgraph.get_property_layout_processor_array(
    internal_properties_processors,
  )
  let monitor_progress = if algorithm.is_empty() {
    1.0
  } else {
    1.0 / algorithm.length().to_double()
  }

  for processor in algorithm {
    if monitor.is_canceled() {
      return
    }

    self.notify_processor_ready(lgraph, processor)
    processor.process(lgraph, monitor.sub_task(monitor_progress))
    self.notify_processor_finished(lgraph, processor)
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
) -> Unit {
  let graphs = elk_layered_collect_all_graphs_bottom_up(lgraph)
  elk_layered_review_and_correct_hierarchical_processors(lgraph, graphs)

  let algorithms : Array[Array[@core.ILayoutProcessor[LayeredPhases, LGraph]]] = []
  let processor_indices : Array[Int] = []
  let mut total_work = 0

  for graph in graphs {
    graph_configurator_prepare_graph_for_layout(graph)
    let algorithm = graph.get_property_layout_processor_array(
      internal_properties_processors,
    )
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
        if monitor.is_canceled() {
          return
        }

        let processor_index = processor_indices[i]
        let processor = algorithm[processor_index]

        processor_indices[i] = processor_index + 1

        if !elk_layered_is_hierarchy_aware_processor(processor) {
          self.notify_processor_ready(graph, processor)
          processor.process(graph, monitor.sub_task(1.0))
          self.notify_processor_finished(graph, processor)
          continue
        }

        if elk_layered_is_root(graph) {
          self.notify_processor_ready(graph, processor)
          processor.process(graph, monitor.sub_task(1.0))
          self.notify_processor_finished(graph, processor)
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
  lgraphs : Array[LGraph],
  processor : @core.ILayoutProcessor[LayeredPhases, LGraph],
) -> Unit {
  for lgraph in lgraphs {
    self.notify_processor_ready(lgraph, processor)
    processor.process(lgraph, Some(@core.new_null_elk_progress_monitor()))
    self.notify_processor_finished(lgraph, processor)
  }
}

///|
pub fn new_elk_layered() -> ElkLayered {
  {
    components_processor: new_layered_components_processor(),
    compound_graph_preprocessor: new_compound_graph_preprocessor_layout_processor(),
    compound_graph_postprocessor: new_compound_graph_postprocessor_layout_processor(),
    test_controller: None,
  }
}

///|
pub fn ElkLayered::do_layout(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let actual_monitor = elk_layered_resolve_monitor(monitor)
  ignore(actual_monitor.begin("Layered layout", 1.0))

  graph_configurator_prepare_graph_for_layout(lgraph)

  let components = self.components_processor.split(lgraph)
  if components.length() == 1 {
    self.layout(components[0], actual_monitor)
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
      self.layout(comp, comp_monitor)
    }
  }

  self.components_processor.combine(components, lgraph)
  elk_layered_resize_graph(lgraph)
  actual_monitor.done()
}

///|
pub fn ElkLayered::do_compound_layout(
  self : ElkLayered,
  lgraph : LGraph,
  monitor : @core.IElkProgressMonitor?,
) -> Unit {
  let actual_monitor = elk_layered_resolve_monitor(monitor)
  ignore(actual_monitor.begin("Layered layout", 2.0))

  self.notify_processor_ready(lgraph, self.compound_graph_preprocessor)
  self.compound_graph_preprocessor.process(lgraph, actual_monitor.sub_task(1.0))
  self.notify_processor_finished(lgraph, self.compound_graph_preprocessor)

  let hierarchy_monitor = match actual_monitor.sub_task(1.0) {
    Some(sub_monitor) => sub_monitor
    None => actual_monitor
  }
  self.hierarchical_layout(lgraph, hierarchy_monitor)

  self.notify_processor_ready(lgraph, self.compound_graph_postprocessor)
  self.compound_graph_postprocessor.process(
    lgraph,
    actual_monitor.sub_task(1.0),
  )
  self.notify_processor_finished(lgraph, self.compound_graph_postprocessor)

  actual_monitor.done()
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
) -> ElkLayeredTestExecutionState {
  graph_configurator_prepare_graph_for_layout(lgraph)
  let graphs = self.components_processor.split(lgraph)
  { graphs, step: 0 }
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
  let algorithm = state.graphs[0].get_property_layout_processor_array(
    internal_properties_processors,
  )
  state.step >= algorithm.length()
}

///|
pub fn ElkLayered::run_layout_test_until(
  self : ElkLayered,
  phase : @core.ILayoutProcessor[LayeredPhases, LGraph],
  state : ElkLayeredTestExecutionState,
  inclusive? : Bool = true,
) -> Unit {
  if state.graphs.is_empty() {
    return
  }
  let algorithm = state.graphs[0].get_property_layout_processor_array(
    internal_properties_processors,
  )
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
    self.layout_test(state.graphs, algorithm[state.step])
    state.step += 1
  }
}

///|
pub fn ElkLayered::run_layout_test_step(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Unit {
  if self.is_layout_test_finished(state) {
    abort("Current layout test run has finished.")
  }
  if state.graphs.is_empty() {
    return
  }

  let algorithm = state.graphs[0].get_property_layout_processor_array(
    internal_properties_processors,
  )
  self.layout_test(state.graphs, algorithm[state.step])
  state.step += 1
}

///|
pub fn ElkLayered::get_layout_test_configuration(
  self : ElkLayered,
  state : ElkLayeredTestExecutionState,
) -> Array[@core.ILayoutProcessor[LayeredPhases, LGraph]] {
  ignore(self)
  if state.graphs.is_empty() {
    return []
  }
  state.graphs[0].get_property_layout_processor_array(
    internal_properties_processors,
  )
}

///|
pub fn ElkLayered::set_test_controller(
  self : ElkLayered,
  test_controller : @core.TestController[LGraph]?,
) -> Unit {
  self.test_controller = test_controller
}
