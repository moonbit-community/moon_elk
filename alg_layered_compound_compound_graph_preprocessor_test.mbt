///|
let compound_graph_preprocessor_test_cross_hierarchy_map : IProperty[
  Array[(LEdge, (LEdge, LGraph, PortType))],
] = new_property("crossHierarchyMap", [])

///|
let compound_graph_preprocessor_test_original_label_edge : IProperty[LEdge?] = new_property(
  "originalLabelEdge",
  None,
)

///|
let compound_graph_preprocessor_test_inside_self_loops_yo : IProperty[Bool] = new_property(
  "org.eclipse.elk.insideSelfLoops.yo", false,
)

///|
fn compound_graph_preprocessor_test_port_type_output() -> PortType {
  port_type_values()[2]
}

///|
fn compound_graph_preprocessor_test_node_type_normal() -> NodeType {
  node_type_values()[0]
}

///|
fn compound_graph_preprocessor_test_port_constraints(
  name : String,
) -> PortConstraints {
  for value in port_constraints_values() {
    if port_constraints_to_string(value) == name {
      return value
    }
  }
  abort("unknown port constraints")
}

///|
fn compound_graph_preprocessor_test_graph_property(
  name : String,
) -> GraphProperties {
  for value in graph_properties_values() {
    if graph_properties_to_string(value) == name {
      return value
    }
  }
  abort("unknown graph property")
}

///|
fn compound_graph_preprocessor_test_graph_has_property(
  graph : LGraph,
  property : GraphProperties,
) -> Bool {
  let expected_name = graph_properties_to_string(property)
  for
    current in graph.get_property_graph_properties_array(
      internal_properties_graph_properties,
    ) {
    if graph_properties_to_string(current) == expected_name {
      return true
    }
  }
  false
}

///|
fn compound_graph_preprocessor_test_add_node(
  graph : LGraph,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_type(node_type)
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn compound_graph_preprocessor_test_add_port(
  node : LNode,
  side : PortSide,
) -> LPort {
  let port = new_l_port()
  port.set_side(side)
  port.set_node(Some(node))
  port
}

///|
fn compound_graph_preprocessor_test_port_side_west() -> PortSide {
  port_side_values()[4]
}

///|
fn compound_graph_preprocessor_test_port_side_east() -> PortSide {
  port_side_values()[2]
}

///|
test "compound graph preprocessor reports expected task name" {
  let processor = new_compound_graph_preprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Compound graph preprocessor")
}

///|
test "compound graph preprocessor splits child-to-parent edge and records cross hierarchy map" {
  let top_graph = new_l_graph()
  top_graph.set_property_string(
    port_constraints,
    port_constraints_to_string(
      compound_graph_preprocessor_test_port_constraints("UNDEFINED"),
    ),
  )

  let parent_node = compound_graph_preprocessor_test_add_node(
    top_graph,
    compound_graph_preprocessor_test_node_type_normal(),
  )
  parent_node.set_property_string(
    port_constraints,
    port_constraints_to_string(
      compound_graph_preprocessor_test_port_constraints("UNDEFINED"),
    ),
  )

  let nested_graph = new_l_graph()
  nested_graph.set_parent_node(Some(parent_node))
  parent_node.set_nested_graph(Some(nested_graph))

  let parent_port = compound_graph_preprocessor_test_add_port(
    parent_node,
    compound_graph_preprocessor_test_port_side_west(),
  )
  let inner_node = compound_graph_preprocessor_test_add_node(
    nested_graph,
    compound_graph_preprocessor_test_node_type_normal(),
  )
  let inner_port = compound_graph_preprocessor_test_add_port(
    inner_node,
    compound_graph_preprocessor_test_port_side_east(),
  )

  let orig_edge = new_l_edge()
  orig_edge.set_source(Some(inner_port))
  orig_edge.set_target(Some(parent_port))

  let label = new_l_label_text("head")
  label.set_property_string(edge_labels_placement, "HEAD")
  orig_edge.get_labels().push(label)

  let processor = new_compound_graph_preprocessor_layout_processor()
  processor.process(top_graph, None)

  assert_true(orig_edge.get_source() is None)
  assert_true(orig_edge.get_target() is None)

  let entries = top_graph.get_property_cross_hierarchy_map_entry_array(
    compound_graph_preprocessor_test_cross_hierarchy_map,
  )
  assert_eq(entries.length(), 1)
  let (mapped_orig_edge, (segment_edge, _segment_graph, segment_type)) = entries[0]
  assert_eq(mapped_orig_edge.get_handle(), orig_edge.get_handle())
  match segment_type {
    Output => ()
    _ => abort("unexpected segment port type")
  }

  assert_eq(segment_edge.get_labels().length(), 1)
  assert_eq(segment_edge.get_labels()[0].get_text(), "head")
  assert_eq(orig_edge.get_labels().length(), 0)
  match
    segment_edge.get_labels()[0].get_property_l_edge(
      compound_graph_preprocessor_test_original_label_edge,
    ) {
    Some(label_edge) =>
      assert_eq(label_edge.get_handle(), orig_edge.get_handle())
    None => abort("missing original label edge marker")
  }

  assert_true(parent_port.has_property_l_node(internal_properties_port_dummy))
  assert_eq(
    parent_node.get_property_string(port_constraints),
    port_constraints_to_string(
      compound_graph_preprocessor_test_port_constraints("FIXED_SIDE"),
    ),
  )
  assert_true(
    compound_graph_preprocessor_test_graph_has_property(
      top_graph,
      compound_graph_preprocessor_test_graph_property("NON_FREE_PORTS"),
    ),
  )
}

///|
test "compound graph preprocessor transforms inside self loop to external port dummy edge" {
  let top_graph = new_l_graph()
  let parent_node = compound_graph_preprocessor_test_add_node(
    top_graph,
    compound_graph_preprocessor_test_node_type_normal(),
  )
  parent_node.set_property_bool(inside_self_loops_activate, true)

  let nested_graph = new_l_graph()
  nested_graph.set_parent_node(Some(parent_node))
  parent_node.set_nested_graph(Some(nested_graph))

  let parent_port = compound_graph_preprocessor_test_add_port(
    parent_node,
    compound_graph_preprocessor_test_port_side_east(),
  )

  let self_loop = new_l_edge()
  self_loop.set_source(Some(parent_port))
  self_loop.set_target(Some(parent_port))
  self_loop.set_property_bool(
    compound_graph_preprocessor_test_inside_self_loops_yo, true,
  )

  let processor = new_compound_graph_preprocessor_layout_processor()
  processor.process(top_graph, None)

  assert_true(self_loop.get_source() is None)
  assert_true(self_loop.get_target() is None)

  let entries = top_graph.get_property_cross_hierarchy_map_entry_array(
    compound_graph_preprocessor_test_cross_hierarchy_map,
  )
  assert_eq(entries.length(), 1)
  let (_, (_, mapped_graph, mapped_type)) = entries[0]
  match mapped_type {
    Output => ()
    _ => abort("inside self loop must map to output segment")
  }

  assert_true(
    compound_graph_preprocessor_test_graph_has_property(
      mapped_graph,
      compound_graph_preprocessor_test_graph_property("EXTERNAL_PORTS"),
    ),
  )
  let mut has_external_port_dummy = false
  for node in mapped_graph.get_layerless_nodes() {
    match node.get_type() {
      NodeType::ExternalPort => {
        has_external_port_dummy = true
        break
      }
      _ => ()
    }
  }
  assert_true(has_external_port_dummy)
}
