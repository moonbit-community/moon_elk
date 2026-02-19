///|
let compound_graph_postprocessor_test_cross_hierarchy_map : @graph.IProperty[
  Array[(LEdge, (LEdge, LGraph, PortType))],
] = @graph.new_property("crossHierarchyMap", [])

///|
let compound_graph_postprocessor_test_original_label_edge : @graph.IProperty[
  LEdge?,
] = @graph.new_property("originalLabelEdge", None)

///|
let compound_graph_postprocessor_test_target_offset : @graph.IProperty[
  @core.KVector,
] = @graph.new_property("targetOffset", @core.new_kvector())

///|
fn compound_graph_postprocessor_test_west() -> @core.PortSide {
  @core.port_side_values()[4]
}

///|
fn compound_graph_postprocessor_test_east() -> @core.PortSide {
  @core.port_side_values()[2]
}

///|
fn compound_graph_postprocessor_test_port_type_input() -> PortType {
  port_type_values()[1]
}

///|
fn compound_graph_postprocessor_test_port_type_output() -> PortType {
  port_type_values()[2]
}

///|
fn compound_graph_postprocessor_test_add_node(
  graph : LGraph,
  x : Double,
  y : Double,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  ignore(node.get_position().set_xy(x, y))
  node
}

///|
fn compound_graph_postprocessor_test_add_port(
  node : LNode,
  side : @core.PortSide,
  x : Double,
  y : Double,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  ignore(port.get_position().set_xy(x, y))
  port
}

///|
fn compound_graph_postprocessor_test_add_edge(
  source : LPort,
  target : LPort,
) -> LEdge {
  let edge = new_l_edge()
  edge.set_source(Some(source))
  edge.set_target(Some(target))
  edge
}

///|
test "compound graph postprocessor reports expected task name" {
  let processor = new_compound_graph_postprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Compound graph postprocessor")
}

