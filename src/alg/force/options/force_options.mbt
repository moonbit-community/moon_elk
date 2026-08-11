///|
pub type ForceBoolOption = @graph.IProperty[Bool]

///|
pub fn new_force_bool_option(
  id : String,
  default_value : Bool,
) -> ForceBoolOption {
  @graph.new_property(id, default_value)
}

///|
pub type ForceIntOption = @graph.IProperty[Int]

///|
pub fn new_force_int_option(id : String, default_value : Int) -> ForceIntOption {
  @graph.new_property(id, default_value)
}

///|
pub type ForceDoubleOption = @graph.IProperty[Double]

///|
pub fn new_force_double_option(
  id : String,
  default_value : Double,
) -> ForceDoubleOption {
  @graph.new_property(id, default_value)
}

///|
pub type ForceModelOption = @graph.IProperty[ForceModelStrategy]

///|
pub fn new_force_model_option(
  id : String,
  default_value : ForceModelStrategy,
) -> ForceModelOption {
  @graph.new_property(id, default_value)
}

///|
pub type ForcePaddingOption = @graph.IProperty[@core.ElkPadding]

///|
pub fn new_force_padding_option(
  id : String,
  default_value : @core.ElkPadding,
) -> ForcePaddingOption {
  @graph.new_property(id, default_value)
}

///|
pub let force_separate_connected_components : ForceBoolOption = new_force_bool_option(
  "org.eclipse.elk.separateConnectedComponents", true,
)

///|
pub let force_interactive : ForceBoolOption = new_force_bool_option(
  "org.eclipse.elk.interactive", false,
)

///|
pub let force_omit_node_micro_layout : ForceBoolOption = new_force_bool_option(
  "org.eclipse.elk.omitNodeMicroLayout", false,
)

///|
pub let force_edge_labels_inline : ForceBoolOption = new_force_bool_option(
  "org.eclipse.elk.edgeLabels.inline", false,
)

///|
pub let force_model : ForceModelOption = new_force_model_option(
  "org.eclipse.elk.force.model",
  FruchtermanReingold,
)

///|
pub let force_iterations : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.force.iterations", 300,
)

///|
pub let force_repulsive_power : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.force.repulsivePower", 0,
)

///|
pub let force_priority : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.priority", 1,
)

///|
pub let force_random_seed : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.randomSeed", 1,
)

///|
pub let force_temperature : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.force.temperature", 0.001,
)

///|
pub let force_repulsion : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.force.repulsion", 5.0,
)

///|
pub let force_spacing_node_node : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.spacing.nodeNode", 80.0,
)

///|
pub let force_spacing_edge_label : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.spacing.edgeLabel", 5.0,
)

///|
pub let force_aspect_ratio : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.aspectRatio", 1.6,
)

///|
pub let force_padding : ForcePaddingOption = new_force_padding_option(
  "org.eclipse.elk.padding",
  @core.new_elk_padding_any(50.0),
)
