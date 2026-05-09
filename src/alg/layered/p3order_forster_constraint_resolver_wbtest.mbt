///|
fn forster_test_new_node(
  layer : Layer,
  id : Int,
  node_type : NodeType,
) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn forster_test_node_ids(nodes : Array[LNode]) -> Array[Int] {
  let ids = []
  for node in nodes {
    ids.push(node.get_id())
  }
  ids
}

///|
fn forster_test_state_of(
  resolver : ForsterConstraintResolver,
  node : LNode,
) -> BarycenterState {
  let layer = match node.get_layer() {
    Some(layer) => layer
    None => abort("node must be attached to a layer")
  }
  match resolver.get_barycenter_states()[layer.get_id()][node.get_id()] {
    Some(state) => state
    None => abort("barycenter state is not initialized")
  }
}

///|
fn forster_test_set_barycenter(
  resolver : ForsterConstraintResolver,
  node : LNode,
  value : Double,
) -> Unit {
  resolver.set_barycenter(node, Some(value))
}

///|
fn forster_test_new_initialized_resolver(
  node_order : Array[Array[LNode]],
) -> ForsterConstraintResolver {
  let resolver = new_forster_constraint_resolver(node_order)
  i_initializable_init([resolver.as_initializable()], node_order)
  resolver
}

///|
test "ForsterConstraintResolver enforces in-layer successor constraints" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = forster_test_new_node(layer, 0, NodeType::Normal)
  let n1 = forster_test_new_node(layer, 1, NodeType::Normal)
  n0.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
    [n1],
  )

  let order = [[n0, n1]]
  let resolver = forster_test_new_initialized_resolver(order)

  forster_test_set_barycenter(resolver, n1, 0.0)
  forster_test_set_barycenter(resolver, n0, 1.0)

  let nodes = [n1, n0]
  resolver.process_constraints(nodes)

  inspect(forster_test_node_ids(nodes), content="[0, 1]")
  debug_inspect(
    forster_test_state_of(resolver, n0).barycenter,
    content="Some(0.5)",
  )
  debug_inspect(
    forster_test_state_of(resolver, n1).barycenter,
    content="Some(0.5)",
  )
}

///|
test "ForsterConstraintResolver keeps layout units non-overlapping" {
  let graph = new_l_graph()
  graph.set_property_bool(
    internal_properties_in_layer_successor_constraints_between_non_dummies, true,
  )
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let a = forster_test_new_node(layer, 0, NodeType::Normal)
  let b = forster_test_new_node(layer, 1, NodeType::Normal)
  let a_dummy = forster_test_new_node(layer, 2, NodeType::NorthSouthPort)
  let b_dummy = forster_test_new_node(layer, 3, NodeType::NorthSouthPort)

  a.set_property_l_node(internal_properties_in_layer_layout_unit, Some(a))
  a_dummy.set_property_l_node(internal_properties_in_layer_layout_unit, Some(a))
  b.set_property_l_node(internal_properties_in_layer_layout_unit, Some(b))
  b_dummy.set_property_l_node(internal_properties_in_layer_layout_unit, Some(b))

  let order = [[a, b, a_dummy, b_dummy]]
  let resolver = forster_test_new_initialized_resolver(order)

  forster_test_set_barycenter(resolver, a, 0.0)
  forster_test_set_barycenter(resolver, b, 1.0)
  forster_test_set_barycenter(resolver, a_dummy, 2.0)
  forster_test_set_barycenter(resolver, b_dummy, 3.0)

  let nodes = [a, b, a_dummy, b_dummy]
  resolver.process_constraints(nodes)

  inspect(forster_test_node_ids(nodes), content="[0, 2, 1, 3]")
}
