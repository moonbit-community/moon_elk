///|
fn end_label_processor_test_strategy(
  name : String,
) -> IntermediateProcessorStrategy {
  for strategy in intermediate_processor_strategy_values() {
    if intermediate_processor_strategy_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown strategy")
}

///|
fn end_label_processor_test_port_side(name : String) -> @core.PortSide {
  for side in @core.port_side_values() {
    if @core.port_side_to_string(side) == name {
      return side
    }
  }
  abort("unknown port side")
}

///|
fn end_label_processor_test_build_graph(
  source_x : Double,
  source_y : Double,
) -> (LGraph, LNode, LPort, LNode, LPort, LEdge, LLabel) {
  let graph = new_l_graph()
  graph.set_property_double(@core.spacing_edge_label, 2.0)
  graph.set_property_double(@core.spacing_label_label, 1.0)
  graph.set_property_string(@core.direction, "RIGHT")

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let source = new_l_node(graph=Some(graph))
  source.set_layer(Some(layer))
  ignore(source.get_size().set_xy(40.0, 20.0))
  ignore(source.get_position().set_xy(source_x, source_y))

  let source_out = new_l_port()
  source_out.set_side(end_label_processor_test_port_side("EAST"))
  source_out.set_node(Some(source))
  ignore(source_out.get_position().set_xy(40.0, 10.0))

  let target = new_l_node(graph=Some(graph))
  target.set_layer(Some(layer))
  ignore(target.get_size().set_xy(30.0, 16.0))

  let target_in = new_l_port()
  target_in.set_side(end_label_processor_test_port_side("WEST"))
  target_in.set_node(Some(target))
  ignore(target_in.get_position().set_xy(0.0, 8.0))

  let edge = new_l_edge()
  edge.set_source(Some(source_out))
  edge.set_target(Some(target_in))
  edge.set_property_double(@core.edge_thickness, 3.0)

  let label = new_l_label_text("tail")
  ignore(label.get_size().set_xy(8.0, 4.0))
  label.set_property_string(@core.edge_labels_placement, "TAIL")
  edge.get_labels().push(label)

  (graph, source, source_out, target, target_in, edge, label)
}

///|
test "end label preprocessor reports expected task name" {
  let processor = new_end_label_preprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="End label pre-processing")
}

///|
test "end label preprocessor stores end label cells and updates margins" {
  let (graph, source, source_out, _target, _target_in, _edge, label) = end_label_processor_test_build_graph(
    0.0, 0.0,
  )

  let processor = new_end_label_preprocessor_layout_processor()
  processor.process(graph, None)

  assert_true(
    source.has_property_end_label_cell_array(internal_properties_end_labels),
  )
  let cells = source.get_property_end_label_cell_array(
    internal_properties_end_labels,
  )
  assert_eq(cells.length(), 1)

  let rect = cells[0].get_cell_rectangle()
  assert_eq(rect.width, 8.0)
  assert_eq(rect.height, 4.0)

  assert_true(
    source_out.has_property_double(internal_properties_max_edge_thickness),
  )
  assert_eq(
    source_out.get_property_double(internal_properties_max_edge_thickness),
    3.0,
  )
  assert_true(label.has_property_l_edge(internal_properties_end_label_edge))
  assert_true(source.get_margin().right > 0.0)
}

///|
test "end label postprocessor offsets and applies label positions then clears cells" {
  let (graph, source, _source_out, _target, _target_in, _edge, label) = end_label_processor_test_build_graph(
    100.0, 50.0,
  )

  let preprocessor = new_end_label_preprocessor_layout_processor()
  preprocessor.process(graph, None)

  let cells = source.get_property_end_label_cell_array(
    internal_properties_end_labels,
  )
  assert_eq(cells.length(), 1)
  let pre_rect = cells[0].get_cell_rectangle()
  let expected_x = source.get_position().x + pre_rect.x
  let expected_y = source.get_position().y + pre_rect.y

  let postprocessor = new_end_label_postprocessor_layout_processor()
  postprocessor.process(graph, None)

  assert_true(
    !source.has_property_end_label_cell_array(internal_properties_end_labels),
  )
  let label_pos = label.get_position()
  assert_true((label_pos.x - expected_x).abs() < 0.0001)
  assert_true((label_pos.y - expected_y).abs() < 0.0001)
}

///|
test "end label processor strategies create concrete processors" {
  let pre_factory = layered_intermediate_processor_factory(
    end_label_processor_test_strategy("END_LABEL_PREPROCESSOR"),
  )
  assert_eq(pre_factory.factory_id(), 23034)
  assert_eq(pre_factory.factory_order(), 34)
  let pre_processor = pre_factory.create()
  let pre_monitor = new_elk_progress_monitor()
  pre_processor.process(new_l_graph(), Some(pre_monitor))
  inspect(pre_monitor.get_task_name(), content="End label pre-processing")

  let post_factory = layered_intermediate_processor_factory(
    end_label_processor_test_strategy("END_LABEL_POSTPROCESSOR"),
  )
  assert_eq(post_factory.factory_id(), 23055)
  assert_eq(post_factory.factory_order(), 55)
  let post_processor = post_factory.create()
  let post_monitor = new_elk_progress_monitor()
  post_processor.process(new_l_graph(), Some(post_monitor))
  inspect(post_monitor.get_task_name(), content="End label post-processing")
}
