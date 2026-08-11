///|
pub struct OptionMetadata {
  priv algorithm_data_store : Map[String, LayoutAlgorithmData]
  priv option_data_store : Map[String, LayoutOptionData]
  priv category_data_store : Map[String, LayoutCategoryData]
}

///|
pub fn new_option_metadata() -> OptionMetadata {
  {
    algorithm_data_store: Map([]),
    option_data_store: Map([]),
    category_data_store: Map([]),
  }
}

///|
priv suberror LayoutMetaDataServiceException {
  LayoutMetaDataServiceException(String)
} derive(Debug, ToJson)

///|
fn layout_meta_data_service_raise_unit(
  message : String,
) -> Unit raise LayoutMetaDataServiceException {
  raise LayoutMetaDataServiceException(message)
}

///|
fn layout_meta_data_service_exception_message(
  err : LayoutMetaDataServiceException,
) -> String {
  match err {
    LayoutMetaDataServiceException(message) => message
  }
}

///|
pub fn OptionMetadata::clear(self : OptionMetadata) -> Unit {
  self.algorithm_data_store.clear()
  self.option_data_store.clear()
  self.category_data_store.clear()
}

///|
pub fn OptionMetadata::register_algorithm(
  self : OptionMetadata,
  algorithm_data : LayoutAlgorithmData,
) -> Unit {
  self.algorithm_data_store[algorithm_data.get_id()] = algorithm_data
}

///|
pub fn OptionMetadata::algorithm_data(
  self : OptionMetadata,
  id : String,
) -> LayoutAlgorithmData? {
  self.algorithm_data_store.get(id)
}

///|
pub fn OptionMetadata::algorithm_data_values(
  self : OptionMetadata,
) -> Array[LayoutAlgorithmData] {
  let values = []
  self.algorithm_data_store.each((id, data) => {
    ignore(id)
    values.push(data)
  })
  values
}

///|
fn has_matching_suffix(id : String, suffix : String) -> Bool {
  id == suffix || id.has_suffix(".\{suffix}")
}

///|
pub fn OptionMetadata::algorithm_data_by_suffix(
  self : OptionMetadata,
  suffix : String,
) -> LayoutAlgorithmData? {
  if suffix.trim().is_empty() {
    return None
  }
  if self.algorithm_data_store.contains(suffix) {
    return self.algorithm_data_store.get(suffix)
  }
  let mut duplicate = false
  let mut result : LayoutAlgorithmData? = None
  self.algorithm_data_store.each((id, data) => {
    if has_matching_suffix(id, suffix) {
      match result {
        None => result = Some(data)
        Some(_) => duplicate = true
      }
    }
  })
  if duplicate {
    None
  } else {
    result
  }
}

///|
pub fn OptionMetadata::register_option(
  self : OptionMetadata,
  option_data : LayoutOptionData,
) -> Unit {
  self.option_data_store[option_data.get_id()] = option_data
}

///|
pub fn OptionMetadata::register_category(
  self : OptionMetadata,
  category_data : LayoutCategoryData,
) -> Unit {
  self.category_data_store[category_data.get_id()] = category_data
}

///|
fn OptionMetadata::add_dependency(
  self : OptionMetadata,
  source_option : String,
  target_option : String,
  required_value : String?,
) -> Unit {
  match self.option_data_store.get(source_option) {
    Some(option_data) =>
      option_data.add_dependency(target_option, expected_value=required_value)
    None => ()
  }
}

///|
fn OptionMetadata::add_option_support(
  self : OptionMetadata,
  algorithm_id : String,
  option_id : String,
  default_value : String?,
) -> Unit {
  ignore(default_value)
  match self.algorithm_data_store.get(algorithm_id) {
    Some(algorithm_data) => algorithm_data.add_known_option(option_id)
    None => ()
  }
}

///|
fn OptionMetadata::registry(self : OptionMetadata) -> LayoutMetaDataRegistry {
  new_layout_meta_data_registry(
    algorithm_data => self.register_algorithm(algorithm_data),
    option_data => self.register_option(option_data),
    category_data => self.register_category(category_data),
    (source_option, target_option, required_value) => {
      self.add_dependency(source_option, target_option, required_value)
    },
    (algorithm_id, option_id, default_value) => {
      self.add_option_support(algorithm_id, option_id, default_value)
    },
  )
}

///|
pub fn OptionMetadata::register_provider(
  self : OptionMetadata,
  provider : ILayoutMetaDataProvider,
) -> Unit {
  provider.apply(self.registry())
}

///|
pub fn OptionMetadata::register_providers(
  self : OptionMetadata,
  providers : Array[ILayoutMetaDataProvider],
) -> Unit {
  for provider in providers {
    self.register_provider(provider)
  }
}

///|
pub fn OptionMetadata::option_data_opt(
  self : OptionMetadata,
  id : String,
) -> LayoutOptionData? {
  self.option_data_store.get(id)
}

///|
pub fn OptionMetadata::option_data_values(
  self : OptionMetadata,
) -> Array[LayoutOptionData] {
  let values = []
  self.option_data_store.each((id, data) => {
    ignore(id)
    values.push(data)
  })
  values
}

///|
pub fn OptionMetadata::option_data_by_suffix(
  self : OptionMetadata,
  suffix : String,
) -> LayoutOptionData? {
  if suffix.trim().is_empty() {
    return None
  }
  if self.option_data_store.contains(suffix) {
    return self.option_data_store.get(suffix)
  }
  let mut duplicate = false
  let mut result : LayoutOptionData? = None
  self.option_data_store.each((id, data) => {
    if has_matching_suffix(id, suffix) {
      match result {
        None => result = Some(data)
        Some(_) => duplicate = true
      }
    }
  })
  if duplicate {
    None
  } else {
    result
  }
}

