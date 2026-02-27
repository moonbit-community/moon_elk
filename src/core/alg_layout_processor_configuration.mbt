///|
priv suberror LayoutProcessorConfigurationException {
  LayoutProcessorConfigurationException(String)
} derive(Show, ToJson)

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
pub(all) struct LayoutProcessorConfiguration[P, G] {
  phase_descriptor : PhaseDescriptor[P]
  list_accessor : AbstractRandomListAccessor[
    Array[ILayoutProcessorFactory[P, G]],
  ]
  mut current_index : Int
}

///|
fn[P, G] empty_processor_factory_slot() -> Array[ILayoutProcessorFactory[P, G]] {
  []
}

///|
pub fn[P, G] layout_processor_configuration_create(
  phase_descriptor : PhaseDescriptor[P],
) -> LayoutProcessorConfiguration[P, G] {
  {
    phase_descriptor,
    list_accessor: new_abstract_random_list_accessor(
      empty_processor_factory_slot,
    ),
    current_index: -1,
  }
}

///|
pub fn[P, G] layout_processor_configuration_create_from(
  source : LayoutProcessorConfiguration[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  layout_processor_configuration_create(source.phase_descriptor).add_all(source)
}

///|
pub fn[P, G] LayoutProcessorConfiguration::clear(
  self : LayoutProcessorConfiguration[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  self.list_accessor.clear_list()
  self.current_index = -1
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::before(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
) -> LayoutProcessorConfiguration[P, G] {
  self.current_index = self.phase_descriptor.ordinal_of(phase)
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::after(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
) -> LayoutProcessorConfiguration[P, G] {
  self.current_index = self.phase_descriptor.ordinal_of(phase) + 1
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::add(
  self : LayoutProcessorConfiguration[P, G],
  processor : ILayoutProcessorFactory[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  if self.current_index < 0 {
    try
      layout_processor_configuration_raise(
        "Did not call before(...) or after(...) before calling add(...).",
      )
    catch {
      err =>
        layout_runtime_report_unsupported_configuration(
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
pub fn[P, G] LayoutProcessorConfiguration::add_before(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
  processor : ILayoutProcessorFactory[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  self.current_index = -1
  self.do_add(self.phase_descriptor.ordinal_of(phase), processor)
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::add_after(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
  processor : ILayoutProcessorFactory[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  self.current_index = -1
  self.do_add(self.phase_descriptor.ordinal_of(phase) + 1, processor)
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::do_add(
  self : LayoutProcessorConfiguration[P, G],
  index : Int,
  processor : ILayoutProcessorFactory[P, G],
) -> Unit {
  let slot = self.list_accessor.get_list_item(index)
  if !slot_contains_processor_factory(slot, processor) {
    slot.push(processor)
  }
}

///|
fn[P, G] slot_contains_processor_factory(
  slot : Array[ILayoutProcessorFactory[P, G]],
  processor : ILayoutProcessorFactory[P, G],
) -> Bool {
  for existing in slot {
    if existing.factory_id() == processor.factory_id() {
      return true
    }
  }
  false
}

///|
pub fn[P, G] LayoutProcessorConfiguration::add_all(
  self : LayoutProcessorConfiguration[P, G],
  configuration : LayoutProcessorConfiguration[P, G],
) -> LayoutProcessorConfiguration[P, G] {
  for i = 0; i < configuration.list_accessor.get_list_size(); i = i + 1 {
    for processor in configuration.list_accessor.get_list_item(i) {
      self.do_add(i, processor)
    }
  }
  self
}

///|
pub fn[P, G] LayoutProcessorConfiguration::processors_before(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
) -> Array[ILayoutProcessorFactory[P, G]] {
  self.processors(self.phase_descriptor.ordinal_of(phase))
}

///|
pub fn[P, G] LayoutProcessorConfiguration::processors_after(
  self : LayoutProcessorConfiguration[P, G],
  phase : P,
) -> Array[ILayoutProcessorFactory[P, G]] {
  self.processors(self.phase_descriptor.ordinal_of(phase) + 1)
}

///|
pub fn[P, G] LayoutProcessorConfiguration::processors(
  self : LayoutProcessorConfiguration[P, G],
  index : Int,
) -> Array[ILayoutProcessorFactory[P, G]] {
  self.list_accessor.get_list_item(index).copy()
}
