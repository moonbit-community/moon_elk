///|
test "elk layered do_layout scaffold completes monitor lifecycle" {
  let elk_layered = new_elk_layered()
  let lgraph = new_l_graph()
  let monitor = new_elk_progress_monitor()

  elk_layered.do_layout(lgraph, Some(monitor))

  assert_false(monitor.is_running())
}

///|
test "elk layered do_compound_layout notifies installed test controller" {
  let elk_layered = new_elk_layered()
  let expected_graph = elk_layered_test_graph_with_greedy_switch_off()
  let lgraph = elk_layered_test_graph_with_greedy_switch_off()
  let monitor = new_elk_progress_monitor()

  let expected_state = elk_layered.prepare_layout_test(expected_graph)
  let expected_notification_count = elk_layered
    .get_layout_test_configuration(expected_state)
    .length() +
    2

  let ready_count = Ref(0)
  let finished_count = Ref(0)
  let root_ready_count = Ref(0)
  let root_finished_count = Ref(0)

  let listener : ILayoutExecutionListener[LGraph] = new_layout_execution_listener(
    (processor_id, graph, is_root) => {
      ignore(processor_id)
      ignore(graph)
      ready_count.val = ready_count.val + 1
      if is_root {
        root_ready_count.val = root_ready_count.val + 1
      }
    },
    (processor_id, graph, is_root) => {
      ignore(processor_id)
      ignore(graph)
      finished_count.val = finished_count.val + 1
      if is_root {
        root_finished_count.val = root_finished_count.val + 1
      }
    },
  )
  let controller : @core.TestController[LGraph] = @core.new_test_controller(
    "org.eclipse.elk.layered",
  )
  controller.add_layout_execution_listener(listener)
  elk_layered.set_test_controller(Some(controller))

  elk_layered.do_compound_layout(lgraph, Some(monitor))

  assert_eq(ready_count.val, expected_notification_count)
  assert_eq(finished_count.val, expected_notification_count)
  assert_eq(root_ready_count.val, expected_notification_count)
  assert_eq(root_finished_count.val, expected_notification_count)
}

///|
test "elk layered run_layout_test_until follows inclusive boundary semantics" {
  let elk_layered = new_elk_layered()
  let state = elk_layered.prepare_layout_test(
    elk_layered_test_graph_with_greedy_switch_off(),
  )
  let algorithm = elk_layered.get_layout_test_configuration(state)
  assert_false(algorithm.is_empty())

  let target_index = if algorithm.length() > 2 {
    2
  } else {
    algorithm.length() - 1
  }
  let target = algorithm[target_index]

  elk_layered.run_layout_test_until(target, state, inclusive=false)
  assert_eq(state.get_step(), target_index)

  elk_layered.run_layout_test_until(target, state)
  assert_eq(state.get_step(), target_index + 1)
}

///|
fn elk_layered_test_graph_with_greedy_switch_off() -> LGraph {
  let graph = new_l_graph()
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_type, "OFF",
  )
  graph.set_property_string(
    layered_options_crossing_minimization_greedy_switch_hierarchical_type, "OFF",
  )
  graph
}

///|
fn elk_layered_test_algorithm_length(graph : LGraph) -> Int {
  let elk_layered = new_elk_layered()
  let state = elk_layered.prepare_layout_test(graph)
  elk_layered.get_layout_test_configuration(state).length()
}

///|
fn elk_layered_test_label_manager() -> @core.ILabelManager {
  new_i_label_manager((origin, target_width) => {
    ignore(origin)
    ignore(target_width)
    None
  })
}

///|
fn elk_layered_test_graph_property(name : String) -> GraphProperties {
  for property in graph_properties_values() {
    if graph_properties_to_string(property) == name {
      return property
    }
  }
  abort("unknown graph property")
}

///|
test "elk layered adds @core.direction pre and post processors for downward layouts" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  baseline.set_property_string(@core.direction, "RIGHT")
  let downward = elk_layered_test_graph_with_greedy_switch_off()
  downward.set_property_string(@core.direction, "DOWN")

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let downward_algorithm_length = elk_layered_test_algorithm_length(downward)
  assert_eq(downward_algorithm_length, baseline_algorithm_length + 2)
}

///|
test "elk layered adds comment processors when comments graph property is present" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let with_comments = elk_layered_test_graph_with_greedy_switch_off()
  with_comments.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [elk_layered_test_graph_property("COMMENTS")],
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let comments_algorithm_length = elk_layered_test_algorithm_length(
    with_comments,
  )
  assert_eq(comments_algorithm_length, baseline_algorithm_length + 3)
}

///|
test "elk layered adds partition processors when partition graph property is present" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let with_partitions = elk_layered_test_graph_with_greedy_switch_off()
  with_partitions.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [elk_layered_test_graph_property("PARTITIONS")],
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let partition_algorithm_length = elk_layered_test_algorithm_length(
    with_partitions,
  )
  assert_eq(partition_algorithm_length, baseline_algorithm_length + 3)
}

///|
test "elk layered adds wrapping processors for multi-edge wrapping strategy" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let multi_edge_wrapping = elk_layered_test_graph_with_greedy_switch_off()
  multi_edge_wrapping.set_property_string(
    layered_options_wrapping_strategy, "MULTI_EDGE",
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let wrapping_algorithm_length = elk_layered_test_algorithm_length(
    multi_edge_wrapping,
  )
  assert_eq(wrapping_algorithm_length, baseline_algorithm_length + 3)
}

///|
test "elk layered adds constraints postprocessor when @core.interactive layout is enabled" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let interactive_graph = elk_layered_test_graph_with_greedy_switch_off()
  interactive_graph.set_property_bool(@core.interactive, true)

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let interactive_algorithm_length = elk_layered_test_algorithm_length(
    interactive_graph,
  )
  assert_eq(interactive_algorithm_length, baseline_algorithm_length + 1)
}

///|
test "elk layered adds constraints postprocessor when generate-position-and-layer-ids is enabled" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let generate_ids_graph = elk_layered_test_graph_with_greedy_switch_off()
  generate_ids_graph.set_property_bool(
    layered_options_generate_position_and_layer_ids, true,
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let generate_ids_algorithm_length = elk_layered_test_algorithm_length(
    generate_ids_graph,
  )
  assert_eq(generate_ids_algorithm_length, baseline_algorithm_length + 1)
}

///|
test "elk layered adds label management processors when label manager exists" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let with_label_manager = elk_layered_test_graph_with_greedy_switch_off()
  with_label_manager.set_property_i_label_manager(
    @core.label_management_options_label_manager,
    Some(elk_layered_test_label_manager()),
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let label_management_algorithm_length = elk_layered_test_algorithm_length(
    with_label_manager,
  )
  assert_eq(label_management_algorithm_length, baseline_algorithm_length + 2)
}

///|
test "elk layered adds hierarchical node resizer for include-children hierarchy" {
  let baseline = elk_layered_test_graph_with_greedy_switch_off()
  let hierarchical = elk_layered_test_graph_with_greedy_switch_off()
  hierarchical.set_property_string(
    layered_options_hierarchy_handling, "INCLUDE_CHILDREN",
  )

  let baseline_algorithm_length = elk_layered_test_algorithm_length(baseline)
  let hierarchical_algorithm_length = elk_layered_test_algorithm_length(
    hierarchical,
  )
  assert_eq(hierarchical_algorithm_length, baseline_algorithm_length + 1)
}
