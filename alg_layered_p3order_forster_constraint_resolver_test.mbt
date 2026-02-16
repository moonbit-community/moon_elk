///|
fn forster_bb_contains_node(nodes : Array[LNode], candidate : LNode) -> Bool {
  for node in nodes {
    if node.get_handle() == candidate.get_handle() {
      return true
    }
  }
  false
}

///|
fn forster_bb_new_node(layer : Layer, id : Int, node_type : NodeType) -> LNode {
  let node = new_l_node()
  node.set_layer(Some(layer))
  node.set_id(id)
  node.set_type(node_type)
  node
}

///|
fn forster_bb_node_type_normal() -> NodeType {
  node_type_values()[0]
}

///|
fn forster_bb_node_type_north_south_port() -> NodeType {
  node_type_values()[3]
}

///|
fn forster_bb_assert_non_overlapping_layout_units(graph : LGraph) -> Unit {
  for layer in graph.get_layers() {
    let encountered_layout_units = []
    let mut current_layout_unit : LNode? = None

    for node in layer.get_nodes() {
      match node.get_property_l_node(internal_properties_in_layer_layout_unit) {
        Some(new_layout_unit) => {
          let changed_layout_unit = match current_layout_unit {
            Some(unit) => unit.get_handle() != new_layout_unit.get_handle()
            None => true
          }

          if changed_layout_unit {
            if forster_bb_contains_node(
                encountered_layout_units, new_layout_unit,
              ) {
              abort("layout units overlap")
            }

            match current_layout_unit {
              Some(unit) => encountered_layout_units.push(unit)
              None => ()
            }
            current_layout_unit = Some(new_layout_unit)
          }
        }
        None => ()
      }
    }
  }
}

///|
test "ForsterConstraintResolver testSuccessorConstraints" {
  let graph = new_l_graph()
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let n0 = forster_bb_new_node(layer, 0, forster_bb_node_type_normal())
  let n1 = forster_bb_new_node(layer, 1, forster_bb_node_type_normal())
  n0.set_property_l_node_array(
    internal_properties_in_layer_successor_constraints,
    [n1],
  )

  let order = [[n0, n1]]
  let resolver = new_forster_constraint_resolver(order)
  i_initializable_init([resolver.as_initializable()], order)

  resolver.set_barycenter(n1, Some(0.0))
  resolver.set_barycenter(n0, Some(1.0))
  let nodes = [n1, n0]
  resolver.process_constraints(nodes)

  assert_eq(nodes[0].get_handle(), n0.get_handle())
  assert_eq(nodes[1].get_handle(), n1.get_handle())
}

///|
test "ForsterConstraintResolver testNonOverlappingLayoutUnits" {
  let graph = new_l_graph()
  graph.set_property_bool(
    internal_properties_in_layer_successor_constraints_between_non_dummies, true,
  )
  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let a = forster_bb_new_node(layer, 0, forster_bb_node_type_normal())
  let b = forster_bb_new_node(layer, 1, forster_bb_node_type_normal())
  let a_dummy = forster_bb_new_node(
    layer,
    2,
    forster_bb_node_type_north_south_port(),
  )
  let b_dummy = forster_bb_new_node(
    layer,
    3,
    forster_bb_node_type_north_south_port(),
  )

  a.set_property_l_node(internal_properties_in_layer_layout_unit, Some(a))
  a_dummy.set_property_l_node(internal_properties_in_layer_layout_unit, Some(a))
  b.set_property_l_node(internal_properties_in_layer_layout_unit, Some(b))
  b_dummy.set_property_l_node(internal_properties_in_layer_layout_unit, Some(b))

  let order = [[a, b, a_dummy, b_dummy]]
  let resolver = new_forster_constraint_resolver(order)
  i_initializable_init([resolver.as_initializable()], order)

  resolver.set_barycenter(a, Some(0.0))
  resolver.set_barycenter(b, Some(1.0))
  resolver.set_barycenter(a_dummy, Some(2.0))
  resolver.set_barycenter(b_dummy, Some(3.0))
  resolver.process_constraints(layer.get_nodes())

  forster_bb_assert_non_overlapping_layout_units(graph)
}
