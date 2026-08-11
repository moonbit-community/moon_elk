///|
pub(all) struct StringBuffer {
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
pub type TestPhases = PhaseId

///|
pub const Phase1 : TestPhases = 0

///|
pub const Phase2 : TestPhases = 1

///|
fn test_phase_label(phase : TestPhases) -> String {
  if phase == Phase1 {
    "PHASE_1"
  } else {
    "PHASE_2"
  }
}

///|
pub fn test_phase_ordinal(phase : TestPhases) -> Int {
  phase
}

///|
pub let test_phase_descriptor : PhaseDescriptor = new_phase_descriptor([
  Phase1,
  Phase2,
])

///|
pub(all) enum TestProcessors {
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
  graph? : StringBuffer? = None,
) -> LayoutProcessorFactory {
  let ordinal = test_processor_ordinal(processor)
  new_layout_processor_factory(10_000 + ordinal, ordinal, graph, () => {
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
  graph? : StringBuffer? = None,
) -> LayoutProcessorFactory {
  let ordinal = test_phase_ordinal(phase)
  new_layout_processor_factory(20_000 + ordinal, ordinal, graph, () => {
    new_layout_phase(
      (graph, progress_monitor) => {
        ignore(progress_monitor)
        if graph is Some(buffer) {
          buffer.append(test_phase_label(phase))
        }
      },
      _ => {
        let config = layout_processor_configuration_create()
        let phase_processor = if phase == Phase1 {
          Processor1
        } else {
          Processor2
        }
        ignore(
          config.add_before(
            phase,
            test_processor_factory(phase_processor, graph~),
          ),
        )
        Some(config)
      },
    )
  })
}

///|
pub fn count_layout_phases(algorithm : LayoutProcessorPlan) -> Int {
  let mut count = 0
  for processor in algorithm.steps() {
    if processor.is_layout_phase() {
      count += 1
    }
  }
  count
}

///|
pub fn run_processor_step(
  processor : &RunnableLayoutProcessor,
  buffer : StringBuffer,
) -> String raise {
  buffer.value = ""
  processor.run(None)
  buffer.to_string()
}
