///|
/// Non-generic factory for one graph-bound runnable processor.
pub(all) struct LayoutProcessorFactory {
  id : Int
  order : Int
  create_fn : () -> &RunnableLayoutProcessor raise
}

///|
/// Erases `G` after binding a typed processor factory to one concrete graph.
pub fn[G] new_layout_processor_factory(
  id : Int,
  order : Int,
  graph : G,
  create_fn : () -> TypedLayoutProcessor[G] raise,
) -> LayoutProcessorFactory {
  { id, order, create_fn: () => bind_layout_processor(graph, create_fn()) }
}

///|
pub fn LayoutProcessorFactory::create(
  self : LayoutProcessorFactory,
) -> &RunnableLayoutProcessor raise {
  (self.create_fn)()
}

///|
pub fn LayoutProcessorFactory::factory_id(self : LayoutProcessorFactory) -> Int {
  self.id
}

///|
pub fn LayoutProcessorFactory::factory_order(
  self : LayoutProcessorFactory,
) -> Int {
  self.order
}
