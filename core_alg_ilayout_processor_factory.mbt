///|
pub struct ILayoutProcessorFactory[P, G] {
  id : Int
  order : Int
  create_fn : () -> ILayoutProcessor[P, G]
}

///|
pub type ILayoutPhaseFactory[P, G] = ILayoutProcessorFactory[P, G]

///|
pub fn[P, G] new_layout_processor_factory(
  id : Int,
  order : Int,
  create_fn : () -> ILayoutProcessor[P, G],
) -> ILayoutProcessorFactory[P, G] {
  { id, order, create_fn }
}

///|
pub fn[P, G] ILayoutProcessorFactory::create(
  self : ILayoutProcessorFactory[P, G],
) -> ILayoutProcessor[P, G] {
  (self.create_fn)()
}

///|
pub fn[P, G] ILayoutProcessorFactory::factory_id(
  self : ILayoutProcessorFactory[P, G],
) -> Int {
  self.id
}

///|
pub fn[P, G] ILayoutProcessorFactory::factory_order(
  self : ILayoutProcessorFactory[P, G],
) -> Int {
  self.order
}
