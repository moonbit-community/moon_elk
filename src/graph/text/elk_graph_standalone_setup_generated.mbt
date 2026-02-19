///|
pub let graph_text_file_extension : String = "elkt"

///|
pub let graph_text_resource_factory_value : String = "org.eclipse.xtext.resource.IResourceFactory"

///|
pub let graph_text_resource_service_provider_value : String = "org.eclipse.xtext.resource.IResourceServiceProvider"

///|
let graph_text_resource_factory_registry_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
let graph_text_resource_service_provider_registry_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
pub struct ElkGraphStandaloneSetupGenerated {
  marker : Unit
}

///|
pub fn new_elk_graph_standalone_setup_generated() -> ElkGraphStandaloneSetupGenerated {
  { marker: () }
}

///|
pub fn ElkGraphStandaloneSetupGenerated::create_injector_and_do_emf_registration(
  self : ElkGraphStandaloneSetupGenerated,
) -> GraphTextInjector {
  let injector = self.create_injector()
  self.register(injector)
  injector
}

///|
pub fn ElkGraphStandaloneSetupGenerated::create_injector(
  self : ElkGraphStandaloneSetupGenerated,
) -> GraphTextInjector {
  ignore(self)
  new_elk_graph_runtime_module().create_injector()
}

///|
pub fn ElkGraphStandaloneSetupGenerated::register(
  self : ElkGraphStandaloneSetupGenerated,
  _injector : GraphTextInjector,
) -> Unit {
  ignore(self)
  graph_text_resource_factory_registry_ref.val[graph_text_file_extension] = graph_text_resource_factory_value
  graph_text_resource_service_provider_registry_ref.val[graph_text_file_extension] = graph_text_resource_service_provider_value
}

///|
pub fn graph_text_registered_resource_factory(extension : String) -> String? {
  graph_text_resource_factory_registry_ref.val.get(extension)
}

///|
pub fn graph_text_registered_resource_service_provider(
  extension : String,
) -> String? {
  graph_text_resource_service_provider_registry_ref.val.get(extension)
}

///|
pub fn graph_text_reset_registries_for_test() -> Unit {
  graph_text_resource_factory_registry_ref.val.clear()
  graph_text_resource_service_provider_registry_ref.val.clear()
}
