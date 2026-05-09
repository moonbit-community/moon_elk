///|
test "LayoutProcessorConfiguration testBefore" {
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(
    config
    .before(Phase1)
    .add(test_processor_factory(Processor1))
    .before(Phase2)
    .add(test_processor_factory(Processor2))
    .add(test_processor_factory(Processor3)),
  )
  @core_debug.assert_eq(config.processors_before(Phase1).length(), 1)
  @core_debug.assert_eq(config.processors_after(Phase1).length(), 2)
  @core_debug.assert_eq(config.processors_before(Phase2).length(), 2)
  @core_debug.assert_eq(config.processors_after(Phase2).length(), 0)
}

///|
test "LayoutProcessorConfiguration testAfter" {
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(
    config
    .after(Phase1)
    .add(test_processor_factory(Processor1))
    .after(Phase2)
    .add(test_processor_factory(Processor2))
    .add(test_processor_factory(Processor3)),
  )
  @core_debug.assert_eq(config.processors_before(Phase1).length(), 0)
  @core_debug.assert_eq(config.processors_after(Phase1).length(), 1)
  @core_debug.assert_eq(config.processors_before(Phase2).length(), 1)
  @core_debug.assert_eq(config.processors_after(Phase2).length(), 2)
}

///|
test "LayoutProcessorConfiguration testAddBefore1" {
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(config.before(Phase1))
  ignore(config.add_before(Phase2, test_processor_factory(Processor1)))
  @core_debug.assert_eq(config.processors_before(Phase1).length(), 0)
  @core_debug.assert_eq(config.processors_after(Phase1).length(), 1)
  @core_debug.assert_eq(config.processors_before(Phase2).length(), 1)
  @core_debug.assert_eq(config.processors_after(Phase2).length(), 0)
}

///|
test "LayoutProcessorConfiguration testAddBefore2 reports runtime error" {
  @core.layout_runtime_clear_error()
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(config.before(Phase1))
  ignore(config.add_before(Phase2, test_processor_factory(Processor1)))
  ignore(config.add(test_processor_factory(Processor2)))
  @core_debug.assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Did not call before(...) or after(...) before calling add(...).",
    ),
  )
}

///|
test "LayoutProcessorConfiguration testAddAfter1" {
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(config.before(Phase1))
  ignore(config.add_after(Phase1, test_processor_factory(Processor1)))
  @core_debug.assert_eq(config.processors_before(Phase1).length(), 0)
  @core_debug.assert_eq(config.processors_after(Phase1).length(), 1)
  @core_debug.assert_eq(config.processors_before(Phase2).length(), 1)
  @core_debug.assert_eq(config.processors_after(Phase2).length(), 0)
}

///|
test "LayoutProcessorConfiguration testAddAfter2 reports runtime error" {
  @core.layout_runtime_clear_error()
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(config.before(Phase1))
  ignore(config.add_after(Phase1, test_processor_factory(Processor1)))
  ignore(config.add(test_processor_factory(Processor2)))
  @core_debug.assert_eq(
    @core.layout_runtime_take_error_message(),
    Some(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Did not call before(...) or after(...) before calling add(...).",
    ),
  )
}

///|
test "LayoutProcessorConfiguration testAddAll" {
  let config = layout_processor_configuration_create(test_phase_descriptor)
  ignore(
    config
    .after(Phase1)
    .add(test_processor_factory(Processor1))
    .after(Phase2)
    .add(test_processor_factory(Processor2))
    .add(test_processor_factory(Processor3)),
  )
  let config2 = layout_processor_configuration_create(test_phase_descriptor)
  ignore(config2.add_all(config))
  @core_debug.assert_eq(config2.processors_before(Phase1).length(), 0)
  @core_debug.assert_eq(config2.processors_after(Phase1).length(), 1)
  @core_debug.assert_eq(config2.processors_before(Phase2).length(), 1)
  @core_debug.assert_eq(config2.processors_after(Phase2).length(), 2)
}
