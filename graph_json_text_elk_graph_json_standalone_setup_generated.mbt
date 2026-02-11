///|
pub let graph_json_text_file_extension : String = "elkj"

///|
pub let graph_json_text_resource_factory_value : String = "org.eclipse.xtext.resource.IResourceFactory"

///|
pub let graph_json_text_resource_service_provider_value : String = "org.eclipse.xtext.resource.IResourceServiceProvider"

///|
let graph_json_text_resource_factory_registry_ref : Ref[Map[String, String]] = Ref::new({},
)

///|
let graph_json_text_resource_service_provider_registry_ref : Ref[
  Map[String, String],
] = Ref::new({})

///|
pub struct ElkGraphJsonStandaloneSetupGenerated {
  marker : Unit
}

///|
pub fn new_elk_graph_json_standalone_setup_generated() -> ElkGraphJsonStandaloneSetupGenerated {
  { marker: () }
}

///|
pub fn ElkGraphJsonStandaloneSetupGenerated::create_injector_and_do_emf_registration(
  self : ElkGraphJsonStandaloneSetupGenerated,
) -> GraphJsonTextInjector {
  let injector = self.create_injector()
  self.register(injector)
  injector
}

///|
pub fn ElkGraphJsonStandaloneSetupGenerated::create_injector(
  self : ElkGraphJsonStandaloneSetupGenerated,
) -> GraphJsonTextInjector {
  ignore(self)
  new_elk_graph_json_runtime_module().create_injector()
}

///|
pub fn ElkGraphJsonStandaloneSetupGenerated::register(
  self : ElkGraphJsonStandaloneSetupGenerated,
  _injector : GraphJsonTextInjector,
) -> Unit {
  ignore(self)
  graph_json_text_resource_factory_registry_ref.val[graph_json_text_file_extension] = graph_json_text_resource_factory_value
  graph_json_text_resource_service_provider_registry_ref.val[graph_json_text_file_extension] = graph_json_text_resource_service_provider_value
}

///|
pub fn graph_json_text_registered_resource_factory(
  extension : String,
) -> String? {
  graph_json_text_resource_factory_registry_ref.val.get(extension)
}

///|
pub fn graph_json_text_registered_resource_service_provider(
  extension : String,
) -> String? {
  graph_json_text_resource_service_provider_registry_ref.val.get(extension)
}

///|
pub fn graph_json_text_reset_registries_for_test() -> Unit {
  graph_json_text_resource_factory_registry_ref.val.clear()
  graph_json_text_resource_service_provider_registry_ref.val.clear()
}
