///|
pub fn enum_based_factory_compare(
  factory1 : LayoutProcessorFactory,
  factory2 : LayoutProcessorFactory,
) -> Int {
  factory1.factory_order() - factory2.factory_order()
}
