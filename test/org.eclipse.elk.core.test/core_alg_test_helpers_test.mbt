///|
pub struct StringBuffer {
  mut value : String
}

///|
pub fn new_string_buffer() -> StringBuffer {
  { value: "" }
}

///|
pub fn StringBuffer::append(self : StringBuffer, text : String) -> Unit {
  self.value = self.value + text
}

///|
pub fn StringBuffer::to_string(self : StringBuffer) -> String {
  self.value
}

///|
pub enum TestPhases {
  Phase1
  Phase2
}

///|
fn test_phase_label(phase : TestPhases) -> String {
  match phase {
    Phase1 => "PHASE_1"
    Phase2 => "PHASE_2"
  }
}

///|
pub fn test_phase_ordinal(phase : TestPhases) -> Int {
  match phase {
    Phase1 => 0
    Phase2 => 1
  }
}

///|
pub let test_phase_descriptor : PhaseDescriptor[TestPhases] = new_phase_descriptor(
  [Phase1, Phase2],
  test_phase_ordinal,
)

///|
pub enum TestProcessors {
  Processor1
  Processor2
  Processor3
}

///|
fn test_processor_label(processor : TestProcessors) -> String {
  match processor {
    Processor1 => "PROCESSOR_1"
    Processor2 => "PROCESSOR_2"
    Processor3 => "PROCESSOR_3"
  }
}

///|
fn test_processor_ordinal(processor : TestProcessors) -> Int {
  match processor {
    Processor1 => 0
    Processor2 => 1
    Processor3 => 2
  }
}

///|
pub fn test_processor_factory(
  processor : TestProcessors,
) -> ILayoutProcessorFactory[TestPhases, StringBuffer?] {
  let ordinal = test_processor_ordinal(processor)
  new_layout_processor_factory(10_000 + ordinal, ordinal, () => {
    new_layout_processor((graph, progress_monitor) => {
      ignore(progress_monitor)
      if graph is Some(buffer) {
        buffer.append(test_processor_label(processor))
      }
    })
  })
}

///|
pub fn test_phase_factory(
  phase : TestPhases,
) -> ILayoutPhaseFactory[TestPhases, StringBuffer?] {
  let ordinal = test_phase_ordinal(phase)
  new_layout_processor_factory(20_000 + ordinal, ordinal, () => {
    new_layout_phase(
      (graph, progress_monitor) => {
        ignore(progress_monitor)
        if graph is Some(buffer) {
          buffer.append(test_phase_label(phase))
        }
      },
      _ => {
        let config = layout_processor_configuration_create(
          test_phase_descriptor,
        )
        let phase_processor = match phase {
          Phase1 => Processor1
          Phase2 => Processor2
        }
        ignore(
          config.add_before(phase, test_processor_factory(phase_processor)),
        )
        Some(config)
      },
    )
  })
}

///|
pub fn count_layout_phases(
  algorithm : Array[ILayoutProcessor[TestPhases, StringBuffer?]],
) -> Int {
  let mut count = 0
  for processor in algorithm {
    if processor.is_layout_phase() {
      count += 1
    }
  }
  count
}

///|
pub fn run_processor_step(
  processor : ILayoutProcessor[TestPhases, StringBuffer?],
) -> String {
  let buffer = new_string_buffer()
  processor.process(Some(buffer), None)
  buffer.to_string()
}
