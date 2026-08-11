///|
/// Keeps executable pipeline state outside `LGraph`.
///
/// The layered graph is the algorithm's data model and is copied when a graph
/// is split into components. Keeping processor instances in that model made the
/// model depend on the pipeline and copied execution state as graph data.
/// A separate plan owns both graph-bound runnable processors and their per-run
/// state. The graph model only carries the shared algorithm state reference.
pub struct LayeredLayoutPlan {
  processors : Array[&@core.RunnableLayoutProcessor]
  state : LayeredLayoutState
}

///|
pub fn new_layered_layout_plan(
  plan : @core.LayoutProcessorPlan,
  state? : LayeredLayoutState = new_layered_layout_state(),
) -> LayeredLayoutPlan {
  { processors: plan.steps(), state }
}

///|
pub fn LayeredLayoutPlan::get_processors(
  self : LayeredLayoutPlan,
) -> Array[&@core.RunnableLayoutProcessor] {
  self.processors
}

///|
pub fn LayeredLayoutPlan::get_state(
  self : LayeredLayoutPlan,
) -> LayeredLayoutState {
  self.state
}
