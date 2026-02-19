///|
pub struct BlackboxTestMethod[T] {
  method_name : String
  ignored : Bool
  run_fn : (T, ElkNode) -> Unit
}

///|
pub fn[T] new_blackbox_test_method(
  method_name : String,
  run_fn : (T, ElkNode) -> Unit,
  ignored? : Bool = false,
) -> BlackboxTestMethod[T] {
  { method_name, ignored, run_fn }
}

///|
pub fn[T] BlackboxTestMethod::get_method_name(
  self : BlackboxTestMethod[T],
) -> String {
  self.method_name
}

///|
pub fn[T] BlackboxTestMethod::is_ignored(self : BlackboxTestMethod[T]) -> Bool {
  self.ignored
}

///|
pub fn[T] BlackboxTestMethod::invoke(
  self : BlackboxTestMethod[T],
  test_instance : T,
  graph : ElkNode,
) -> Unit {
  (self.run_fn)(test_instance, graph)
}

///|
pub struct WhiteboxTestMethod[T, G] {
  method_name : String
  ignored : Bool
  fail_if_not_executed : Bool
  only_on_root_node : Bool
  before_processor_ids : Array[String]
  after_processor_ids : Array[String]
  run_fn : (T, G) -> Unit
}

///|
pub fn[T, G] new_whitebox_test_method(
  method_name : String,
  run_fn : (T, G) -> Unit,
  ignored? : Bool = false,
  fail_if_not_executed? : Bool = false,
  only_on_root_node? : Bool = false,
  before_processor_ids? : Array[String] = [],
  after_processor_ids? : Array[String] = [],
) -> WhiteboxTestMethod[T, G] {
  {
    method_name,
    ignored,
    fail_if_not_executed,
    only_on_root_node,
    before_processor_ids,
    after_processor_ids,
    run_fn,
  }
}

///|
pub fn[T, G] WhiteboxTestMethod::get_method_name(
  self : WhiteboxTestMethod[T, G],
) -> String {
  self.method_name
}

///|
pub fn[T, G] WhiteboxTestMethod::is_ignored(
  self : WhiteboxTestMethod[T, G],
) -> Bool {
  self.ignored
}

///|
pub fn[T, G] WhiteboxTestMethod::get_fail_if_not_executed(
  self : WhiteboxTestMethod[T, G],
) -> Bool {
  self.fail_if_not_executed
}

///|
pub fn[T, G] WhiteboxTestMethod::get_only_on_root_node(
  self : WhiteboxTestMethod[T, G],
) -> Bool {
  self.only_on_root_node
}

///|
pub fn[T, G] WhiteboxTestMethod::get_before_processor_ids(
  self : WhiteboxTestMethod[T, G],
) -> Array[String] {
  self.before_processor_ids
}

///|
pub fn[T, G] WhiteboxTestMethod::get_after_processor_ids(
  self : WhiteboxTestMethod[T, G],
) -> Array[String] {
  self.after_processor_ids
}

///|
pub fn[T, G] WhiteboxTestMethod::invoke(
  self : WhiteboxTestMethod[T, G],
  test_instance : T,
  graph : G,
) -> Unit {
  (self.run_fn)(test_instance, graph)
}
