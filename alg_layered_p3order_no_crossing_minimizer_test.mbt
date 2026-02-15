///|
fn no_crossing_test_node_ids(nodes : Array[LNode]) -> Array[Int] {
  let ids = []
  for node in nodes {
    ids.push(node.get_id())
  }
  ids
}

///|
fn no_crossing_test_factory_ids(
  factories : Array[ILayoutProcessorFactory[LayeredPhases, LGraph]],
) -> Array[Int] {
  let ids = []
  for factory in factories {
    ids.push(factory.factory_id())
  }
  ids
}

///|
test "NoCrossingMinimizer process leaves node order untouched" {
  let creator = new_test_graph_creator()
  let graph = creator.get_graph()
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(graph))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  creator.set_up_ids()

  let before = creator.get_current_order(graph)
  let before_ids = no_crossing_test_node_ids(before[1])

  let phase = new_no_crossing_minimizer_layout_phase()
  phase.process(graph, None)

  let after = creator.get_current_order(graph)
  let after_ids = no_crossing_test_node_ids(after[1])
  assert_eq(after_ids, before_ids)
}

///|
test "NoCrossingMinimizer configuration matches upstream processor slots" {
  let graph = new_l_graph()
  let phase = new_no_crossing_minimizer_layout_phase()
  let configuration = match phase.get_layout_processor_configuration(graph) {
    Some(value) => value
    None => abort("no-crossing configuration must exist")
  }
  let phase_constants = layered_phase_constants()
  let p3_node_ordering = phase_constants[2]
  let p4_node_placement = phase_constants[3]
  let p5_edge_routing = phase_constants[4]

  assert_eq(
    no_crossing_test_factory_ids(
      configuration.processors_before(p3_node_ordering),
    ),
    [23016, 23019],
  )
  assert_eq(
    no_crossing_test_factory_ids(
      configuration.processors_before(p4_node_placement),
    ),
    [23028],
  )
  assert_eq(
    no_crossing_test_factory_ids(
      configuration.processors_after(p5_edge_routing),
    ),
    [23046],
  )
}
