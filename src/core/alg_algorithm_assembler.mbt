///|
priv suberror AlgorithmAssemblerException {
  AlgorithmAssemblerException(String)
} derive(Debug, ToJson)

///|
fn algorithm_assembler_raise(
  message : String,
) -> Unit raise AlgorithmAssemblerException {
  raise AlgorithmAssemblerException(message)
}

///|
fn algorithm_assembler_exception_message(
  err : AlgorithmAssemblerException,
) -> String {
  match err {
    AlgorithmAssemblerException(message) => message
  }
}

///|
/// Non-generic pipeline scheduler for graph-bound runnable processors.
pub(all) struct AlgorithmAssembler {
  mut enable_caching : Bool
  mut fail_on_missing_phase : Bool
  mut processor_comparator : (LayoutProcessorFactory, LayoutProcessorFactory) -> Int
  phase_descriptor : PhaseDescriptor
  number_of_phases : Int
  configured_phases : Array[Bool]
  phase_accessor : AbstractRandomListAccessor[LayoutProcessorFactory?]
  additional_processors : LayoutProcessorConfiguration
  cache : Array[(Int, &RunnableLayoutProcessor)]
}

///|
fn none_phase_factory() -> LayoutProcessorFactory? {
  None
}

///|
pub fn algorithm_assembler_create(
  phase_descriptor : PhaseDescriptor,
) -> AlgorithmAssembler raise {
  let number_of_phases = phase_descriptor.size()
  if number_of_phases == 0 {
    try
      algorithm_assembler_raise(
        "There must be at least one phase in the phase enumeration.",
      )
    catch {
      err =>
        layout_runtime_raise_unsupported_configuration(
          algorithm_assembler_exception_message(err),
        )
    } noraise {
      _ => ()
    }
  }
  if phase_descriptor.validation_error() is Some(message) {
    layout_runtime_raise_unsupported_configuration(message)
  }
  {
    enable_caching: true,
    fail_on_missing_phase: true,
    processor_comparator: enum_based_factory_compare,
    phase_descriptor,
    number_of_phases,
    configured_phases: make_bool_array(number_of_phases),
    phase_accessor: new_abstract_random_list_accessor(none_phase_factory),
    additional_processors: layout_processor_configuration_create(),
    cache: [],
  }
}

///|
fn make_bool_array(length : Int) -> Array[Bool] {
  [
    for _ in 0..<length => false
  ]
}

///|
pub fn AlgorithmAssembler::with_caching(
  self : AlgorithmAssembler,
  enabled : Bool,
) -> AlgorithmAssembler {
  self.enable_caching = enabled
  self
}

///|
pub fn AlgorithmAssembler::with_fail_on_missing_phase(
  self : AlgorithmAssembler,
  fail : Bool,
) -> AlgorithmAssembler {
  self.fail_on_missing_phase = fail
  self
}

///|
pub fn AlgorithmAssembler::with_processor_comparator(
  self : AlgorithmAssembler,
  comparator : (LayoutProcessorFactory, LayoutProcessorFactory) -> Int,
) -> AlgorithmAssembler {
  self.processor_comparator = comparator
  self
}

///|
pub fn AlgorithmAssembler::clear_cache(
  self : AlgorithmAssembler,
) -> AlgorithmAssembler {
  self.cache.clear()
  self
}

///|
pub fn AlgorithmAssembler::reset(
  self : AlgorithmAssembler,
) -> AlgorithmAssembler {
  self.phase_accessor.clear_list()
  for i in 0..<self.configured_phases.length() {
    self.configured_phases[i] = false
  }
  ignore(self.additional_processors.clear())
  self.cache.clear()
  self
}

///|
pub fn AlgorithmAssembler::set_phase(
  self : AlgorithmAssembler,
  phase : PhaseId,
  phase_factory : LayoutProcessorFactory,
) -> AlgorithmAssembler raise {
  if phase < 0 || phase >= self.number_of_phases {
    layout_runtime_raise_unsupported_configuration(
      "Phase \{phase} is outside the descriptor range 0..<\{self.number_of_phases}.",
    )
    return self
  }
  let index = phase
  self.phase_accessor.set_list_item(index, Some(phase_factory))
  self.configured_phases[index] = true
  self
}

