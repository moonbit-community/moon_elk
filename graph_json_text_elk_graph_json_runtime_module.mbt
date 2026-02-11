///|
pub struct GraphJsonTextInjector {
  providers : Map[String, () -> String]
}

///|
pub fn new_graph_json_text_injector() -> GraphJsonTextInjector {
  { providers: {} }
}

///|
pub fn GraphJsonTextInjector::register_provider(
  self : GraphJsonTextInjector,
  class_name : String,
  provider : () -> String,
) -> Unit {
  self.providers[class_name] = provider
}

///|
pub fn GraphJsonTextInjector::get_instance(
  self : GraphJsonTextInjector,
  class_name : String,
) -> String? {
  match self.providers.get(class_name) {
    Some(provider) => Some(provider())
    None => None
  }
}

///|
pub struct ElkGraphJsonRuntimeModule {
  base : AbstractElkGraphJsonRuntimeModule
}

///|
pub fn new_elk_graph_json_runtime_module(
  base? : AbstractElkGraphJsonRuntimeModule = new_abstract_elk_graph_json_runtime_module(),
) -> ElkGraphJsonRuntimeModule {
  { base, }
}

///|
pub fn ElkGraphJsonRuntimeModule::configure(
  self : ElkGraphJsonRuntimeModule,
  properties : Map[String, String],
) -> Unit {
  self.base.configure(properties)
}

///|
pub fn ElkGraphJsonRuntimeModule::get_base(
  self : ElkGraphJsonRuntimeModule,
) -> AbstractElkGraphJsonRuntimeModule {
  self.base
}

///|
pub fn ElkGraphJsonRuntimeModule::bind_i_value_converter_service(
  self : ElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.conversion.ElkGraphJsonValueConverterService"
}

///|
pub fn ElkGraphJsonRuntimeModule::bind_i_qualified_name_provider(
  self : ElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.naming.ElkGraphJsonQualifiedNameProvider"
}

///|
pub fn ElkGraphJsonRuntimeModule::bind_i_qualified_name_converter(
  self : ElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.naming.ElkGraphJsonQualifiedNameConverter"
}

///|
pub fn ElkGraphJsonRuntimeModule::bind_i_transient_value_service2(
  self : ElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.serializer.ElkGraphJsonTransientValueService"
}

///|
pub fn ElkGraphJsonRuntimeModule::bind_ilinker(
  self : ElkGraphJsonRuntimeModule,
) -> String {
  ignore(self)
  "org.eclipse.elk.graph.json.text.linking.ElkGraphJsonLinker"
}

///|
pub fn ElkGraphJsonRuntimeModule::create_injector(
  self : ElkGraphJsonRuntimeModule,
) -> GraphJsonTextInjector {
  let injector = new_graph_json_text_injector()
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
