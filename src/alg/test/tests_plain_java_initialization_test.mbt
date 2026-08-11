///|
fn tests_plain_java_initialization_test_setup() -> @core.OptionMetadata {
  let metadata = @core.new_option_metadata()
  plain_java_initialization_initialize_plain_java_layout(metadata)
  metadata
}

///|
fn tests_plain_java_initialization_default_configuration() -> TestConfiguration[
  Unit,
] {
  new_test_configuration(apply_base_configuration_fn=(
    _test_instance : Unit,
    _graph : ElkNode,
  ) => ())
}

///|
fn tests_plain_java_initialization_algorithms(
  metadata : @core.OptionMetadata,
) -> Array[TestAlgorithm] {
  let algorithm_ids = [
    "org.eclipse.elk.box", "org.eclipse.elk.disco", "org.eclipse.elk.fixed", "org.eclipse.elk.force",
    "org.eclipse.elk.layered", "org.eclipse.elk.mrtree", "org.eclipse.elk.radial",
    "org.eclipse.elk.random", rectpacking_algorithm_id, spore_compaction_algorithm_id,
    spore_overlap_removal_algorithm_id, "org.eclipse.elk.stress",
  ]
  let algorithms : Array[TestAlgorithm] = []
  for algorithm_id in algorithm_ids {
    match metadata.algorithm_data(algorithm_id) {
      Some(data) => algorithms.push(new_test_algorithm(Some(data)))
      None => abort("Unknown layout algorithm: " + algorithm_id)
    }
  }
  algorithms
}

///|
test "PlainJavaInitializationTest algorithm property is available for all expected algorithms" {
  let metadata = tests_plain_java_initialization_test_setup()

  let graph = new_test_graph(
    (_test_instance : Unit) => create_graph(),
    "graphMethod(basicGraph)",
  )
  let blackbox_test = new_blackbox_test_method("testAlgorithmPresent", (
    _test_instance : Unit,
    graph : ElkNode,
  ) => {
    if !node_has_string_property(graph, algorithm) {
      abort("Graph is expected to have CoreOptions.ALGORITHM.")
    }
  })

  let runner : LayoutTestRunner[Unit, Int] = new_layout_test_runner(
    () => (),
    tests_plain_java_initialization_algorithms(metadata),
    [tests_plain_java_initialization_default_configuration()],
    [graph],
    [blackbox_test],
    [],
  )
  let notifier = new_run_notifier()
  runner.run(notifier)

  assert_eq(notifier.test_failures().length(), 0)
  assert_eq(notifier.started_tests().length(), 12)
  assert_eq(notifier.finished_tests().length(), 12)
}
