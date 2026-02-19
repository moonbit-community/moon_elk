///|
pub struct PropertyConstantsDelegator {
  property_delegate_ids : Map[String, Unit]
}

///|
pub fn property_constants_delegator_create_empty() -> PropertyConstantsDelegator {
  { property_delegate_ids: {} }
}

///|
pub fn property_constants_delegator_create_for_layout_algorithm_data(
  algorithm_data : LayoutAlgorithmData,
) -> PropertyConstantsDelegator {
  let delegator = property_constants_delegator_create_empty()
  for option_id in algorithm_data.get_known_option_ids() {
    delegator.property_delegate_ids[option_id] = ()
  }
  delegator
}

///|
pub fn property_constants_delegator_create_for_layout_algorithm_with_id(
  algorithm_id : String,
) -> PropertyConstantsDelegator {
  match layout_meta_data_service_get_algorithm_data(algorithm_id) {
    Some(algorithm_data) =>
      property_constants_delegator_create_for_layout_algorithm_data(
        algorithm_data,
      )
    None => property_constants_delegator_create_empty()
  }
}

///|
pub fn[T] PropertyConstantsDelegator::add_delegate(
  self : PropertyConstantsDelegator,
  delegate : IProperty[T],
) -> PropertyConstantsDelegator {
  self.property_delegate_ids[delegate.get_id()] = ()
  self
}

///|
pub fn[T] PropertyConstantsDelegator::get_property_or_delegate(
  self : PropertyConstantsDelegator,
  property : IProperty[T],
) -> IProperty[T] {
  if self.property_delegate_ids.contains(property.get_id()) {
    // MoonBit metadata currently tracks known option ids but not algorithm-specific
    // typed constants/default values, so delegation is id-based.
    new_property(property.get_id(), property.get_default())
  } else {
    property
  }
}

///|
pub fn[T, P] PropertyConstantsDelegator::get_property_with(
  self : PropertyConstantsDelegator,
  property_holder : P,
  property : IProperty[T],
  getter : (P, IProperty[T]) -> T,
) -> T {
  getter(property_holder, self.get_property_or_delegate(property))
}

///|
pub fn PropertyConstantsDelegator::get_property_double(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[Double],
) -> Double {
  self.get_property_with(node, property, node_get_double_property)
}

///|
pub fn PropertyConstantsDelegator::get_property_int(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[Int],
) -> Int {
  self.get_property_with(node, property, node_get_int_property)
}

///|
pub fn PropertyConstantsDelegator::get_property_bool(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[Bool],
) -> Bool {
  self.get_property_with(node, property, node_get_bool_property)
}

///|
pub fn PropertyConstantsDelegator::get_property_string(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[String],
) -> String {
  self.get_property_with(node, property, node_get_string_property)
}

///|
pub fn PropertyConstantsDelegator::get_property_string_set(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[Array[String]],
) -> Array[String] {
  self.get_property_with(node, property, node_get_string_set_property)
}

///|
pub fn PropertyConstantsDelegator::get_property_kvector(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[KVector],
) -> KVector {
  self.get_property_with(node, property, node_get_kvector_property)
}

///|
pub fn PropertyConstantsDelegator::get_individual_or_inherited_property(
  self : PropertyConstantsDelegator,
  node : ElkNode,
  property : IProperty[Double],
) -> Double {
  individual_spacings_get_individual_or_inherited(
    node,
    self.get_property_or_delegate(property),
  )
}

///|
pub fn PropertyConstantsDelegator::has_delegate_for(
  self : PropertyConstantsDelegator,
  property_id : String,
) -> Bool {
  self.property_delegate_ids.contains(property_id)
}
