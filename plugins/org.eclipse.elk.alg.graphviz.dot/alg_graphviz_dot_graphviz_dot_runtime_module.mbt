///|
pub let graphviz_dot_serializer_class_name : String = "org.eclipse.elk.alg.graphviz.dot.serializer.GraphvizDotSerializer"

///|
pub struct GraphvizDotRuntimeModule {
  serializer_provider : () -> GraphvizDotSerializer
  injector_providers : Map[String, () -> GraphvizDotObject]
}

///|
fn graphviz_dot_runtime_module_default_serializer_provider() -> GraphvizDotSerializer {
  new_graphviz_dot_serializer()
}

///|
pub fn new_graphviz_dot_runtime_module(
  serializer_provider? : () -> GraphvizDotSerializer = graphviz_dot_runtime_module_default_serializer_provider,
) -> GraphvizDotRuntimeModule {
  let injector_providers : Map[String, () -> GraphvizDotObject] = {}
  injector_providers[graphviz_dot_serializer_class_name] = () => {
    GraphvizDotObjectSerializer(serializer_provider())
  }
  { serializer_provider, injector_providers }
}

///|
pub fn GraphvizDotRuntimeModule::bind_iserializer(
  self : GraphvizDotRuntimeModule,
) -> String {
  ignore(self.serializer_provider)
  graphviz_dot_serializer_class_name
}

///|
pub fn GraphvizDotRuntimeModule::register_injector_provider(
  self : GraphvizDotRuntimeModule,
  class_name : String,
  provider : () -> GraphvizDotObject,
) -> Unit {
  self.injector_providers[class_name] = provider
}

///|
pub fn GraphvizDotRuntimeModule::create_injector(
  self : GraphvizDotRuntimeModule,
) -> GraphvizDotInjector {
  let injector = new_graphviz_dot_injector()
  for entry in self.injector_providers.to_array() {
    injector.register_provider(entry.0, entry.1)
  }
  injector
}
