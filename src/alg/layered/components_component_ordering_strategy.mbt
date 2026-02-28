///|
pub enum ComponentOrderingStrategy {
  NoneType
  InsidePortSideGroups
  GroupModelOrder
  ModelOrder
}

///|
let _component_ordering_strategy_all_values : Array[ComponentOrderingStrategy] = [
  NoneType,
  InsidePortSideGroups,
  GroupModelOrder,
  ModelOrder,
]

///|
pub fn component_ordering_strategy_equals(
  left : ComponentOrderingStrategy,
  right : ComponentOrderingStrategy,
) -> Bool {
  match (left, right) {
    (NoneType, NoneType) => true
    (InsidePortSideGroups, InsidePortSideGroups) => true
    (GroupModelOrder, GroupModelOrder) => true
    (ModelOrder, ModelOrder) => true
    _ => false
  }
}
