///|
fn layered_components_test_new_graph(
  id : Int,
  width : Double,
  height : Double,
  connections : Array[@core.PortSide],
) -> LGraph {
  let graph = new_l_graph()
  graph.set_id(id)
  graph.set_size_xy(width, height)
  graph.set_property_port_side_array(
    internal_properties_ext_port_connections, connections,
  )
  graph.set_property_double(@core.spacing_component_component, 10.0)
  graph.set_property_double(@core.aspect_ratio, 10.0)
  graph
}

///|
fn layered_components_test_add_layerless_node(graph : LGraph) -> LNode {
  let node = new_l_node(graph=Some(graph))
  graph.get_layerless_nodes().push(node)
  node
}

///|
test "LayeredComponentsProcessor splits disconnected layerless nodes" {
  let graph = new_l_graph()
  ignore(layered_components_test_add_layerless_node(graph))
  ignore(layered_components_test_add_layerless_node(graph))

  let components = new_layered_components_processor().split(graph)
  assert_eq(components.length(), 2)
  assert_eq(components[0].get_layerless_nodes().length(), 1)
  assert_eq(components[1].get_layerless_nodes().length(), 1)
}

///|
test "LayeredComponentsProcessor does not split when external ports require fixed order" {
  let graph = new_l_graph()
  graph.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [GraphProperties::ExternalPorts],
  )
  graph.set_property_string(@core.port_constraints, "FIXED_ORDER")
  ignore(layered_components_test_add_layerless_node(graph))
  ignore(layered_components_test_add_layerless_node(graph))

  let components = new_layered_components_processor().split(graph)
  assert_eq(components.length(), 1)
  assert_eq(components[0].get_layerless_nodes().length(), 2)
}

///|
test "LayeredSimpleRowGraphPlacer places components into one row" {
  let target = new_l_graph()
  target.set_property_component_ordering_strategy(
    layered_options_consider_model_order_components,
    ComponentOrderingStrategy::ModelOrder,
  )

  let first = layered_components_test_new_graph(1, 30.0, 10.0, @core.sides_none)
  let second = layered_components_test_new_graph(
    2, 30.0, 10.0, @core.sides_none,
  )
  let third = layered_components_test_new_graph(3, 30.0, 10.0, @core.sides_none)

  new_layered_simple_row_graph_placer().combine([first, second, third], target)

  assert_eq(target.get_size().x, 110.0)
  assert_eq(target.get_size().y, 10.0)
  assert_eq(first.get_offset().x, 0.0)
  assert_eq(first.get_offset().y, 0.0)
  assert_eq(second.get_offset().x, 40.0)
  assert_eq(second.get_offset().y, 0.0)
  assert_eq(third.get_offset().x, 80.0)
  assert_eq(third.get_offset().y, 0.0)
}

///|
test "LayeredModelOrderRowGraphPlacer starts a new row for west connections" {
  let target = new_l_graph()
  let first = layered_components_test_new_graph(1, 20.0, 10.0, @core.sides_none)
  let second = layered_components_test_new_graph(
    2, 20.0, 10.0, @core.sides_north,
  )
  let third = layered_components_test_new_graph(3, 20.0, 10.0, @core.sides_west)

  new_layered_model_order_row_graph_placer().combine(
    [first, second, third],
    target,
  )

  assert_eq(first.get_offset().x, 0.0)
  assert_eq(first.get_offset().y, 0.0)
  assert_eq(second.get_offset().x, 30.0)
  assert_eq(second.get_offset().y, 0.0)
  assert_eq(third.get_offset().x, 0.0)
  assert_eq(third.get_offset().y, 20.0)
  assert_eq(target.get_size().x, 50.0)
  assert_eq(target.get_size().y, 30.0)
}

///|
test "LayeredComponentGroupGraphPlacer places incompatible groups diagonally" {
  let target = new_l_graph()
  let first = layered_components_test_new_graph(
    1, 20.0, 10.0, @core.sides_east_west,
  )
  let second = layered_components_test_new_graph(
    2, 20.0, 10.0, @core.sides_north_south,
  )

  new_layered_component_group_graph_placer().combine([first, second], target)

  assert_true(second.get_offset().x > 0.0)
  assert_true(second.get_offset().y > 0.0)
  assert_true(target.get_size().x > 0.0)
  assert_true(target.get_size().y > 0.0)
}

///|
test "LayeredComponentGroupModelOrderGraphPlacer honors horizontal model-order blocking" {
  let target = new_l_graph()
  let first = layered_components_test_new_graph(1, 20.0, 10.0, @core.sides_none)
  let second = layered_components_test_new_graph(
    2, 20.0, 10.0, @core.sides_north,
  )
  first.set_property_direction(
    layered_components_direction,
    @core.Direction::Rightward,
  )

  new_layered_component_group_model_order_graph_placer().combine(
    [first, second],
    target,
  )

  assert_true(second.get_offset().x > first.get_offset().x)
}

///|
test "LayeredComponentsProcessor picks model-order row placer for model-order strategy" {
  let config = new_l_graph()
  config.set_property_graph_properties_array(
    internal_properties_graph_properties,
    [GraphProperties::ExternalPorts],
  )
  config.set_property_component_ordering_strategy(
    layered_options_consider_model_order_components,
    ComponentOrderingStrategy::ModelOrder,
  )

  let processor = new_layered_components_processor()
  ignore(processor.split(config))

  let target = new_l_graph()
  let first = layered_components_test_new_graph(1, 20.0, 10.0, @core.sides_none)
  let second = layered_components_test_new_graph(
    2, 20.0, 10.0, @core.sides_west,
  )
  processor.combine([first, second], target)

  assert_true(second.get_offset().y > first.get_offset().y)
}

///|
test "LayeredComponentsCompactor normalizes overall bounds" {
  let left = layered_components_test_new_graph(1, 30.0, 10.0, @core.sides_none)
  left.set_offset_xy(10.0, 20.0)
  let right = layered_components_test_new_graph(2, 5.0, 5.0, @core.sides_none)
  right.set_offset_xy(-5.0, 15.0)

  let compactor = new_layered_components_compactor()
  compactor.compact([left, right], @core.new_kvector(), 10.0)

  assert_eq(compactor.get_offset().x, 5.0)
  assert_eq(compactor.get_offset().y, -15.0)
  assert_eq(compactor.get_graph_size().x, 45.0)
  assert_eq(compactor.get_graph_size().y, 15.0)
}
