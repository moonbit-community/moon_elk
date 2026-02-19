///|
fn basic_cross_min_record_layer_assignment(graph : LGraph) -> Map[Int, Int] {
  let assignment = {}
  for layer in graph.get_layers() {
    let layer_id = layer.get_id()
    for node in layer.get_nodes() {
      assignment[node.get_handle()] = layer_id
    }
  }
  assignment
}

///|
fn basic_cross_min_verify_layer_assignment(
  graph : LGraph,
  assignment : Map[Int, Int],
) -> Unit {
  for layer in graph.get_layers() {
    let layer_id = layer.get_id()
    for node in layer.get_nodes() {
      let node_handle = node.get_handle()
      let expected = match assignment.get(node_handle) {
        Some(value) => value
        None => abort("missing layer assignment for node")
      }
      if layer_id != expected {
        abort("node moved to a different layer")
      }
    }
  }
}

///|
test "LayerSweep crossing minimization keeps layer assignment on simple graph" {
  let creator = new_test_graph_creator()
  let graph = creator.get_cross_formed_graph()
  let assignment = basic_cross_min_record_layer_assignment(graph)

  let cross_min = new_layer_sweep_crossing_minimizer(
    cross_min_type_constants()[0],
  )
  cross_min.process(graph, progress_monitor=Some(new_basic_progress_monitor()))

  basic_cross_min_verify_layer_assignment(graph, assignment)
}

///|
test "LayerSweep crossing minimization keeps layer assignment on hierarchical graph" {
  let creator = new_test_graph_creator()
  let root = creator.get_graph()

  let parent = creator.add_node_to_layer(creator.make_layer(root))
  let nested = creator.nested_graph(parent)
  let left_nodes = creator.add_nodes_to_layer(2, creator.make_layer(nested))
  let right_nodes = creator.add_nodes_to_layer(2, creator.make_layer(nested))
  creator.east_west_edge_from_to_nodes(left_nodes[0], right_nodes[1])
  creator.east_west_edge_from_to_nodes(left_nodes[1], right_nodes[0])
  creator.set_up_ids()

  let assignment = basic_cross_min_record_layer_assignment(nested)

  let cross_min = new_layer_sweep_crossing_minimizer(
    cross_min_type_constants()[0],
  )
  cross_min.process(root, progress_monitor=Some(new_basic_progress_monitor()))

  basic_cross_min_verify_layer_assignment(nested, assignment)
}
