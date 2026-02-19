///|
pub struct PropertyHolderComparator[T] {
  property : IProperty[T]
}

///|
pub fn[T : Compare + FromJson] property_holder_comparator_with(
  property : IProperty[T],
) -> PropertyHolderComparator[T] {
  { property, }
}

///|
pub fn[T : Compare + FromJson] PropertyHolderComparator::compare(
  self : PropertyHolderComparator[T],
  ph1 : IPropertyHolder,
  ph2 : IPropertyHolder,
) -> Int {
  let p1 = ph1.get_property(self.property)
  let p2 = ph2.get_property(self.property)
  p1.compare(p2)
}