///|
pub fn AlgorithmAssembler::add_processor_configuration(
  self : AlgorithmAssembler,
  config : LayoutProcessorConfiguration,
) -> AlgorithmAssembler raise {
  ignore(self.additional_processors.add_all(config))
  self
}

///|
pub fn AlgorithmAssembler::build(
  self : AlgorithmAssembler,
) -> LayoutProcessorPlan raise {
  if self.fail_on_missing_phase &&
    self.count_configured_phases() < self.number_of_phases {
    try
      algorithm_assembler_raise(
        "Expected \{self.number_of_phases} phases to be configured; only found \{self.count_configured_phases()}",
      )
    catch {
      err =>
        layout_runtime_raise_unsupported_configuration(
          algorithm_assembler_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return new_layout_processor_plan([])
  }
  let phases = self.phase_descriptor.phases()
  let phase_implementations : Array[&RunnableLayoutProcessor?] = []
  for phase in phases {
    match self.phase_accessor.get_list_item(phase) {
      Some(factory) =>
        phase_implementations.push(Some(self.retrieve_phase(factory)))
      None => phase_implementations.push(None)
    }
  }
  let processor_configuration = layout_processor_configuration_create()
  for phase in phase_implementations {
    if phase is Some(phase_impl) {
      if phase_impl.get_layout_processor_configuration() is Some(config) {
        ignore(processor_configuration.add_all(config))
      }
    }
  }
  ignore(processor_configuration.add_all(self.additional_processors))
  let algorithm : Array[&RunnableLayoutProcessor] = []
  for phase in phases {
    append_processors(
      algorithm,
      self.retrieve_processors(processor_configuration.processors_before(phase)),
    )
    if phase_implementations[phase] is Some(phase_implementation) {
      algorithm.push(phase_implementation)
    }
  }
  if phases is [.., last_phase] {
    append_processors(
      algorithm,
      self.retrieve_processors(
        processor_configuration.processors_after(last_phase),
      ),
    )
  }
  new_layout_processor_plan(algorithm)
}

///|
fn append_processors(
  target : Array[&RunnableLayoutProcessor],
  source : Array[&RunnableLayoutProcessor],
) -> Unit {
  for processor in source {
    target.push(processor)
  }
}

///|
pub fn AlgorithmAssembler::count_configured_phases(
  self : AlgorithmAssembler,
) -> Int {
  self.configured_phases.fold(init=0, (count, configured) => {
    if configured {
      count + 1
    } else {
      count
    }
  })
}

///|
pub fn AlgorithmAssembler::retrieve_processors(
  self : AlgorithmAssembler,
  factories : Array[LayoutProcessorFactory],
) -> Array[&RunnableLayoutProcessor] raise {
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
fn sort_processor_factories(
  factories : Array[LayoutProcessorFactory],
  comparator : (LayoutProcessorFactory, LayoutProcessorFactory) -> Int,
) -> Array[LayoutProcessorFactory] {
  let sorted = factories.copy()
  for i in 1..<sorted.length() {
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
pub fn AlgorithmAssembler::retrieve_phase(
  self : AlgorithmAssembler,
  factory : LayoutProcessorFactory,
) -> &RunnableLayoutProcessor raise {
  self.retrieve_processor(factory)
}

///|
pub fn AlgorithmAssembler::retrieve_processor(
  self : AlgorithmAssembler,
  factory : LayoutProcessorFactory,
) -> &RunnableLayoutProcessor raise {
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
fn find_cached_processor(
  cache : Array[(Int, &RunnableLayoutProcessor)],
  factory_id : Int,
) -> &RunnableLayoutProcessor? {
  for entry in cache {
    let (cached_id, processor) = entry
    if cached_id == factory_id {
      return Some(processor)
    }
  }
  None
}
