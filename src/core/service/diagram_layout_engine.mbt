///|
pub let diagram_layout_engine_pref_debug_logging : String = "elk.debug.logs"

///|
pub let diagram_layout_engine_pref_debug_store : String = "elk.debug.store"

///|
pub let diagram_layout_engine_pref_debug_exec_time : String = "elk.debug.exectime"

///|
pub let diagram_layout_engine_mapping_connector_key : String = "layoutEngine.diagramLayoutConnector"

///|
pub let diagram_layout_engine_mapping_status_key : String = "layoutEngine.status"

///|
pub(all) struct DiagramLayoutEngineParameters {
  configurators : Array[@core.IGraphElementVisitor]
  global_settings : LayoutApplySettings
  mut override_diagram_config : Bool
}

///|
pub fn new_diagram_layout_engine_parameters() -> DiagramLayoutEngineParameters {
  {
    configurators: [],
    global_settings: {
      "animate": "false",
      "progressBar": "false",
      "layoutAncestors": "false",
      "zoomToFit": "false",
    },
    override_diagram_config: true,
  }
}

///|
pub fn DiagramLayoutEngineParameters::set_override_diagram_config(
  self : DiagramLayoutEngineParameters,
  override_value : Bool,
) -> DiagramLayoutEngineParameters {
  self.override_diagram_config = override_value
  self
}

///|
pub fn DiagramLayoutEngineParameters::set_global_bool_setting(
  self : DiagramLayoutEngineParameters,
  key : String,
  value : Bool,
) -> DiagramLayoutEngineParameters {
  self.global_settings[key] = if value { "true" } else { "false" }
  self
}

///|
pub fn DiagramLayoutEngineParameters::get_global_bool_setting(
  self : DiagramLayoutEngineParameters,
  key : String,
  default_value : Bool,
) -> Bool {
  match self.global_settings.get(key) {
    Some(value) => value == "true"
    None => default_value
  }
}

///|
pub fn DiagramLayoutEngineParameters::set_global_string_setting(
  self : DiagramLayoutEngineParameters,
  key : String,
  value : String,
) -> DiagramLayoutEngineParameters {
  self.global_settings[key] = value
  self
}

///|
pub fn DiagramLayoutEngineParameters::get_global_string_setting(
  self : DiagramLayoutEngineParameters,
  key : String,
) -> String? {
  self.global_settings.get(key)
}

///|
pub fn DiagramLayoutEngineParameters::add_layout_run(
  self : DiagramLayoutEngineParameters,
  configurator : @core.IGraphElementVisitor,
) -> @core.IGraphElementVisitor {
  self.configurators.push(configurator)
  configurator
}

///|
pub fn DiagramLayoutEngineParameters::add_layout_run_configurator(
  self : DiagramLayoutEngineParameters,
) -> @core.LayoutConfigurator {
  let configurator = @core.new_layout_configurator()
  ignore(self.add_layout_run(configurator.to_visitor()))
  configurator
}

///|
pub(all) struct DiagramLayoutEngine {
  connector : IDiagramLayoutConnector
  config_manager : LayoutConfigurationManager
  graph_layout_engine : @core.IGraphLayoutEngine
  algorithm_resolver : @core.LayoutAlgorithmResolver
  connectors_service : LayoutConnectorsService
}

///|
fn diagram_layout_engine_default_graph_layout_engine(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
) -> @core.IGraphLayoutEngine {
  let recursive_engine = @core.new_recursive_graph_layout_engine(
    runtime, session,
  )
  @core.new_graph_layout_engine((layout_graph, progress_monitor) => {
    recursive_engine.layout(layout_graph, progress_monitor)
  })
}

///|
pub fn new_diagram_layout_engine(
  runtime : @core.LayoutRuntime,
  session : @core.LayoutSession,
  connector : IDiagramLayoutConnector,
  config_manager? : LayoutConfigurationManager,
  graph_layout_engine? : @core.IGraphLayoutEngine,
  algorithm_resolver? : @core.LayoutAlgorithmResolver,
  connectors_service? : LayoutConnectorsService,
) -> DiagramLayoutEngine {
  let metadata = runtime.option_metadata()
  let config_manager = config_manager.unwrap_or(
    new_layout_configuration_manager(metadata),
  )
  let graph_layout_engine = graph_layout_engine.unwrap_or(
    diagram_layout_engine_default_graph_layout_engine(runtime, session),
  )
  let algorithm_resolver = algorithm_resolver.unwrap_or(
    @core.new_layout_algorithm_resolver(metadata),
  )
  let connectors_service = connectors_service.unwrap_or(
    new_layout_connectors_service(runtime, session),
  )
  {
    connector,
    config_manager,
    graph_layout_engine,
    algorithm_resolver,
    connectors_service,
  }
}

