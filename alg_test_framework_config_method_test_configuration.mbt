///|
pub struct MethodTestConfiguration[T] {
  base : TestConfiguration[T]
  configurator_method_name : String
}

///|
pub fn[T] new_method_test_configuration(
  configurator_method_name : String,
  configurator_fn : (T, ElkNode) -> Unit,
  default_configuration? : DefaultConfiguration? = None,
) -> MethodTestConfiguration[T] {
  {
    base: new_test_configuration(
      default_configuration~,
      apply_base_configuration_fn=configurator_fn,
    ),
    configurator_method_name,
  }
}

///|
pub fn[T] method_test_configuration_from_methods(
  methods : Array[(String, (T, ElkNode) -> Unit)],
  default_configuration? : DefaultConfiguration? = None,
) -> Array[MethodTestConfiguration[T]] {
  let configurations : Array[MethodTestConfiguration[T]] = []
  for entry in methods {
    configurations.push(
      new_method_test_configuration(entry.0, entry.1, default_configuration~),
    )
  }
  configurations
}

///|
pub fn[T] MethodTestConfiguration::as_test_configuration(
  self : MethodTestConfiguration[T],
) -> TestConfiguration[T] {
  self.base
}

///|
pub fn[T] MethodTestConfiguration::apply(
  self : MethodTestConfiguration[T],
  test_instance : T,
  graph : ElkNode,
) -> Unit {
  self.base.apply(test_instance, graph)
}

///|
pub fn[T] MethodTestConfiguration::to_string(
  self : MethodTestConfiguration[T],
) -> String {
  self.base.to_string() + " configMethod(" + self.configurator_method_name + ")"
}
