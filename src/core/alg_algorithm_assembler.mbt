///|
pub(all) struct AlgorithmAssembler[P, G] {
  mut enable_caching : Bool
  mut fail_on_missing_phase : Bool
  mut processor_comparator : (
    ILayoutProcessorFactory[P, G],
    ILayoutProcessorFactory[P, G],
  ) -> Int
  phase_descriptor : PhaseDescriptor[P]
  number_of_phases : Int
  configured_phases : Array[Bool]
  phase_accessor : AbstractRandomListAccessor[ILayoutPhaseFactory[P, G]?]
  additional_processors : LayoutProcessorConfiguration[P, G]
  cache : Array[(Int, ILayoutProcessor[P, G])]
}

///|
fn[P, G] none_phase_factory() -> ILayoutPhaseFactory[P, G]? {
  None
}

///|
pub fn[P, G] algorithm_assembler_create(
  phase_descriptor : PhaseDescriptor[P],
) -> AlgorithmAssembler[P, G] {
  let number_of_phases = phase_descriptor.size()
  if number_of_phases == 0 {
    abort("There must be at least one phase in the phase enumeration.")
  }
  {
    enable_caching: true,
    fail_on_missing_phase: true,
    processor_comparator: enum_based_factory_compare,
    phase_descriptor,
    number_of_phases,
    configured_phases: make_bool_array(number_of_phases),
    phase_accessor: new_abstract_random_list_accessor(none_phase_factory),
    additional_processors: layout_processor_configuration_create(
      phase_descriptor,
    ),
    cache: [],
  }
}

///|
fn make_bool_array(length : Int) -> Array[Bool] {
  let array = []
  let mut i = 0
  while i < length {
    array.push(false)
    i += 1
  }
  array
}

///|
pub fn[P, G] AlgorithmAssembler::with_caching(
  self : AlgorithmAssembler[P, G],
  enabled : Bool,
) -> AlgorithmAssembler[P, G] {
  self.enable_caching = enabled
  self
}

///|
pub fn[P, G] AlgorithmAssembler::with_fail_on_missing_phase(
  self : AlgorithmAssembler[P, G],
  fail : Bool,
) -> AlgorithmAssembler[P, G] {
  self.fail_on_missing_phase = fail
  self
}

///|
pub fn[P, G] AlgorithmAssembler::with_processor_comparator(
  self : AlgorithmAssembler[P, G],
  comparator : (ILayoutProcessorFactory[P, G], ILayoutProcessorFactory[P, G]) -> Int,
) -> AlgorithmAssembler[P, G] {
  self.processor_comparator = comparator
  self
}

///|
pub fn[P, G] AlgorithmAssembler::clear_cache(
  self : AlgorithmAssembler[P, G],
) -> AlgorithmAssembler[P, G] {
  self.cache.clear()
  self
}

///|
pub fn[P, G] AlgorithmAssembler::reset(
  self : AlgorithmAssembler[P, G],
) -> AlgorithmAssembler[P, G] {
  self.phase_accessor.clear_list()
  for i = 0; i < self.configured_phases.length(); i = i + 1 {
    self.configured_phases[i] = false
  }
  ignore(self.additional_processors.clear())
  self
}

///|
pub fn[P, G] AlgorithmAssembler::set_phase(
  self : AlgorithmAssembler[P, G],
  phase : P,
  phase_factory : ILayoutPhaseFactory[P, G],
) -> AlgorithmAssembler[P, G] {
  let index = self.phase_descriptor.ordinal_of(phase)
  self.phase_accessor.set_list_item(index, Some(phase_factory))
  self.configured_phases[index] = true
  self
}

///|
pub fn[P, G] AlgorithmAssembler::add_processor_configuration(
  self : AlgorithmAssembler[P, G],
  config : LayoutProcessorConfiguration[P, G],
) -> AlgorithmAssembler[P, G] {
  ignore(self.additional_processors.add_all(config))
  self
}

