///|
pub(all) enum PortConstraints {
  Undefined
  Free
  FixedSide
  FixedOrder
  FixedRatio
  FixedPos
}

///|
pub fn port_constraints_values() -> Array[PortConstraints] {
  [Undefined, Free, FixedSide, FixedOrder, FixedRatio, FixedPos]
}

///|
pub fn port_constraints_to_string(constraint : PortConstraints) -> String {
  match constraint {
    Undefined => "UNDEFINED"
    Free => "FREE"
    FixedSide => "FIXED_SIDE"
    FixedOrder => "FIXED_ORDER"
    FixedRatio => "FIXED_RATIO"
    FixedPos => "FIXED_POS"
  }
}

///|
fn port_constraints_equals(
  left : PortConstraints,
  right : PortConstraints,
) -> Bool {
  match (left, right) {
    (Undefined, Undefined) => true
    (Free, Free) => true
    (FixedSide, FixedSide) => true
    (FixedOrder, FixedOrder) => true
    (FixedRatio, FixedRatio) => true
    (FixedPos, FixedPos) => true
    _ => false
  }
}

///|
pub fn PortConstraints::is_pos_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedPos)
}

///|
pub fn PortConstraints::is_ratio_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedRatio)
}

///|
pub fn PortConstraints::is_order_fixed(self : PortConstraints) -> Bool {
  port_constraints_equals(self, FixedOrder) ||
  port_constraints_equals(self, FixedRatio) ||
  port_constraints_equals(self, FixedPos)
}

///|
pub fn PortConstraints::is_side_fixed(self : PortConstraints) -> Bool {
  !port_constraints_equals(self, Free) &&
  !port_constraints_equals(self, Undefined)
}
