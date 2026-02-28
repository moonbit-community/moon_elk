///|
test "AlgorithmAssembler testEnableCaching" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  let algorithm = assembler.build(None)
  assert_eq(count_layout_phases(algorithm), 2)
  let algorithm2 = assembler.build(None)
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_eq(algorithm[i].instance_id(), algorithm2[i].instance_id())
  }
}

///|
test "AlgorithmAssembler testDisableCaching" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_caching(false))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  let algorithm = assembler.build(None)
  assert_eq(count_layout_phases(algorithm), 2)
  let algorithm2 = assembler.build(None)
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_true(algorithm[i].instance_id() != algorithm2[i].instance_id())
  }
}

///|
test "AlgorithmAssembler testFailOnMissingPhase reports runtime error" {
  @core.layout_runtime_clear_error()
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.build(None))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Expected 2 phases to be configured; only found 1",
    ),
  )
}

///|
test "AlgorithmAssembler testDontFailOnMissingPhase" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_fail_on_missing_phase(false))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  assert_true(assembler.build(None).length() > 0)
}

///|
test "AlgorithmAssembler testClearCache" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_caching(true))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  let algorithm = assembler.build(None)
  assert_eq(count_layout_phases(algorithm), 2)
  ignore(assembler.clear_cache())
  let algorithm2 = assembler.build(None)
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_true(algorithm[i].instance_id() != algorithm2[i].instance_id())
  }
}

///|
test "AlgorithmAssembler testResetWithFailOnMissingPhase reports runtime error" {
  @core.layout_runtime_clear_error()
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_fail_on_missing_phase(true))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  ignore(assembler.reset())
  ignore(assembler.build(None))
  assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Expected 2 phases to be configured; only found 0",
    ),
  )
}

///|
test "AlgorithmAssembler testResetWithoutFailOnMissingPhase" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_fail_on_missing_phase(false))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  ignore(assembler.reset())
  assert_eq(assembler.build(None).length(), 0)
}

///|
test "AlgorithmAssembler testAddProcessorConfiguration" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(
    assembler.add_processor_configuration(
      layout_processor_configuration_create(test_phase_descriptor).add_before(
        Phase1,
        test_processor_factory(Processor3),
      ),
    ),
  )
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  let algorithm = assembler.build(None)
  let expected_strings = [
    "PROCESSOR_1", "PROCESSOR_3", "PHASE_1", "PROCESSOR_2", "PHASE_2",
  ]
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_eq(run_processor_step(algorithm[i]), expected_strings[i])
  }
}
