///|
pub let force_algorithm_id = "org.eclipse.elk.force"

///|
pub let stress_algorithm_id = "org.eclipse.elk.stress"

///|
pub let force_category_id = "org.eclipse.elk.force"

///|
fn register_force_category(registry : @core.LayoutMetaDataRegistry) -> Unit {
  registry.register_category(
    @core.new_layout_category_data(
      force_category_id,
      name="Force",
      description="Force-based layout algorithms.",
    ),
  )
}

///|
fn register_force_algorithm(registry : @core.LayoutMetaDataRegistry) -> Unit {
  registry.register_algorithm(
    @core.new_layout_algorithm_data(
      force_algorithm_id,
      name="ELK Force",
      description="Force-based @core.algorithm provided by the Eclipse Layout Kernel.",
    ),
  )
  registry.add_option_support(force_algorithm_id, @core.priority.get_id(), Some("1"))
  registry.add_option_support(
    force_algorithm_id,
    @core.spacing_node_node.get_id(),
    Some("80"),
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.spacing_edge_label.get_id(),
    Some("5"),
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.aspect_ratio.get_id(),
    Some("1.6"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_random_seed.get_id(),
    Some("1"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_separate_connected_components.get_id(),
    Some("true"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_padding.get_id(),
    Some("[left=50, top=50, right=50, bottom=50]"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_interactive.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.port_constraints.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    force_edge_labels_inline.get_id(),
    Some("false"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_omit_node_micro_layout.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.node_size_fixed_graph_size.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.node_size_options.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.node_size_constraints.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.node_labels_placement.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    @core.port_labels_placement.get_id(),
    None,
  )
  registry.add_option_support(
    force_algorithm_id,
    force_model.get_id(),
    Some("FRUCHTERMAN_REINGOLD"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_temperature.get_id(),
    Some("0.001"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_iterations.get_id(),
    Some("300"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_repulsion.get_id(),
    Some("5.0"),
  )
  registry.add_option_support(
    force_algorithm_id,
    force_repulsive_power.get_id(),
    Some("0"),
  )
}

///|
fn register_stress_algorithm(registry : @core.LayoutMetaDataRegistry) -> Unit {
  registry.register_algorithm(
    @core.new_layout_algorithm_data(
      stress_algorithm_id,
      name="ELK Stress",
      description="Stress majorization based layout @core.algorithm.",
    ),
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_interactive.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    force_edge_labels_inline.get_id(),
    Some("true"),
  )
  registry.add_option_support(
    stress_algorithm_id,
    @core.node_size_constraints.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    @core.node_size_minimum.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    @core.node_size_options.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    @core.node_labels_placement.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_omit_node_micro_layout.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    @core.port_labels_placement.get_id(),
    None,
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_fixed.get_id(),
    Some("false"),
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_dimension.get_id(),
    Some("XY"),
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_epsilon.get_id(),
    Some("0.001"),
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_iteration_limit.get_id(),
    Some("2147483647"),
  )
  registry.add_option_support(
    stress_algorithm_id,
    stress_desired_edge_length.get_id(),
    Some("100.0"),
  )
}

///|
fn register_force_options(registry : @core.LayoutMetaDataRegistry) -> Unit {
  registry.register_option(
    @core.new_layout_option_data(
      force_model.get_id(),
      name="Force Model",
      description="Determines the model for force calculation.",
      group="force",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      force_iterations.get_id(),
      name="Iterations",
      description="The number of iterations on the force model.",
      group="force",
      option_type=IntType,
      lower_bound=Some(1.0),
      targets=[ParentsTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      force_repulsive_power.get_id(),
      name="Repulsive Power",
      description="The number of bendpoints added as repelling particles.",
      group="force",
      option_type=IntType,
      lower_bound=Some(0.0),
      targets=[EdgesTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      force_temperature.get_id(),
      name="FR Temperature",
      description="The temperature scaling factor for displacements.",
      group="force",
      option_type=DoubleType,
      lower_bound=Some(0.0),
      lower_bound_exclusive=true,
      targets=[ParentsTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      force_repulsion.get_id(),
      name="Eades Repulsion",
      description="Factor for repulsive forces in Eades model.",
      group="force",
      option_type=DoubleType,
      lower_bound=Some(0.0),
      lower_bound_exclusive=true,
      targets=[ParentsTarget],
    ),
  )
}

///|
fn register_stress_options(registry : @core.LayoutMetaDataRegistry) -> Unit {
  registry.register_option(
    @core.new_layout_option_data(
      stress_fixed.get_id(),
      name="Fixed Position",
      description="Prevents that the node is moved by the layout @core.algorithm.",
      group="stress",
      option_type=BoolType,
      targets=[NodesTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      stress_desired_edge_length.get_id(),
      name="Desired Edge Length",
      description="Desired edge length for graph or individual edges.",
      group="stress",
      option_type=DoubleType,
      targets=[ParentsTarget, EdgesTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      stress_dimension.get_id(),
      name="Layout Dimension",
      description="Dimensions that are altered during layout.",
      group="stress",
      option_type=StringType,
      targets=[ParentsTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      stress_epsilon.get_id(),
      name="Stress Epsilon",
      description="Termination criterion for the iterative process.",
      group="stress",
      option_type=DoubleType,
      targets=[ParentsTarget],
    ),
  )
  registry.register_option(
    @core.new_layout_option_data(
      stress_iteration_limit.get_id(),
      name="Iteration Limit",
      description="Maximum number of stress majorization iterations.",
      group="stress",
      option_type=IntType,
      targets=[ParentsTarget],
    ),
  )
}

///|
pub fn new_force_meta_data_provider() -> @core.ILayoutMetaDataProvider {
  @core.new_layout_meta_data_provider(registry => {
    register_force_category(registry)
    register_force_options(registry)
    register_force_algorithm(registry)
  })
}

///|
pub fn new_stress_meta_data_provider() -> @core.ILayoutMetaDataProvider {
  @core.new_layout_meta_data_provider(registry => {
    register_force_category(registry)
    register_stress_options(registry)
    register_stress_algorithm(registry)
  })
}

///|
pub fn force_layout_meta_data_providers() -> Array[@core.ILayoutMetaDataProvider] {
  [new_force_meta_data_provider(), new_stress_meta_data_provider()]
}
