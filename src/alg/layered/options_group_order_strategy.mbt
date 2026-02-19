///|
pub enum GroupOrderStrategy {
  OnlyWithinGroup
  ModelOrder
  Enforced
}

///|
pub fn group_order_strategy_to_string(value : GroupOrderStrategy) -> String {
  match value {
    OnlyWithinGroup => "ONLY_WITHIN_GROUP"
    ModelOrder => "MODEL_ORDER"
    Enforced => "ENFORCED"
  }
}

///|
pub fn group_order_strategy_from_string(value : String) -> GroupOrderStrategy {
  match value {
    "ONLY_WITHIN_GROUP" => GroupOrderStrategy::OnlyWithinGroup
    "MODEL_ORDER" => GroupOrderStrategy::ModelOrder
    "ENFORCED" => GroupOrderStrategy::Enforced
    _ => GroupOrderStrategy::OnlyWithinGroup
  }
}

///|
pub fn group_order_strategy_values() -> Array[String] {
  [
    group_order_strategy_to_string(GroupOrderStrategy::OnlyWithinGroup),
    group_order_strategy_to_string(GroupOrderStrategy::ModelOrder),
    group_order_strategy_to_string(GroupOrderStrategy::Enforced),
  ]
}

///|
pub fn group_order_strategy_equals(
  left : GroupOrderStrategy,
  right : GroupOrderStrategy,
) -> Bool {
  match (left, right) {
    (GroupOrderStrategy::OnlyWithinGroup, GroupOrderStrategy::OnlyWithinGroup) =>
      true
    (GroupOrderStrategy::ModelOrder, GroupOrderStrategy::ModelOrder) => true
    (GroupOrderStrategy::Enforced, GroupOrderStrategy::Enforced) => true
    _ => false
  }
}
