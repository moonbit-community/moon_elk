///|
pub struct IElkCancelIndicator {
  canceled : Bool
}

///|
pub fn new_elk_cancel_indicator(
  canceled? : Bool = false,
) -> IElkCancelIndicator {
  { canceled, }
}

///|
pub fn IElkCancelIndicator::is_canceled(self : IElkCancelIndicator) -> Bool {
  self.canceled
}
