///|
pub struct ForceBoolOption {
  id : String
  default_value : Bool
}

///|
pub fn new_force_bool_option(
  id : String,
  default_value : Bool,
) -> ForceBoolOption {
  { id, default_value }
}

///|
pub fn ForceBoolOption::get_id(self : ForceBoolOption) -> String {
  self.id
}

///|
pub fn ForceBoolOption::get_default(self : ForceBoolOption) -> Bool {
  self.default_value
}

///|
pub struct ForceIntOption {
  id : String
  default_value : Int
}

///|
pub fn new_force_int_option(id : String, default_value : Int) -> ForceIntOption {
  { id, default_value }
}

///|
pub fn ForceIntOption::get_id(self : ForceIntOption) -> String {
  self.id
}

///|
pub fn ForceIntOption::get_default(self : ForceIntOption) -> Int {
  self.default_value
}

///|
pub struct ForceDoubleOption {
  id : String
  default_value : Double
}

///|
pub fn new_force_double_option(
  id : String,
  default_value : Double,
) -> ForceDoubleOption {
  { id, default_value }
}

///|
pub fn ForceDoubleOption::get_id(self : ForceDoubleOption) -> String {
  self.id
}

///|
pub fn ForceDoubleOption::get_default(self : ForceDoubleOption) -> Double {
  self.default_value
}

///|
pub struct ForceModelOption {
  id : String
  default_value : ForceModelStrategy
}

///|
pub fn new_force_model_option(
  id : String,
  default_value : ForceModelStrategy,
) -> ForceModelOption {
  { id, default_value }
}

///|
pub fn ForceModelOption::get_id(self : ForceModelOption) -> String {
  self.id
}

///|
pub fn ForceModelOption::get_default(
  self : ForceModelOption,
) -> ForceModelStrategy {
  self.default_value
}

///|
pub struct ForcePaddingOption {
  id : String
  default_value : ElkPadding
}

///|
pub fn new_force_padding_option(
  id : String,
  default_value : ElkPadding,
) -> ForcePaddingOption {
  { id, default_value }
}

///|
pub fn ForcePaddingOption::get_id(self : ForcePaddingOption) -> String {
  self.id
}

///|
pub fn ForcePaddingOption::get_default(self : ForcePaddingOption) -> ElkPadding {
  self.default_value
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
  new_elk_padding_any(50.0),
)
