///|
let next_layout_processor_id_ref : Ref[Int] = Ref(0)

///|
fn next_layout_processor_id() -> Int {
  let id = next_layout_processor_id_ref.val
  next_layout_processor_id_ref.val = id + 1
  id
}

///|
/// Graph-specific processor implementation kept inside an algorithm package.
///
/// `G` remains concrete throughout the processor body and its inner loops. It
/// is erased only when the processor is bound to one graph for plan execution.
pub(all) struct TypedLayoutProcessor[G] {
  id : Int
  process_fn : ((G, IElkProgressMonitor?) -> Unit raise)?
  pure_process_fn : ((G, IElkProgressMonitor?) -> Unit)?
  is_phase : Bool
  is_hierarchy_aware : Bool
  get_layout_processor_configuration_fn : ((G) -> LayoutProcessorConfiguration? raise)?
  get_pure_layout_processor_configuration_fn : ((G) -> LayoutProcessorConfiguration?)?
}

///|
/// Coarse-grained execution seam for a fully bound pipeline step.
///
/// Dynamic dispatch happens once per processor. The graph is already captured
/// by the adapter, so processor implementations never use `Any`, reflection,
/// or a universal graph trait.
pub(open) trait RunnableLayoutProcessor {
  fn run(Self, IElkProgressMonitor?) -> Unit raise
  fn instance_id(Self) -> Int
  fn is_layout_phase(Self) -> Bool
  fn is_hierarchy_aware_layout_processor(Self) -> Bool
  fn get_layout_processor_configuration(Self) -> LayoutProcessorConfiguration? raise
}

///|
priv struct BoundLayoutProcessor[G] {
  graph : G
  processor : TypedLayoutProcessor[G]
}

///|
impl[G] RunnableLayoutProcessor for BoundLayoutProcessor[G] with fn run(
  self,
  progress_monitor,
) raise {
  self.processor.process(self.graph, progress_monitor)
}

///|
impl[G] RunnableLayoutProcessor for BoundLayoutProcessor[G] with fn instance_id(
  self,
) {
  self.processor.instance_id()
}

///|
impl[G] RunnableLayoutProcessor for BoundLayoutProcessor[G] with fn is_layout_phase(
  self,
) {
  self.processor.is_layout_phase()
}

///|
impl[G] RunnableLayoutProcessor for BoundLayoutProcessor[G] with fn is_hierarchy_aware_layout_processor(
  self,
) {
  self.processor.is_hierarchy_aware_layout_processor()
}

///|
impl[G] RunnableLayoutProcessor for BoundLayoutProcessor[G] with fn get_layout_processor_configuration(
  self,
) raise {
  self.processor.get_layout_processor_configuration(self.graph)
}

///|
fn[G] bind_layout_processor(
  graph : G,
  processor : TypedLayoutProcessor[G],
) -> &RunnableLayoutProcessor {
  BoundLayoutProcessor::{ graph, processor }
}

///|
pub fn[G] new_layout_processor(
  process_fn : (G, IElkProgressMonitor?) -> Unit raise,
) -> TypedLayoutProcessor[G] {
  {
    id: next_layout_processor_id(),
    process_fn: Some(process_fn),
    pure_process_fn: None,
    is_phase: false,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn: None,
    get_pure_layout_processor_configuration_fn: None,
  }
}

///|
pub fn[G] new_pure_layout_processor(
  process_fn : (G, IElkProgressMonitor?) -> Unit,
) -> TypedLayoutProcessor[G] {
  {
    id: next_layout_processor_id(),
    process_fn: None,
    pure_process_fn: Some(process_fn),
    is_phase: false,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn: None,
    get_pure_layout_processor_configuration_fn: None,
  }
}

///|
pub fn[G] new_layout_phase(
  process_fn : (G, IElkProgressMonitor?) -> Unit raise,
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration? raise,
) -> TypedLayoutProcessor[G] {
  {
    id: next_layout_processor_id(),
    process_fn: Some(process_fn),
    pure_process_fn: None,
    is_phase: true,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn: Some(
      get_layout_processor_configuration_fn,
    ),
    get_pure_layout_processor_configuration_fn: None,
  }
}

///|
pub fn[G] new_pure_layout_phase(
  process_fn : (G, IElkProgressMonitor?) -> Unit raise,
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration?,
) -> TypedLayoutProcessor[G] {
  {
    id: next_layout_processor_id(),
    process_fn: Some(process_fn),
    pure_process_fn: None,
    is_phase: true,
    is_hierarchy_aware: false,
    get_layout_processor_configuration_fn: None,
    get_pure_layout_processor_configuration_fn: Some(
      get_layout_processor_configuration_fn,
    ),
  }
}

///|
pub fn[G] new_hierarchy_aware_layout_phase(
  process_fn : (G, IElkProgressMonitor?) -> Unit raise,
  get_layout_processor_configuration_fn : (G) -> LayoutProcessorConfiguration? raise,
) -> TypedLayoutProcessor[G] {
  {
    id: next_layout_processor_id(),
    process_fn: Some(process_fn),
    pure_process_fn: None,
    is_phase: true,
    is_hierarchy_aware: true,
    get_layout_processor_configuration_fn: Some(
      get_layout_processor_configuration_fn,
    ),
    get_pure_layout_processor_configuration_fn: None,
  }
}

///|
pub fn[G] TypedLayoutProcessor::process(
  self : TypedLayoutProcessor[G],
  graph : G,
  progress_monitor : IElkProgressMonitor?,
) -> Unit raise {
  match self.process_fn {
    Some(process) => process(graph, progress_monitor)
    None =>
      match self.pure_process_fn {
        Some(process) => process(graph, progress_monitor)
        None => ()
      }
  }
}

///|
pub fn[G] TypedLayoutProcessor::is_layout_phase(
  self : TypedLayoutProcessor[G],
) -> Bool {
  self.is_phase
}

///|
pub fn[G] TypedLayoutProcessor::is_hierarchy_aware_layout_processor(
  self : TypedLayoutProcessor[G],
) -> Bool {
  self.is_hierarchy_aware
}

///|
pub fn[G] TypedLayoutProcessor::get_layout_processor_configuration(
  self : TypedLayoutProcessor[G],
  graph : G,
) -> LayoutProcessorConfiguration? raise {
  match self.get_layout_processor_configuration_fn {
    Some(get_configuration) => get_configuration(graph)
    None =>
      match self.get_pure_layout_processor_configuration_fn {
        Some(get_configuration) => get_configuration(graph)
        None => None
      }
  }
}

///|
pub fn[G] TypedLayoutProcessor::instance_id(
  self : TypedLayoutProcessor[G],
) -> Int {
  self.id
}