///|
test "compound graph postprocessor restores cross-hierarchy edges and copies geometry" {
  let graph = new_l_graph()
  graph.set_property_bool(layered_options_unnecessary_bendpoints, false)

  let source_node = compound_graph_postprocessor_test_add_node(graph, 0.0, 0.0)
  let middle_node = compound_graph_postprocessor_test_add_node(graph, 20.0, 0.0)
  let target_node = compound_graph_postprocessor_test_add_node(graph, 40.0, 0.0)

  let source_port = compound_graph_postprocessor_test_add_port(
    source_node,
    compound_graph_postprocessor_test_east(),
    10.0,
    0.0,
  )
  let middle_input = compound_graph_postprocessor_test_add_port(
    middle_node,
    compound_graph_postprocessor_test_west(),
    0.0,
    0.0,
  )
  let middle_output = compound_graph_postprocessor_test_add_port(
    middle_node,
    compound_graph_postprocessor_test_east(),
    0.0,
    0.0,
  )
  let target_port = compound_graph_postprocessor_test_add_port(
    target_node,
    compound_graph_postprocessor_test_west(),
    0.0,
    0.0,
  )

  let orig_edge = new_l_edge()
  let existing_junction_points = @core.new_kvector_chain()
  existing_junction_points.add_xy(99.0, 99.0)
  orig_edge.set_property_kvector_chain(
    layered_options_junction_points, existing_junction_points,
  )

  let first_segment = compound_graph_postprocessor_test_add_edge(
    source_port, middle_input,
  )
  first_segment.get_bend_points().add_xy(15.0, 5.0)
  let first_segment_junction_points = @core.new_kvector_chain()
  first_segment_junction_points.add_xy(16.0, 6.0)
  first_segment.set_property_kvector_chain(
    layered_options_junction_points, first_segment_junction_points,
  )

  let second_segment = compound_graph_postprocessor_test_add_edge(
    middle_output, target_port,
  )
  second_segment.get_bend_points().add_xy(30.0, 8.0)
  let moved_label = new_l_label_text("moved")
  ignore(moved_label.get_position().set_xy(31.0, 9.0))
  moved_label.set_property_l_edge(
    compound_graph_postprocessor_test_original_label_edge,
    Some(orig_edge),
  )
  second_segment.get_labels().push(moved_label)

  graph.set_property_cross_hierarchy_map_entry_array(
    compound_graph_postprocessor_test_cross_hierarchy_map,
    [
      (
        orig_edge,
        (
          second_segment,
          graph,
          compound_graph_postprocessor_test_port_type_input(),
        ),
      ),
      (
        orig_edge,
        (
          first_segment,
          graph,
          compound_graph_postprocessor_test_port_type_output(),
        ),
      ),
    ],
  )

  let processor = new_compound_graph_postprocessor_layout_processor()
  processor.process(graph, None)

  match orig_edge.get_source() {
    Some(port) => assert_eq(port.get_handle(), source_port.get_handle())
    None => abort("missing restored source")
  }
  match orig_edge.get_target() {
    Some(port) => assert_eq(port.get_handle(), target_port.get_handle())
    None => abort("missing restored target")
  }

  let bend_points = orig_edge.get_bend_points()
  assert_eq(bend_points.size(), 3)
  assert_true((bend_points.get(0).x - 15.0).abs() < 0.0001)
  assert_true((bend_points.get(0).y - 5.0).abs() < 0.0001)
  assert_true((bend_points.get(1).x - 20.0).abs() < 0.0001)
  assert_true((bend_points.get(1).y - 0.0).abs() < 0.0001)
  assert_true((bend_points.get(2).x - 30.0).abs() < 0.0001)
  assert_true((bend_points.get(2).y - 8.0).abs() < 0.0001)

  assert_true(
    orig_edge.has_property_kvector_chain(layered_options_junction_points),
  )
  let copied_junction_points = orig_edge.get_property_kvector_chain(
    layered_options_junction_points,
  )
  assert_eq(copied_junction_points.size(), 1)
  assert_true((copied_junction_points.get(0).x - 16.0).abs() < 0.0001)
  assert_true((copied_junction_points.get(0).y - 6.0).abs() < 0.0001)

  assert_eq(orig_edge.get_labels().length(), 1)
  assert_eq(orig_edge.get_labels()[0].get_text(), "moved")
  assert_eq(second_segment.get_labels().length(), 0)

  assert_true(
    orig_edge.has_property_kvector(
      compound_graph_postprocessor_test_target_offset,
    ),
  )
  let target_offset = orig_edge.get_property_kvector(
    compound_graph_postprocessor_test_target_offset,
  )
  assert_true(target_offset.x.abs() < 0.0001)
  assert_true(target_offset.y.abs() < 0.0001)

  assert_true(first_segment.get_source() is None)
  assert_true(first_segment.get_target() is None)
  assert_true(second_segment.get_source() is None)
  assert_true(second_segment.get_target() is None)
}

///|
test "compound graph postprocessor removes original junction points if segments have none" {
  let graph = new_l_graph()
  let source_node = compound_graph_postprocessor_test_add_node(graph, 0.0, 0.0)
  let target_node = compound_graph_postprocessor_test_add_node(graph, 40.0, 0.0)
  let source_port = compound_graph_postprocessor_test_add_port(
    source_node,
    compound_graph_postprocessor_test_east(),
    10.0,
    0.0,
  )
  let target_port = compound_graph_postprocessor_test_add_port(
    target_node,
    compound_graph_postprocessor_test_west(),
    0.0,
    0.0,
  )

  let orig_edge = new_l_edge()
  let old_junction_points = @core.new_kvector_chain()
  old_junction_points.add_xy(1.0, 1.0)
  orig_edge.set_property_kvector_chain(
    layered_options_junction_points, old_junction_points,
  )

  let segment = compound_graph_postprocessor_test_add_edge(
    source_port, target_port,
  )
  graph.set_property_cross_hierarchy_map_entry_array(
    compound_graph_postprocessor_test_cross_hierarchy_map,
    [
      (
        orig_edge,
        (segment, graph, compound_graph_postprocessor_test_port_type_output()),
      ),
    ],
  )

  let processor = new_compound_graph_postprocessor_layout_processor()
  processor.process(graph, None)

  assert_true(
    !orig_edge.has_property_kvector_chain(layered_options_junction_points),
  )
}
