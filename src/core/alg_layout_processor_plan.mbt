///|
/// Fully type-erased execution plan assembled from graph-bound processors.
pub struct LayoutProcessorPlan {
  processors : Array[&RunnableLayoutProcessor]
}

///|
pub fn new_layout_processor_plan(
  processors : Array[&RunnableLayoutProcessor],
) -> LayoutProcessorPlan {
  { processors, }
}

///|
pub fn LayoutProcessorPlan::steps(
  self : LayoutProcessorPlan,
) -> Array[&RunnableLayoutProcessor] {
  self.processors.copy()
}

///|
pub fn LayoutProcessorPlan::length(self : LayoutProcessorPlan) -> Int {
  self.processors.length()
}

///|
pub fn LayoutProcessorPlan::is_empty(self : LayoutProcessorPlan) -> Bool {
  self.processors.is_empty()
}