///|
fn diagram_layout_engine_merge_configurations(
  engine : DiagramLayoutEngine,
  params : DiagramLayoutEngineParameters,
  mapping : LayoutMapping,
) -> Array[@core.IGraphElementVisitor] {
  ignore(engine.config_manager.create_configurator(mapping))
  let visitors : Array[@core.IGraphElementVisitor] = [
    engine.algorithm_resolver.to_visitor(),
  ]
  for visitor in params.configurators {
    visitors.push(visitor)
  }
  visitors
}

///|
pub fn DiagramLayoutEngine::layout(
  self : DiagramLayoutEngine,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
  progress_monitor? : @core.IElkProgressMonitor = @core.new_basic_progress_monitor(),
  params? : DiagramLayoutEngineParameters = new_diagram_layout_engine_parameters(),
) -> LayoutMapping? raise {
  if workbench_part is None && diagram_part is None {
    return None
  }

  let mapping = match
    self.connector.build_layout_graph(workbench_part, diagram_part) {
    Some(created_mapping) => created_mapping
    None => return None
  }
  mapping.set_connector_id(Some(self.connector.id))
  mapping.set_property(
    diagram_layout_engine_mapping_connector_key,
    self.connector.id,
  )

  match mapping.get_layout_graph() {
    Some(layout_graph) => {
      let visitors = diagram_layout_engine_merge_configurations(
        self, params, mapping,
      )
      self.connectors_service.fire_layout_about_to_start(
        mapping, progress_monitor,
      )

      if progress_monitor.is_canceled() {
        mapping.set_status(Some(CanceledStatus))
        mapping.set_property(
          diagram_layout_engine_mapping_status_key, "CANCELED",
        )
        self.connectors_service.fire_layout_done(mapping, progress_monitor)
        return Some(mapping)
      }

      if !visitors.is_empty() {
        @core.apply_visitors(layout_graph, visitors)
      }
      self.graph_layout_engine.layout(layout_graph, progress_monitor)

      if progress_monitor.is_canceled() {
        mapping.set_status(Some(CanceledStatus))
        mapping.set_property(
          diagram_layout_engine_mapping_status_key, "CANCELED",
        )
      } else {
        mapping.set_status(Some(OkStatus))
        mapping.set_property(diagram_layout_engine_mapping_status_key, "OK")
      }

      self.connectors_service.fire_layout_done(mapping, progress_monitor)

      if mapping.get_status() == Some(OkStatus) {
        self.connector.apply_layout(mapping, params.global_settings)
      }
      Some(mapping)
    }
    None => {
      mapping.set_status(Some(WarningStatus("Unable to build layout graph")))
      mapping.set_property(
        diagram_layout_engine_mapping_status_key, "WARNING: Unable to build layout graph",
      )
      Some(mapping)
    }
  }
}

///|
fn diagram_layout_engine_from_injector(
  injector : CoreServiceInjector,
  service : LayoutConnectorsService,
) -> DiagramLayoutEngine? {
  match injector.get_connector() {
    Some(connector) => {
      let config_manager = match injector.get_layout_configuration_manager() {
        Some(manager) => manager
        None =>
          new_layout_configuration_manager(
            injector.runtime.option_metadata(),
            config_provider=injector.get_layout_configuration_store_provider(),
          )
      }
      let graph_layout_engine = match injector.get_graph_layout_engine() {
        Some(engine) => engine
        None =>
          diagram_layout_engine_default_graph_layout_engine(
            injector.runtime,
            injector.session,
          )
      }
      Some(
        new_diagram_layout_engine(
          injector.runtime,
          injector.session,
          connector,
          config_manager~,
          graph_layout_engine~,
          connectors_service=service,
        ),
      )
    }
    None => None
  }
}

///|
pub fn diagram_layout_engine_invoke_layout(
  service : LayoutConnectorsService,
  workbench_part : ServiceWorkbenchPart?,
  diagram_part : ServiceDiagramElement?,
  params? : DiagramLayoutEngineParameters = new_diagram_layout_engine_parameters(),
) -> LayoutMapping? raise {
  match service.get_injector(workbench_part, diagram_part) {
    Some(injector) =>
      match diagram_layout_engine_from_injector(injector, service) {
        Some(engine) => engine.layout(workbench_part, diagram_part, params~)
        None => None
      }
    None => None
  }
}
