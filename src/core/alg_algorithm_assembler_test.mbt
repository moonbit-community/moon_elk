///|
test "AlgorithmAssembler testEnableCaching" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  let graph = Some(new_string_buffer())
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1, graph~)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2, graph~)))
  let algorithm = assembler.build()
  assert_eq(count_layout_phases(algorithm), 2)
  let algorithm2 = assembler.build()
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_eq(
      algorithm.steps()[i].instance_id(),
      algorithm2.steps()[i].instance_id(),
    )
  }
}

///|
test "AlgorithmAssembler testDisableCaching" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  let graph = Some(new_string_buffer())
  ignore(assembler.with_caching(false))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1, graph~)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2, graph~)))
  let algorithm = assembler.build()
  assert_eq(count_layout_phases(algorithm), 2)
  let algorithm2 = assembler.build()
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_true(
      algorithm.steps()[i].instance_id() != algorithm2.steps()[i].instance_id(),
    )
  }
}

///|
test "AlgorithmAssembler testFailOnMissingPhase reports runtime error" {
  let error = capture_layout_error(fn() raise {
    let assembler = algorithm_assembler_create(test_phase_descriptor)
    ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
    ignore(assembler.build())
  })
  assert_eq(
    error,
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
  assert_true(assembler.build().length() > 0)
}

///|
test "AlgorithmAssembler testClearCache" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  ignore(assembler.with_caching(true))
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
  let algorithm = assembler.build()
  assert_eq(count_layout_phases(algorithm), 2)
  ignore(assembler.clear_cache())
  let algorithm2 = assembler.build()
  assert_eq(count_layout_phases(algorithm2), 2)
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_true(
      algorithm.steps()[i].instance_id() != algorithm2.steps()[i].instance_id(),
    )
  }
}

///|
test "AlgorithmAssembler testResetWithFailOnMissingPhase reports runtime error" {
  let error = capture_layout_error(fn() raise {
    let assembler = algorithm_assembler_create(test_phase_descriptor)
    ignore(assembler.with_fail_on_missing_phase(true))
    ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1)))
    ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2)))
    ignore(assembler.reset())
    ignore(assembler.build())
  })
  assert_eq(
    error,
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
  assert_eq(assembler.build().length(), 0)
}

///|
test "AlgorithmAssembler testAddProcessorConfiguration" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  let buffer = new_string_buffer()
  let graph = Some(buffer)
  ignore(
    assembler.add_processor_configuration(
      layout_processor_configuration_create().add_before(
        Phase1,
        test_processor_factory(Processor3, graph~),
      ),
    ),
  )
  ignore(assembler.set_phase(Phase1, test_phase_factory(Phase1, graph~)))
  ignore(assembler.set_phase(Phase2, test_phase_factory(Phase2, graph~)))
  let algorithm = assembler.build()
  let expected_strings = [
    "PROCESSOR_1", "PROCESSOR_3", "PHASE_1", "PROCESSOR_2", "PHASE_2",
  ]
  for i = 0; i < algorithm.length(); i = i + 1 {
    assert_eq(
      run_processor_step(algorithm.steps()[i], buffer),
      expected_strings[i],
    )
  }
}

///|
test "AlgorithmAssembler rejects invalid phase descriptors" {
  let sparse_error = capture_layout_error(fn() raise {
    ignore(algorithm_assembler_create(new_phase_descriptor([0, 10])))
  })
  assert_eq(
    sparse_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase descriptor must contain consecutive zero-based ordinals in declaration order; expected phase 1, found 10.",
    ),
  )
  let negative_error = capture_layout_error(fn() raise {
    ignore(algorithm_assembler_create(new_phase_descriptor([-1, 0])))
  })
  assert_eq(
    negative_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase descriptor must contain consecutive zero-based ordinals in declaration order; expected phase 0, found -1.",
    ),
  )
  let duplicate_error = capture_layout_error(fn() raise {
    ignore(algorithm_assembler_create(new_phase_descriptor([0, 0])))
  })
  assert_eq(
    duplicate_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase descriptor must contain consecutive zero-based ordinals in declaration order; expected phase 1, found 0.",
    ),
  )
  let reordered_error = capture_layout_error(fn() raise {
    ignore(algorithm_assembler_create(new_phase_descriptor([1, 0])))
  })
  assert_eq(
    reordered_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase descriptor must contain consecutive zero-based ordinals in declaration order; expected phase 0, found 1.",
    ),
  )
}

///|
test "AlgorithmAssembler rejects phases outside its descriptor" {
  let assembler = algorithm_assembler_create(test_phase_descriptor)
  let high_error = capture_layout_error(fn() raise {
    ignore(assembler.set_phase(10, test_phase_factory(Phase1)))
  })
  assert_eq(
    high_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase 10 is outside the descriptor range 0..<2.",
    ),
  )
  let negative_error = capture_layout_error(fn() raise {
    ignore(assembler.set_phase(-1, test_phase_factory(Phase1)))
  })
  assert_eq(
    negative_error,
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Phase -1 is outside the descriptor range 0..<2.",
    ),
  )
}
