///|
fn core_service_test_reset_environment() -> LayoutConnectorsService {
  layout_connectors_service_unload()
  reset_layout_listener_ids_for_test()
  reset_graph_model_for_test()
  layout_connectors_service_get_instance()
}

///|
fn core_service_test_make_connector(
  id : String,
  events : Array[String],
) -> IDiagramLayoutConnector {
  new_diagram_layout_connector(
    id~,
    build_layout_graph_fn=(_workbench_part, diagram_part) => {
      events.push("build")
      let graph = create_graph()
      let mapping = new_layout_mapping_with_graph(None, diagram_part, graph)
      match diagram_part {
        Some(diagram_element) =>
          mapping.put_graph_mapping(graph, diagram_element)
        None => ()
      }
      Some(mapping)
    },
    apply_layout_fn=(_mapping, _settings) => events.push("apply"),
  )
}

///|
fn core_service_test_make_setup(
  workbench_id : Int,
  diagram_id : Int,
  connector : IDiagramLayoutConnector,
  setup_tag : String,
  graph_layout_engine? : IGraphLayoutEngine? = None,
) -> ILayoutSetup {
  new_layout_setup(
    obj => {
      match obj {
        WorkbenchPartObject(value) => value == workbench_id
        DiagramPartObject(value) => value == diagram_id
        _ => false
      }
    },
    default_module => {
      let injector = default_module.copy()
      injector.set_connector(Some(connector))
      injector.set_binding("setupTag", setup_tag)
      match graph_layout_engine {
        Some(engine) => injector.set_graph_layout_engine(Some(engine))
        None => ()
      }
      injector
    },
  )
}

///|
test "LayoutConnectorsService selects setup by priority" {
  let service = core_service_test_reset_environment()
  service.clear_setups_for_test()
  service.clear_listeners_for_test()

  let low_events : Array[String] = []
  let high_events : Array[String] = []
  let low_setup = core_service_test_make_setup(
    1,
    2,
    core_service_test_make_connector("low", low_events),
    "low",
  )
  let high_setup = core_service_test_make_setup(
    1,
    2,
    core_service_test_make_connector("high", high_events),
    "high",
  )

  service.register_setup(low_setup, priority=1)
  service.register_setup(high_setup, priority=10)

  inspect(service.registered_priorities_for_test(), content="[10, 1]")
  inspect(
    match service.get_injector(Some(1), Some(2)) {
      Some(injector) => injector.binding_of("setupTag")
      None => None
    },
    content="Some(\"high\")",
  )
}

///|
test "DiagramLayoutEngine invoke flow calls connector build layout and apply" {
  let service = core_service_test_reset_environment()
  service.clear_setups_for_test()
  service.clear_listeners_for_test()

  let events : Array[String] = []
  let connector = core_service_test_make_connector("flow", events)
  let graph_layout_engine = new_graph_layout_engine((_layout_graph, _monitor) => {
    events.push("layout")
  })
  let setup = core_service_test_make_setup(
    7,
    9,
    connector,
    "flow",
    graph_layout_engine=Some(graph_layout_engine),
  )
  service.register_setup(setup, priority=1)

  let mapping = diagram_layout_engine_invoke_layout(Some(7), Some(9))
  inspect(events, content="[\"build\", \"layout\", \"apply\"]")
  inspect(
    match mapping {
      Some(actual_mapping) => actual_mapping.get_status()
      None => None
    },
    content="Some(OkStatus)",
  )
}

///|
test "Layout listeners receive about-to-start and done callbacks" {
  let service = core_service_test_reset_environment()
  service.clear_setups_for_test()
  service.clear_listeners_for_test()

  let connector_events : Array[String] = []
  let listener_events : Array[String] = []
  let connector = core_service_test_make_connector("listener", connector_events)
  let setup = core_service_test_make_setup(11, 12, connector, "listener")
  service.register_setup(setup, priority=1)
  service.add_layout_listener(
    new_layout_listener(
      layout_about_to_start_fn=(_mapping, _progress_monitor) => {
        listener_events.push("about")
      },
      layout_done_fn=(_mapping, _progress_monitor) => {
        listener_events.push("done")
      },
    ),
  )

  ignore(diagram_layout_engine_invoke_layout(Some(11), Some(12)))
  inspect(listener_events, content="[\"about\", \"done\"]")
}

///|
test "LayoutMapping stores graph-to-diagram and diagram-to-graph associations" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))
  let mapping = new_layout_mapping(workbench_part=Some(42))
  mapping.set_layout_graph(Some(root))
  mapping.set_parent_element(Some(99))
  mapping.put_graph_mapping(root, 1000)
  mapping.put_graph_mapping(child, 1001)

  inspect(mapping.get_diagram_element(root), content="Some(1000)")
  inspect(mapping.get_graph_element(1001), content="Some(\{child})")
  inspect(mapping.graph_map_size(), content="2")
  inspect(mapping.get_parent_element(), content="Some(99)")
  inspect(mapping.get_workbench_part(), content="Some(42)")
}

///|
test "CompoundGraphElementVisitor supports element-first and full-graph-first modes" {
  reset_graph_model_for_test()
  let root = create_graph()
  let child = create_node(Some(root))

  let element_first_events : Array[String] = []
  let element_first = new_compound_graph_element_visitor(visitors=[
    new_graph_element_visitor(node => element_first_events.push("v1:\{node}")),
    new_graph_element_visitor(node => element_first_events.push("v2:\{node}")),
  ])
  element_first.visit(root)
  element_first.visit(child)
  assert_eq(element_first_events, [
    "v1:\{root}",
    "v2:\{root}",
    "v1:\{child}",
    "v2:\{child}",
  ])

  let full_graph_first_events : Array[String] = []
  let full_graph_first = new_compound_graph_element_visitor_with_mode(true, visitors=[
    new_graph_element_visitor(node => full_graph_first_events.push("v1:\{node}")),
    new_graph_element_visitor(node => full_graph_first_events.push("v2:\{node}")),
  ])
  full_graph_first.visit(root)
  full_graph_first.visit(child)
  assert_eq(full_graph_first_events, [
    "v1:\{root}",
    "v1:\{child}",
    "v2:\{root}",
    "v2:\{child}",
  ])
}

///|
test "MonitoredOperation supports basic run and cancellation" {
  reset_monitored_operation_timestamp_for_test()
  let run_events : Array[String] = []
  let operation = new_monitored_operation(
    _monitor => {
      run_events.push("execute")
      monitored_operation_status_ok()
    },
    pre_uiexec_fn=() => run_events.push("pre"),
    post_uiexec_fn=() => run_events.push("post"),
  )
  inspect(operation.run_monitored(), content="OperationOk")
  inspect(run_events, content="[\"pre\", \"execute\", \"post\"]")
  inspect(operation.get_timestamp() > 0, content="true")

  let cancel_events : Array[String] = []
  let canceled_operation = new_monitored_operation(
    _monitor => {
      cancel_events.push("execute")
      monitored_operation_status_ok()
    },
    pre_uiexec_fn=() => cancel_events.push("pre"),
    post_uiexec_fn=() => cancel_events.push("post"),
  )
  canceled_operation.cancel()
  inspect(canceled_operation.run_unmonitored(), content="OperationCanceled")
  inspect(cancel_events, content="[\"pre\"]")
}
