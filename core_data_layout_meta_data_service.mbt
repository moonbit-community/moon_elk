///|
let layout_algorithm_data_store : Ref[Map[String, LayoutAlgorithmData]] = Ref::new({},
)

///|
let layout_option_data_store : Ref[Map[String, LayoutOptionData]] = Ref::new({})

///|
let layout_category_data_store : Ref[Map[String, LayoutCategoryData]] = Ref::new({},
)

///|
pub fn layout_meta_data_service_reset_for_test() -> Unit {
  layout_algorithm_data_store.val.clear()
  layout_option_data_store.val.clear()
  layout_category_data_store.val.clear()
}

///|
pub fn layout_meta_data_service_register_algorithm(
  algorithm_data : LayoutAlgorithmData,
) -> Unit {
  layout_algorithm_data_store.val[algorithm_data.get_id()] = algorithm_data
}

///|
pub fn layout_meta_data_service_get_algorithm_data(
  id : String,
) -> LayoutAlgorithmData? {
  layout_algorithm_data_store.val.get(id)
}

///|
pub fn layout_meta_data_service_algorithm_data_values() -> Array[
  LayoutAlgorithmData,
] {
  let values = []
  layout_algorithm_data_store.val.each((id, data) => {
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
pub fn layout_meta_data_service_get_algorithm_data_by_suffix(
  suffix : String,
) -> LayoutAlgorithmData? {
  if suffix.trim().is_empty() {
    return None
  }
  if layout_algorithm_data_store.val.contains(suffix) {
    return layout_algorithm_data_store.val.get(suffix)
  }
  let mut duplicate = false
  let mut result : LayoutAlgorithmData? = None
  layout_algorithm_data_store.val.each((id, data) => if has_matching_suffix(
      id, suffix,
    ) {
    match result {
      None => result = Some(data)
      Some(_) => duplicate = true
    }
  })
  if duplicate {
    None
  } else {
    result
  }
}

///|
pub fn layout_meta_data_service_register_option(
  option_data : LayoutOptionData,
) -> Unit {
  layout_option_data_store.val[option_data.get_id()] = option_data
}

///|
pub fn layout_meta_data_service_register_category(
  category_data : LayoutCategoryData,
) -> Unit {
  layout_category_data_store.val[category_data.get_id()] = category_data
}

///|
fn layout_meta_data_service_add_dependency(
  source_option : String,
  target_option : String,
  required_value : String?,
) -> Unit {
  ignore(source_option)
  ignore(target_option)
  ignore(required_value)
}

///|
fn layout_meta_data_service_add_option_support(
  algorithm_id : String,
  option_id : String,
  default_value : String?,
) -> Unit {
  ignore(default_value)
  match layout_algorithm_data_store.val.get(algorithm_id) {
    Some(algorithm_data) => algorithm_data.add_known_option(option_id)
    None => ()
  }
}

///|
fn layout_meta_data_service_registry() -> LayoutMetaDataRegistry {
  new_layout_meta_data_registry(
    algorithm_data => layout_meta_data_service_register_algorithm(
      algorithm_data,
    ),
    option_data => layout_meta_data_service_register_option(option_data),
    category_data => layout_meta_data_service_register_category(category_data),
    (source_option, target_option, required_value) => layout_meta_data_service_add_dependency(
      source_option, target_option, required_value,
    ),
    (algorithm_id, option_id, default_value) => layout_meta_data_service_add_option_support(
      algorithm_id, option_id, default_value,
    ),
  )
}

///|
pub fn layout_meta_data_service_register_layout_meta_data_provider(
  provider : ILayoutMetaDataProvider,
) -> Unit {
  provider.apply(layout_meta_data_service_registry())
}

///|
pub fn layout_meta_data_service_register_layout_meta_data_providers(
  providers : Array[ILayoutMetaDataProvider],
) -> Unit {
  for provider in providers {
    layout_meta_data_service_register_layout_meta_data_provider(provider)
  }
}

///|
pub fn layout_meta_data_service_get_option_data_opt(
  id : String,
) -> LayoutOptionData? {
  layout_option_data_store.val.get(id)
}

///|
pub fn layout_meta_data_service_option_data_values() -> Array[LayoutOptionData] {
  let values = []
  layout_option_data_store.val.each((id, data) => {
    ignore(id)
    values.push(data)
  })
  values
}

///|
pub fn layout_meta_data_service_get_option_data_by_suffix(
  suffix : String,
) -> LayoutOptionData? {
  if suffix.trim().is_empty() {
    return None
  }
  if layout_option_data_store.val.contains(suffix) {
    return layout_option_data_store.val.get(suffix)
  }
  let mut duplicate = false
  let mut result : LayoutOptionData? = None
  layout_option_data_store.val.each((id, data) => if has_matching_suffix(
      id, suffix,
    ) {
    match result {
      None => result = Some(data)
      Some(_) => duplicate = true
    }
  })
  if duplicate {
    None
  } else {
    result
  }
}

///|
pub fn layout_meta_data_service_get_option_data(
  id : String,
) -> LayoutOptionData {
  match layout_option_data_store.val.get(id) {
    Some(option_data) => option_data
    None => abort("unknown layout option")
  }
}

///|
pub fn layout_meta_data_service_get_category_data(
  id : String,
) -> LayoutCategoryData? {
  layout_category_data_store.val.get(id)
}

///|
pub fn layout_meta_data_service_category_data_values() -> Array[
  LayoutCategoryData,
] {
  let values = []
  layout_category_data_store.val.each((id, data) => {
    ignore(id)
    values.push(data)
  })
  values
}

///|
fn register_default_algorithm_with_known_option_ids(
  algorithm_id : String,
  known_option_ids : Array[String],
) -> Unit {
  let algorithm_data = new_layout_algorithm_data(algorithm_id)
  for option_id in known_option_ids {
    algorithm_data.add_known_option(option_id)
  }
  layout_meta_data_service_register_algorithm(algorithm_data)
}

///|
pub fn layout_meta_data_service_register_default_algorithms() -> Unit {
  register_default_algorithm_with_known_option_ids("org.eclipse.elk.fixed", [
    padding.get_id(),
    node_size_constraints.get_id(),
    node_size_minimum.get_id(),
  ])
  register_default_algorithm_with_known_option_ids("org.eclipse.elk.box", [
    padding.get_id(),
    spacing_node_node.get_id(),
    priority.get_id(),
    expand_nodes.get_id(),
    node_size_constraints.get_id(),
    node_size_options.get_id(),
    aspect_ratio.get_id(),
    node_size_minimum.get_id(),
    content_alignment.get_id(),
  ])
  register_default_algorithm_with_known_option_ids("org.eclipse.elk.random", [
    padding.get_id(),
    spacing_node_node.get_id(),
    aspect_ratio.get_id(),
  ])
  register_default_algorithm_with_known_option_ids("org.eclipse.elk.layered", [])
}

///|
pub fn layout_meta_data_service_register_default_options() -> Unit {
  layout_meta_data_service_register_option(
    new_layout_option_data(
      algorithm.get_id(),
      name="Algorithm",
      group="algorithm",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      direction.get_id(),
      name="Direction",
      group="direction",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      alignment.get_id(),
      name="Alignment",
      group="alignment",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
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
  layout_meta_data_service_register_option(
    new_layout_option_data(
      spacing_node_node.get_id(),
      name="Node Node",
      group="spacing",
      option_type=DoubleType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      spacing_edge_node.get_id(),
      name="Edge Node",
      group="spacing",
      option_type=DoubleType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      priority.get_id(),
      name="Priority",
      group="priority",
      option_type=DoubleType,
      targets=[EdgesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      content_alignment.get_id(),
      name="Content Alignment",
      group="content",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      node_labels_placement.get_id(),
      name="Node Labels Placement",
      group="nodeLabels",
      option_type=EnumSetType,
      targets=[NodesTarget, LabelsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      port_labels_placement.get_id(),
      name="Port Labels Placement",
      group="portLabels",
      option_type=EnumSetType,
      targets=[PortsTarget, LabelsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      port_constraints.get_id(),
      name="Port Constraints",
      group="port",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      port_side.get_id(),
      name="Port Side",
      group="port",
      option_type=StringType,
      targets=[PortsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      port_labels_next_to_port_if_possible.get_id(),
      name="Port Labels Next To Port If Possible",
      group="portLabels",
      option_type=BoolType,
      targets=[PortsTarget, LabelsTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      padding.get_id(),
      name="Padding",
      group="spacing",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      node_size_constraints.get_id(),
      name="Node Size Constraints",
      group="nodeSize",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      node_size_minimum.get_id(),
      name="Node Size Minimum",
      group="nodeSize",
      option_type=StringType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      node_size_options.get_id(),
      name="Node Size Options",
      group="nodeSize",
      option_type=EnumSetType,
      targets=[NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      no_layout.get_id(),
      name="No Layout",
      group="algorithm",
      option_type=BoolType,
      targets=[ParentsTarget, NodesTarget],
    ),
  )
  layout_meta_data_service_register_option(
    new_layout_option_data(
      expand_nodes.get_id(),
      name="Expand Nodes",
      group="nodeSize",
      option_type=BoolType,
      targets=[ParentsTarget],
    ),
  )
}
