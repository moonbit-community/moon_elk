///|
/// Keeps executable pipeline state outside `LGraph`.
///
/// The layered graph is the algorithm's data model and is copied when a graph
/// is split into components. Keeping processor instances in that model made the
/// model depend on the pipeline and copied execution state as graph data.
/// A separate plan owns both the processors and their per-run state. Graphs
/// only carry a shared state reference while the current processor interface
/// still accepts an `LGraph` directly.
pub struct LayeredLayoutPlan {
  processors : Array[@core.ILayoutProcessor[LayeredPhases, LGraph]]
  state : LayeredLayoutState
}

///|
pub fn new_layered_layout_plan(
  processors : Array[@core.ILayoutProcessor[LayeredPhases, LGraph]],
  state? : LayeredLayoutState = new_layered_layout_state(),
) -> LayeredLayoutPlan {
  { processors, state }
}

///|
pub fn LayeredLayoutPlan::get_processors(
  self : LayeredLayoutPlan,
) -> Array[@core.ILayoutProcessor[LayeredPhases, LGraph]] {
  self.processors
}

///|
pub fn LayeredLayoutPlan::get_state(
  self : LayeredLayoutPlan,
) -> LayeredLayoutState {
  self.state
}
