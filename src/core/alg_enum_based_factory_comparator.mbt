///|
pub fn[P, G] enum_based_factory_compare(
  factory1 : ILayoutProcessorFactory[P, G],
  factory2 : ILayoutProcessorFactory[P, G],
) -> Int {
  factory1.factory_order() - factory2.factory_order()
}
