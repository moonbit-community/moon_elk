///|
priv suberror LayoutProcessorConfigurationException {
  LayoutProcessorConfigurationException(String)
} derive(Debug, ToJson)

///|
fn layout_processor_configuration_raise(
  message : String,
) -> Unit raise LayoutProcessorConfigurationException {
  raise LayoutProcessorConfigurationException(message)
}

///|
fn layout_processor_configuration_exception_message(
  err : LayoutProcessorConfigurationException,
) -> String {
  match err {
    LayoutProcessorConfigurationException(message) => message
  }
}

///|
/// Non-generic placement of graph-bound processor factories around phases.
pub(all) struct LayoutProcessorConfiguration {
  list_accessor : AbstractRandomListAccessor[Array[LayoutProcessorFactory]]
  mut current_index : Int
}

///|
fn empty_processor_factory_slot() -> Array[LayoutProcessorFactory] {
  []
}

///|
pub fn layout_processor_configuration_create() -> LayoutProcessorConfiguration {
  {
    list_accessor: new_abstract_random_list_accessor(
      empty_processor_factory_slot,
    ),
    current_index: -1,
  }
}

///|
pub fn layout_processor_configuration_create_from(
  source : LayoutProcessorConfiguration,
) -> LayoutProcessorConfiguration raise {
  layout_processor_configuration_create().add_all(source)
}

///|
pub fn LayoutProcessorConfiguration::clear(
  self : LayoutProcessorConfiguration,
) -> LayoutProcessorConfiguration {
  self.list_accessor.clear_list()
  self.current_index = -1
  self
}

///|
pub fn LayoutProcessorConfiguration::before(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
) -> LayoutProcessorConfiguration {
  self.current_index = phase
  self
}

///|
pub fn LayoutProcessorConfiguration::after(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
) -> LayoutProcessorConfiguration {
  self.current_index = phase + 1
  self
}

///|
pub fn LayoutProcessorConfiguration::add(
  self : LayoutProcessorConfiguration,
  processor : LayoutProcessorFactory,
) -> LayoutProcessorConfiguration raise {
  if self.current_index < 0 {
    try
      layout_processor_configuration_raise(
        "Did not call before(...) or after(...) before calling add(...).",
      )
    catch {
      err =>
        layout_runtime_raise_unsupported_configuration(
          layout_processor_configuration_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return self
  }
  self.do_add(self.current_index, processor)
  self
}

///|
pub fn LayoutProcessorConfiguration::add_before(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
  processor : LayoutProcessorFactory,
) -> LayoutProcessorConfiguration raise {
  self.current_index = -1
  self.do_add(phase, processor)
  self
}

///|
pub fn LayoutProcessorConfiguration::add_after(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
  processor : LayoutProcessorFactory,
) -> LayoutProcessorConfiguration raise {
  self.current_index = -1
  self.do_add(phase + 1, processor)
  self
}

///|
pub fn LayoutProcessorConfiguration::do_add(
  self : LayoutProcessorConfiguration,
  index : Int,
  processor : LayoutProcessorFactory,
) -> Unit raise {
  let slot = self.list_accessor.get_list_item(index)
  if !slot_contains_processor_factory(slot, processor) {
    slot.push(processor)
  }
}

///|
fn slot_contains_processor_factory(
  slot : Array[LayoutProcessorFactory],
  processor : LayoutProcessorFactory,
) -> Bool {
  for existing in slot {
    if existing.factory_id() == processor.factory_id() {
      return true
    }
  }
  false
}

///|
pub fn LayoutProcessorConfiguration::add_all(
  self : LayoutProcessorConfiguration,
  configuration : LayoutProcessorConfiguration,
) -> LayoutProcessorConfiguration raise {
  for i in 0..<configuration.list_accessor.get_list_size() {
    for processor in configuration.list_accessor.get_list_item(i) {
      self.do_add(i, processor)
    }
  }
  self
}

///|
pub fn LayoutProcessorConfiguration::processors_before(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
) -> Array[LayoutProcessorFactory] raise {
  self.processors(phase)
}

///|
pub fn LayoutProcessorConfiguration::processors_after(
  self : LayoutProcessorConfiguration,
  phase : PhaseId,
) -> Array[LayoutProcessorFactory] raise {
  self.processors(phase + 1)
}

///|
pub fn LayoutProcessorConfiguration::processors(
  self : LayoutProcessorConfiguration,
  index : Int,
) -> Array[LayoutProcessorFactory] raise {
  self.list_accessor.get_list_item(index).copy()
}