///|
pub fn[P, G] AlgorithmAssembler::build(
  self : AlgorithmAssembler[P, G],
  graph : G,
) -> Array[ILayoutProcessor[P, G]] {
  if self.fail_on_missing_phase &&
    self.count_configured_phases() < self.number_of_phases {
    abort(
      "Expected \{self.number_of_phases} phases to be configured; only found \{self.count_configured_phases()}",
    )
  }
  let phase_enum_constants = self.phase_descriptor.phases()
  let phase_implementations = []
  for phase in phase_enum_constants {
    let index = self.phase_descriptor.ordinal_of(phase)
    match self.phase_accessor.get_list_item(index) {
      Some(factory) =>
        phase_implementations.push(Some(self.retrieve_phase(factory)))
      None => phase_implementations.push(None)
    }
  }
  let processor_configuration = layout_processor_configuration_create(
    self.phase_descriptor,
  )
  for phase in phase_implementations {
    if phase is Some(phase_impl) {
      if phase_impl.get_layout_processor_configuration(graph) is Some(config) {
        ignore(processor_configuration.add_all(config))
      }
    }
  }
  ignore(processor_configuration.add_all(self.additional_processors))
  let algorithm = []
  for phase in phase_enum_constants {
    append_processors(
      algorithm,
      self.retrieve_processors(processor_configuration.processors_before(phase)),
    )
    let index = self.phase_descriptor.ordinal_of(phase)
    if phase_implementations[index] is Some(phase_implementation) {
      algorithm.push(phase_implementation)
    }
  }
  if phase_enum_constants.length() > 0 {
    let last_phase = phase_enum_constants[phase_enum_constants.length() - 1]
    append_processors(
      algorithm,
      self.retrieve_processors(
        processor_configuration.processors_after(last_phase),
      ),
    )
  }
  algorithm
}

///|
fn[P, G] append_processors(
  target : Array[ILayoutProcessor[P, G]],
  source : Array[ILayoutProcessor[P, G]],
) -> Unit {
  for processor in source {
    target.push(processor)
  }
}

///|
pub fn[P, G] AlgorithmAssembler::count_configured_phases(
  self : AlgorithmAssembler[P, G],
) -> Int {
  let mut count = 0
  for configured in self.configured_phases {
    if configured {
      count += 1
    }
  }
  count
}

///|
pub fn[P, G] AlgorithmAssembler::retrieve_processors(
  self : AlgorithmAssembler[P, G],
  factories : Array[ILayoutProcessorFactory[P, G]],
) -> Array[ILayoutProcessor[P, G]] {
  let processors = []
  let sorted_factories = sort_processor_factories(
    factories,
    self.processor_comparator,
  )
  for factory in sorted_factories {
    processors.push(self.retrieve_processor(factory))
  }
  processors
}

///|
fn[P, G] sort_processor_factories(
  factories : Array[ILayoutProcessorFactory[P, G]],
  comparator : (ILayoutProcessorFactory[P, G], ILayoutProcessorFactory[P, G]) -> Int,
) -> Array[ILayoutProcessorFactory[P, G]] {
  let sorted = factories.copy()
  for i = 1; i < sorted.length(); i = i + 1 {
    let mut j = i
    while j > 0 && comparator(sorted[j - 1], sorted[j]) > 0 {
      let previous = sorted[j - 1]
      sorted[j - 1] = sorted[j]
      sorted[j] = previous
      j = j - 1
    }
  }
  sorted
}

///|
pub fn[P, G] AlgorithmAssembler::retrieve_phase(
  self : AlgorithmAssembler[P, G],
  factory : ILayoutPhaseFactory[P, G],
) -> ILayoutProcessor[P, G] {
  self.retrieve_processor(factory)
}

///|
pub fn[P, G] AlgorithmAssembler::retrieve_processor(
  self : AlgorithmAssembler[P, G],
  factory : ILayoutProcessorFactory[P, G],
) -> ILayoutProcessor[P, G] {
  if self.enable_caching {
    if find_cached_processor(self.cache, factory.factory_id())
      is Some(processor) {
      processor
    } else {
      let processor = factory.create()
      self.cache.push((factory.factory_id(), processor))
      processor
    }
  } else {
    factory.create()
  }
}

///|
fn[P, G] find_cached_processor(
  cache : Array[(Int, ILayoutProcessor[P, G])],
  factory_id : Int,
) -> ILayoutProcessor[P, G]? {
  for entry in cache {
    let (cached_id, processor) = entry
    if cached_id == factory_id {
      return Some(processor)
    }
  }
  None
}
