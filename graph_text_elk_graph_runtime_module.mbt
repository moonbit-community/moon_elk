///|
pub struct GraphTextInjector {
  providers : Map[String, () -> String]
}

///|
pub fn new_graph_text_injector() -> GraphTextInjector {
  { providers: {} }
}

///|
pub fn GraphTextInjector::register_provider(
  self : GraphTextInjector,
  class_name : String,
  provider : () -> String,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn GraphTextInjector::get_instance(
  self : GraphTextInjector,
  class_name : String,
) -> String? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub struct ElkGraphRuntimeModule {
  base : AbstractElkGraphRuntimeModule
}

///|
pub fn new_elk_graph_runtime_module(
  base? : AbstractElkGraphRuntimeModule = new_abstract_elk_graph_runtime_module(),
) -> ElkGraphRuntimeModule {
  { base, }
}

///|
pub fn ElkGraphRuntimeModule::configure(
  self : ElkGraphRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.base.configure(properties)
}

///|
pub fn ElkGraphRuntimeModule::get_base(
  self : ElkGraphRuntimeModule,
) -> AbstractElkGraphRuntimeModule {
  self.base
}

///|
pub fn ElkGraphRuntimeModule::bind_i_value_converter_service(
  self : ElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.conversion.ElkGraphValueConverterService"
}

///|
pub fn ElkGraphRuntimeModule::bind_i_qualified_name_provider(
  self : ElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.naming.ElkGraphQualifiedNameProvider"
}

///|
pub fn ElkGraphRuntimeModule::bind_i_qualified_name_converter(
  self : ElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.naming.ElkGraphQualifiedNameConverter"
}

///|
pub fn ElkGraphRuntimeModule::bind_i_transient_value_service2(
  self : ElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.serializer.ElkGraphTransientValueService"
}

///|
pub fn ElkGraphRuntimeModule::bind_ilinker(
  self : ElkGraphRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.text.linking.ElkGraphLinker"
}

///|
pub fn ElkGraphRuntimeModule::create_injector(
  self : ElkGraphRuntimeModule,
) -> GraphTextInjector {
  let injector = new_graph_text_injector()
  injector.register_provider("org.eclipse.xtext.resource.IResourceFactory", () => {
    "org.eclipse.xtext.resource.IResourceFactory"
  })
  injector.register_provider(
    "org.eclipse.xtext.resource.IResourceServiceProvider",
    () => "org.eclipse.xtext.resource.IResourceServiceProvider",
  )
  injector.register_provider(self.bind_i_value_converter_service(), () => {
    self.bind_i_value_converter_service()
  })
  injector
}
