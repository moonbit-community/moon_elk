///|
pub let graphviz_dot_ns_uri : String = "http://www.eclipse.org/elk/GraphvizDot"

///|
pub let graphviz_dot_file_extension : String = "graphviz_dot"

///|
pub let graphviz_dot_epackage_value : String = "org.eclipse.elk.alg.graphviz.dot.dot.DotPackage"

///|
pub let graphviz_dot_resource_factory_value : String = "org.eclipse.xtext.resource.IResourceFactory"

///|
pub let graphviz_dot_resource_service_provider_value : String = "org.eclipse.xtext.resource.IResourceServiceProvider"

///|
let graphviz_dot_epackage_registry_ref : Ref[Map[String, String]] = Ref({})

///|
let graphviz_dot_resource_factory_registry_ref : Ref[Map[String, String]] = Ref({},
)

///|
let graphviz_dot_resource_service_provider_registry_ref : Ref[
  Map[String, String],
] = Ref({})

///|
pub struct GraphvizDotStandaloneSetupGenerated {
  marker : Unit
}

///|
pub fn new_graphviz_dot_standalone_setup_generated() -> GraphvizDotStandaloneSetupGenerated {
  { marker: () }
}

///|
pub fn GraphvizDotStandaloneSetupGenerated::create_injector_and_do_emf_registration(
  self : GraphvizDotStandaloneSetupGenerated,
) -> GraphvizDotInjector {
  let injector = self.create_injector()
  self.register(injector)
  injector
}

///|
pub fn GraphvizDotStandaloneSetupGenerated::create_injector(
  self : GraphvizDotStandaloneSetupGenerated,
) -> GraphvizDotInjector {
  ignore(self)
  new_graphviz_dot_runtime_module().create_injector()
}

///|
pub fn GraphvizDotStandaloneSetupGenerated::register(
  self : GraphvizDotStandaloneSetupGenerated,
  _injector : GraphvizDotInjector,
) -> Unit {
  ignore(self)
  if !graphviz_dot_epackage_registry_ref.val.contains(graphviz_dot_ns_uri) {
    graphviz_dot_epackage_registry_ref.val[graphviz_dot_ns_uri] = graphviz_dot_epackage_value
  }
  graphviz_dot_resource_factory_registry_ref.val[graphviz_dot_file_extension] = graphviz_dot_resource_factory_value
  graphviz_dot_resource_service_provider_registry_ref.val[graphviz_dot_file_extension] = graphviz_dot_resource_service_provider_value
}

///|
pub fn graphviz_dot_registered_epackage(ns_uri : String) -> String? {
  graphviz_dot_epackage_registry_ref.val.get(ns_uri)
}

///|
pub fn graphviz_dot_registered_resource_factory(extension : String) -> String? {
  graphviz_dot_resource_factory_registry_ref.val.get(extension)
}

///|
pub fn graphviz_dot_registered_resource_service_provider(
  extension : String,
) -> String? {
  graphviz_dot_resource_service_provider_registry_ref.val.get(extension)
}

///|
pub fn graphviz_dot_reset_registries_for_test() -> Unit {
  graphviz_dot_epackage_registry_ref.val.clear()
  graphviz_dot_resource_factory_registry_ref.val.clear()
  graphviz_dot_resource_service_provider_registry_ref.val.clear()
}
