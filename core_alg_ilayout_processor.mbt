///|
let next_layout_processor_id_ref : Ref[Int] = Ref::new(0)

///|
fn next_layout_processor_id() -> Int {
  let id = next_layout_processor_id_ref.val
  next_layout_processor_id_ref.val = id + 1
  id
}

///|
pub struct ILayoutProcessor[P, G] {
  id : Int
  process_fn : (G, IElkProgressMonitor?) -> Unit
  is_phase : Bool
  is_hierarchy_aware : Bool
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration[
    P,
    G,
  ]?
}

///|
pub fn[P, G] new_layout_processor(
  process_fn : (G, IElkProgressMonitor?) -> Unit,
) -> ILayoutProcessor[P, G] {
  {
    id: next_layout_processor_id(),
    process_fn,
    is_phase: false,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn: _ => None,
  }
}

///|
pub fn[P, G] new_layout_phase(
  process_fn : (G, IElkProgressMonitor?) -> Unit,
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration[
    P,
    G,
  ]?,
) -> ILayoutProcessor[P, G] {
  {
    id: next_layout_processor_id(),
    process_fn,
    is_phase: true,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn,
  }
}

///|
pub fn[P, G] new_hierarchy_aware_layout_phase(
  process_fn : (G, IElkProgressMonitor?) -> Unit,
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration[
    P,
    G,
  ]?,
) -> ILayoutProcessor[P, G] {
  {
    id: next_layout_processor_id(),
    process_fn,
    is_phase: true,
    is_hierarchy_aware: true,
    get_layout_processor_configuration_fn,
  }
}

///|
pub fn[P, G] ILayoutProcessor::process(
  self : ILayoutProcessor[P, G],
  graph : G,
  progress_monitor : IElkProgressMonitor?,
) -> Unit {
  (self.process_fn)(graph, progress_monitor)
}

///|
pub fn[P, G] ILayoutProcessor::is_layout_phase(
  self : ILayoutProcessor[P, G],
) -> Bool {
  self.is_phase
}

///|
pub fn[P, G] ILayoutProcessor::is_hierarchy_aware_layout_processor(
  self : ILayoutProcessor[P, G],
) -> Bool {
  self.is_hierarchy_aware
}

///|
pub fn[P, G] ILayoutProcessor::get_layout_processor_configuration(
  self : ILayoutProcessor[P, G],
  graph : G,
) -> LayoutProcessorConfiguration[P, G]? {
  (self.get_layout_processor_configuration_fn)(graph)
}

///|
pub fn[P, G] ILayoutProcessor::instance_id(
  self : ILayoutProcessor[P, G],
) -> Int {
  self.id
}
