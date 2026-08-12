///|
fn edge_router_factory_test_routing(name : String) -> @core.EdgeRouting {
  for strategy in @core.edge_routing_values() {
    if @core.edge_routing_to_string(strategy) == name {
      return strategy
    }
  }
  abort("unknown edge routing strategy")
}

///|
fn edge_router_factory_test_run(strategy : @core.EdgeRouting) -> String raise {
  let factory = edge_router_factory_factory_for(
    @runtime.new_l_graph(),
    strategy,
  )
  let processor = factory.create()
  if !processor.is_layout_phase() {
    abort("expected layout phase")
  }

  let monitor = new_elk_progress_monitor()
  processor.run(Some(monitor))
  monitor.get_task_name()
}

///|
test "edge router factory dispatches to orthogonal by default" {
  inspect(
    edge_router_factory_test_run(edge_router_factory_test_routing("UNDEFINED")),
    content="Orthogonal edge routing",
  )
  inspect(
    edge_router_factory_test_run(edge_router_factory_test_routing("ORTHOGONAL")),
    content="Orthogonal edge routing",
  )
}

///|
test "edge router factory dispatches to polyline and spline" {
  inspect(
    edge_router_factory_test_run(edge_router_factory_test_routing("POLYLINE")),
    content="Polyline edge routing",
  )
  inspect(
    edge_router_factory_test_run(edge_router_factory_test_routing("SPLINES")),
    content="Spline edge routing",
  )
}

///|
test "edge router factory ids are stable by strategy" {
  let polyline = edge_router_factory_test_routing("POLYLINE")
  let orthogonal = edge_router_factory_test_routing("ORTHOGONAL")
  let poly_a = edge_router_factory_factory_for(@runtime.new_l_graph(), polyline)
  let poly_b = edge_router_factory_factory_for(@runtime.new_l_graph(), polyline)
  let orth = edge_router_factory_factory_for(@runtime.new_l_graph(), orthogonal)

  assert_eq(poly_a.factory_id(), poly_b.factory_id())
  assert_true(poly_a.factory_id() != orth.factory_id())
}