///|
pub fn OptionMetadata::option_data(
  self : OptionMetadata,
  id : String,
) -> LayoutOptionData raise {
  match self.option_data_store.get(id) {
    Some(option_data) => option_data
    None => {
      try layout_meta_data_service_raise_unit("unknown layout option") catch {
        err =>
          layout_runtime_raise_unsupported_configuration(
            layout_meta_data_service_exception_message(err),
          )
      } noraise {
        _ => ()
      }
      new_layout_option_data(id)
    }
  }
}

///|
pub fn OptionMetadata::category_data(
  self : OptionMetadata,
  id : String,
) -> LayoutCategoryData? {
  self.category_data_store.get(id)
}

///|
pub fn OptionMetadata::category_data_values(
  self : OptionMetadata,
) -> Array[LayoutCategoryData] {
  let values = []
  self.category_data_store.each((id, data) => {
    ignore(id)
    values.push(data)
  })
  values
}

///|
fn OptionMetadata::register_default_algorithm(
  self : OptionMetadata,
  algorithm_id : String,
  known_option_ids : Array[String],
) -> Unit {
  let algorithm_data = new_layout_algorithm_data(algorithm_id)
  for option_id in known_option_ids {
    algorithm_data.add_known_option(option_id)
  }
  self.register_algorithm(algorithm_data)
}

///|
pub fn OptionMetadata::register_default_algorithms(
  self : OptionMetadata,
) -> Unit {
  self.register_default_algorithm("org.eclipse.elk.fixed", [
    padding.get_id(),
    node_size_constraints.get_id(),
    node_size_minimum.get_id(),
  ])
  self.register_default_algorithm("org.eclipse.elk.box", [
    padding.get_id(),
    spacing_node_node.get_id(),
    priority.get_id(),
    expand_nodes.get_id(),
    interactive.get_id(),
    node_size_constraints.get_id(),
    node_size_options.get_id(),
    aspect_ratio.get_id(),
    node_size_minimum.get_id(),
    box_packing_mode.get_id(),
    content_alignment.get_id(),
  ])
  self.register_default_algorithm("org.eclipse.elk.random", [
    padding.get_id(),
    spacing_node_node.get_id(),
    aspect_ratio.get_id(),
  ])
  self.register_default_algorithm("org.eclipse.elk.layered", [])
  self.register_default_algorithm("org.eclipse.elk.mrtree", [
    padding.get_id(),
    spacing_node_node.get_id(),
    aspect_ratio.get_id(),
    priority.get_id(),
    "org.eclipse.elk.separateConnectedComponents",
  ])
}

///|
pub fn OptionMetadata::register_default_options(self : OptionMetadata) -> Unit {
  self.register_option(
    new_layout_option_data(
      algorithm.get_id(),
      name="Algorithm",
      group="algorithm",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      direction.get_id(),
      name="Direction",
      group="direction",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      "org.eclipse.elk.position",
      name="Position",
      group="",
      option_type=StringType,
      targets=[NodesTarget, PortsTarget, LabelsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      "org.eclipse.elk.bendPoints",
      name="Bend Points",
      group="",
      option_type=StringType,
      targets=[EdgesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      alignment.get_id(),
      name="Alignment",
      group="alignment",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      aspect_ratio.get_id(),
      name="Aspect Ratio",
      group="spacing",
      option_type=DoubleType,
      lower_bound=Some(0.0),
      lower_bound_exclusive=true,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      spacing_node_node.get_id(),
      name="Node Node",
      group="spacing",
      option_type=DoubleType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      spacing_edge_node.get_id(),
      name="Edge Node",
      group="spacing",
      option_type=DoubleType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      priority.get_id(),
      name="Priority",
      group="priority",
      option_type=DoubleType,
      targets=[EdgesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      content_alignment.get_id(),
      name="Content Alignment",
      group="content",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      node_labels_placement.get_id(),
      name="Node Labels Placement",
      group="nodeLabels",
      option_type=EnumSetType,
      targets=[NodesTarget, LabelsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      port_labels_placement.get_id(),
      name="Port Labels Placement",
      group="portLabels",
      option_type=EnumSetType,
      targets=[PortsTarget, LabelsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      port_constraints.get_id(),
      name="Port Constraints",
      group="port",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      port_side.get_id(),
      name="Port Side",
      group="port",
      option_type=StringType,
      targets=[PortsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      port_labels_next_to_port_if_possible.get_id(),
      name="Port Labels Next To Port If Possible",
      group="portLabels",
      option_type=BoolType,
      targets=[PortsTarget, LabelsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      port_labels_treat_as_group.get_id(),
      name="Treat Port Labels as Group",
      group="portLabels",
      option_type=BoolType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      padding.get_id(),
      name="Padding",
      group="spacing",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      node_size_constraints.get_id(),
      name="Node Size Constraints",
      group="nodeSize",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      node_size_minimum.get_id(),
      name="Node Size Minimum",
      group="nodeSize",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      node_size_options.get_id(),
      name="Node Size Options",
      group="nodeSize",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      no_layout.get_id(),
      name="No Layout",
      group="algorithm",
      option_type=BoolType,
      targets=[ParentsTarget, NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      expand_nodes.get_id(),
      name="Expand Nodes",
      group="nodeSize",
      option_type=BoolType,
      targets=[ParentsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      "org.eclipse.elk.hierarchyHandling",
      name="Hierarchy Handling",
      group="",
      option_type=StringType,
      targets=[ParentsTarget, NodesTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      interactive.get_id(),
      name="Interactive",
      group="algorithm",
      option_type=BoolType,
      targets=[ParentsTarget],
    ),
  )
  self.register_option(
    new_layout_option_data(
      box_packing_mode.get_id(),
      name="Box Layout Mode",
      group="box",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
}
