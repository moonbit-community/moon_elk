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
    "ONLY_WITHIN_GROUP" => OnlyWithinGroup
    "MODEL_ORDER" => ModelOrder
    "ENFORCED" => Enforced
    _ => OnlyWithinGroup
  }
}

///|
pub fn group_order_strategy_values() -> Array[String] {
  [
    group_order_strategy_to_string(OnlyWithinGroup),
    group_order_strategy_to_string(ModelOrder),
    group_order_strategy_to_string(Enforced),
  ]
}

///|
pub fn group_order_strategy_equals(
  left : GroupOrderStrategy,
  right : GroupOrderStrategy,
) -> Bool {
  match (left, right) {
    (OnlyWithinGroup, OnlyWithinGroup) => true
    (ModelOrder, ModelOrder) => true
    (Enforced, Enforced) => true
    _ => false
  }
}
