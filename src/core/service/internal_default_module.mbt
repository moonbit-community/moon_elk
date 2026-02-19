///|
pub(all) struct CoreServiceInjector {
  bindings : Map[String, String]
  mut diagram_layout_connector : IDiagramLayoutConnector?
  mut layout_configuration_store_provider : LayoutConfigurationStoreProvider?
  mut layout_configuration_manager : LayoutConfigurationManager?
  mut graph_layout_engine : @core.IGraphLayoutEngine?
}

///|
pub fn new_core_service_injector(
  bindings? : Map[String, String] = {},
  diagram_layout_connector? : IDiagramLayoutConnector? = None,
  layout_configuration_store_provider? : LayoutConfigurationStoreProvider? = None,
  layout_configuration_manager? : LayoutConfigurationManager? = None,
  graph_layout_engine? : @core.IGraphLayoutEngine? = None,
) -> CoreServiceInjector {
  {
    bindings,
    diagram_layout_connector,
    layout_configuration_store_provider,
    layout_configuration_manager,
    graph_layout_engine,
  }
}

///|
pub fn CoreServiceInjector::copy(
  self : CoreServiceInjector,
) -> CoreServiceInjector {
  new_core_service_injector(
    bindings=self.bindings.copy(),
    diagram_layout_connector=self.diagram_layout_connector,
    layout_configuration_store_provider=self.layout_configuration_store_provider,
    layout_configuration_manager=self.layout_configuration_manager,
    graph_layout_engine=self.graph_layout_engine,
  )
}

///|
pub fn CoreServiceInjector::binding_of(
  self : CoreServiceInjector,
  key : String,
) -> String? {
  self.bindings.get(key)
}

///|
pub fn CoreServiceInjector::set_binding(
  self : CoreServiceInjector,
  key : String,
  value : String,
) -> Unit {
  self.bindings[key] = value
}

///|
pub fn CoreServiceInjector::set_connector(
  self : CoreServiceInjector,
  connector : IDiagramLayoutConnector?,
) -> Unit {
  self.diagram_layout_connector = connector
}

///|
pub fn CoreServiceInjector::get_connector(
  self : CoreServiceInjector,
) -> IDiagramLayoutConnector? {
  self.diagram_layout_connector
}

///|
pub fn CoreServiceInjector::set_layout_configuration_store_provider(
  self : CoreServiceInjector,
  provider : LayoutConfigurationStoreProvider?,
) -> Unit {
  self.layout_configuration_store_provider = provider
}

///|
pub fn CoreServiceInjector::get_layout_configuration_store_provider(
  self : CoreServiceInjector,
) -> LayoutConfigurationStoreProvider? {
  self.layout_configuration_store_provider
}

///|
pub fn CoreServiceInjector::set_layout_configuration_manager(
  self : CoreServiceInjector,
  manager : LayoutConfigurationManager?,
) -> Unit {
  self.layout_configuration_manager = manager
}

///|
pub fn CoreServiceInjector::get_layout_configuration_manager(
  self : CoreServiceInjector,
) -> LayoutConfigurationManager? {
  self.layout_configuration_manager
}

///|
pub fn CoreServiceInjector::set_graph_layout_engine(
  self : CoreServiceInjector,
  graph_layout_engine : @core.IGraphLayoutEngine?,
) -> Unit {
  self.graph_layout_engine = graph_layout_engine
}

///|
pub fn CoreServiceInjector::get_graph_layout_engine(
  self : CoreServiceInjector,
) -> @core.IGraphLayoutEngine? {
  self.graph_layout_engine
}

///|
fn default_graph_layout_engine() -> @core.IGraphLayoutEngine {
  let recursive_engine = @core.new_recursive_graph_layout_engine()
  @core.new_graph_layout_engine((layout_graph, progress_monitor) => {
    recursive_engine.layout(layout_graph, progress_monitor)
  })
}

///|
pub fn new_default_module() -> CoreServiceInjector {
  new_core_service_injector(
    bindings={
      "IGraphLayoutEngine": "RecursiveGraphLayoutEngine",
      "LayoutConfigurationManager": "LayoutConfigurationManager",
    },
    layout_configuration_manager=Some(new_layout_configuration_manager()),
    graph_layout_engine=Some(default_graph_layout_engine()),
  )
}
