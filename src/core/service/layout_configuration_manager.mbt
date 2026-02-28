///|
pub struct LayoutConfigurationManager {
  mut config_provider : LayoutConfigurationStoreProvider?
  layout_algorithm_resolver : @core.LayoutAlgorithmResolver
}

///|
pub fn new_layout_configuration_manager(
  config_provider? : LayoutConfigurationStoreProvider? = None,
  layout_algorithm_resolver? : @core.LayoutAlgorithmResolver = @core.new_layout_algorithm_resolver(),
) -> LayoutConfigurationManager {
  { config_provider, layout_algorithm_resolver }
}

///|
pub fn LayoutConfigurationManager::set_config_provider(
  self : LayoutConfigurationManager,
  config_provider : LayoutConfigurationStoreProvider?,
) -> Unit {
  self.config_provider = config_provider
}

///|
pub fn LayoutConfigurationManager::get_algorithm(
  self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> @core.LayoutAlgorithmData? {
  let configured_algorithm = config.get_option_value(@core.algorithm.get_id())
  match configured_algorithm {
    Some(value) =>
      if value.trim().is_empty() {
        @core.layout_meta_data_service_get_algorithm_data_by_suffix(
          self.layout_algorithm_resolver.default_layout_algorithm_id,
        )
      } else {
        match
          @core.layout_meta_data_service_get_algorithm_data_by_suffix(value) {
          Some(data) => Some(data)
          None =>
            @core.layout_meta_data_service_get_algorithm_data_by_suffix(
              self.layout_algorithm_resolver.default_layout_algorithm_id,
            )
        }
      }
    None =>
      @core.layout_meta_data_service_get_algorithm_data_by_suffix(
        self.layout_algorithm_resolver.default_layout_algorithm_id,
      )
  }
}

///|
pub fn LayoutConfigurationManager::get_supported_options(
  self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> Array[@core.LayoutOptionData] {
  let option_data : Map[String, @core.LayoutOptionData] = {}
  match self.get_algorithm(config) {
    Some(algo_data) =>
      for candidate in @core.layout_meta_data_service_option_data_values() {
        if algo_data.knows_option(candidate.get_id()) {
          option_data[candidate.get_id()] = candidate
        }
      }
    None => ()
  }

  for option_id in config.get_affected_options() {
    match @core.layout_meta_data_service_get_option_data_opt(option_id) {
      Some(found_option) => option_data[option_id] = found_option
      None => ()
    }
  }

  let result : Array[@core.LayoutOptionData] = []
  for entry in option_data.to_array() {
    result.push(entry.1)
  }
  result
}

///|
pub fn LayoutConfigurationManager::get_option_value(
  self : LayoutConfigurationManager,
  option_data : @core.LayoutOptionData,
  config : ILayoutConfigurationStore,
) -> String? {
  match self.get_raw_option_value(option_data.get_id(), config) {
    Some(value) => Some(value)
    None =>
      if option_data.get_id() == @core.algorithm.get_id() {
        Some(self.layout_algorithm_resolver.default_layout_algorithm_id)
      } else {
        None
      }
  }
}

///|
pub fn LayoutConfigurationManager::get_raw_option_value(
  _self : LayoutConfigurationManager,
  option_id : String,
  config : ILayoutConfigurationStore,
) -> String? {
  config.get_option_value(option_id)
}

///|
pub fn LayoutConfigurationManager::get_responsible_parent(
  self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> ILayoutConfigurationStore? {
  let mut result = config.get_parent()
  let mut current = result
  while current is Some(current_store) {
    let parent = current_store.get_parent()
    if parent is Some(parent_store) &&
      self.is_full_hierarchy_layout(parent_store) {
      result = parent
    }
    current = parent
  }
  result
}

///|
pub fn LayoutConfigurationManager::is_full_hierarchy_layout(
  self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> Bool {
  let hierarchy_setting = config.get_option_value(
    "org.eclipse.elk.hierarchyHandling",
  )
  match hierarchy_setting {
    Some(value) =>
      if value == "INCLUDE_CHILDREN" {
        match self.get_algorithm(config) {
          Some(algo_data) =>
            algo_data.supports_feature(@graph.GraphFeature::Compound) ||
            algo_data.supports_feature(@graph.GraphFeature::Clusters)
          None => false
        }
      } else {
        false
      }
    None => false
  }
}

///|
pub fn LayoutConfigurationManager::get_root(
  _self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> ILayoutConfigurationStore {
  let mut current = config
  let mut parent = current.get_parent()
  while parent is Some(parent_store) {
    current = parent_store
    parent = current.get_parent()
  }
  current
}

///|
pub fn LayoutConfigurationManager::clear_option_values(
  _self : LayoutConfigurationManager,
  config : ILayoutConfigurationStore,
) -> Unit {
  for option_id in config.get_affected_options() {
    config.set_option_value(option_id, None)
  }
}

///|
fn layout_configuration_manager_collect_nodes(
  root : @graph.ElkNode,
) -> Map[Int, Bool] {
  let nodes : Map[Int, Bool] = {}
  for node in @graph.node_all_descendants_including_self(root) {
    nodes[node] = true
  }
  nodes
}

///|
fn layout_configuration_manager_configure_element(
  element : @graph.ElkNode,
  config_store : ILayoutConfigurationStore,
) -> Unit {
  for option_id in config_store.get_affected_options() {
    match config_store.get_option_value(option_id) {
      Some(value) =>
        @graph.node_set_layout_option_string_by_id(element, option_id, value)
      None => ()
    }
  }
}

///|
pub fn LayoutConfigurationManager::create_configurator(
  self : LayoutConfigurationManager,
  layout_mapping : LayoutMapping,
) -> @core.LayoutConfigurator {
  let configurator = @core.new_layout_configurator()
  match (self.config_provider, layout_mapping.get_layout_graph()) {
    (Some(provider), Some(layout_graph)) => {
      let graph_nodes = layout_configuration_manager_collect_nodes(layout_graph)
      for entry in layout_mapping.graph_map_entries() {
        if graph_nodes.contains(entry.0) {
          match
            provider.get(layout_mapping.get_workbench_part(), Some(entry.1)) {
            Some(config_store) =>
              layout_configuration_manager_configure_element(
                entry.0,
                config_store,
              )
            None => ()
          }
        }
      }
    }
    _ => ()
  }
  configurator
}
