///|
pub struct ConfiguratorTestConfiguration[T] {
  base : TestConfiguration[T]
  configurator_method_name : String
}

///|
pub fn[T] new_configurator_test_configuration(
  configurator_method_name : String,
  configurator_provider_fn : (T) -> LayoutConfigurator,
  default_configuration? : DefaultConfiguration? = None,
) -> ConfiguratorTestConfiguration[T] {
  let cache : Ref[LayoutConfigurator?] = Ref::new(None)
  let base = new_test_configuration(default_configuration~, apply_base_configuration_fn=(
    test_instance,
    graph,
  ) => {
    let configurator = match cache.val {
      Some(value) => value
      None => {
        let generated = configurator_provider_fn(test_instance)
        cache.val = Some(generated)
        generated
      }
    }
    apply_visitors(graph, [configurator.to_visitor()])
  })
  { base, configurator_method_name }
}

///|
pub fn[T] configurator_test_configuration_from_providers(
  providers : Array[(String, (T) -> LayoutConfigurator)],
  default_configuration? : DefaultConfiguration? = None,
) -> Array[ConfiguratorTestConfiguration[T]] {
  let configurations : Array[ConfiguratorTestConfiguration[T]] = []
  for provider in providers {
    configurations.push(
      new_configurator_test_configuration(
        provider.0,
        provider.1,
        default_configuration~,
      ),
    )
  }
  configurations
}

///|
pub fn[T] ConfiguratorTestConfiguration::as_test_configuration(
  self : ConfiguratorTestConfiguration[T],
) -> TestConfiguration[T] {
  self.base
}

///|
pub fn[T] ConfiguratorTestConfiguration::apply(
  self : ConfiguratorTestConfiguration[T],
  test_instance : T,
  graph : ElkNode,
) -> Unit {
  self.base.apply(test_instance, graph)
}

///|
pub fn[T] ConfiguratorTestConfiguration::to_string(
  self : ConfiguratorTestConfiguration[T],
) -> String {
  self.base.to_string() +
  " layoutConfigurator(" +
  self.configurator_method_name +
  ")"
}
