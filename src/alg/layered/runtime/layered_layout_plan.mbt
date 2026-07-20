///|
/// Keeps executable pipeline state outside `LGraph`.
///
/// The layered graph is the algorithm's data model and is copied when a graph
/// is split into components. Keeping processor instances in that model made the
/// model depend on the pipeline and copied execution state as graph data.
/// A separate plan lets the model remain independent from pipeline assembly.
pub struct LayeredLayoutPlan {
  processors : Array[@core.ILayoutProcessor[LayeredPhases, LGraph]]
}

///|
pub fn new_layered_layout_plan(
  processors : Array[@core.ILayoutProcessor[LayeredPhases, LGraph]],
) -> LayeredLayoutPlan {
  { processors, }
}

///|
pub fn LayeredLayoutPlan::get_processors(
  self : LayeredLayoutPlan,
) -> Array[@core.ILayoutProcessor[LayeredPhases, LGraph]] {
  self.processors
}
