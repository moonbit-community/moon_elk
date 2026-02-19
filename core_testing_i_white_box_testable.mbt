///|
pub struct IWhiteBoxTestable[G] {
  set_test_controller_fn : (TestController[G]?) -> Unit
}

///|
pub fn[G] new_white_box_testable(
  set_test_controller_fn : (TestController[G]?) -> Unit,
) -> IWhiteBoxTestable[G] {
  { set_test_controller_fn, }
}

///|
pub fn[G] IWhiteBoxTestable::set_test_controller(
  self : IWhiteBoxTestable[G],
  controller : TestController[G]?,
) -> Unit {
  (self.set_test_controller_fn)(controller)
}
