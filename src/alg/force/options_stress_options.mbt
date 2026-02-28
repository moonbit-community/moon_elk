///|
pub enum StressDimension {
  StressDimensionXY
  StressDimensionX
  StressDimensionY
}

///|
pub fn stress_dimension_from_int(value : Int) -> StressDimension {
  match value {
    1 => StressDimensionX
    2 => StressDimensionY
    _ => StressDimensionXY
  }
}

///|
pub let stress_interactive : ForceBoolOption = force_interactive

///|
pub let stress_omit_node_micro_layout : ForceBoolOption = force_omit_node_micro_layout

///|
pub let stress_fixed : ForceBoolOption = new_force_bool_option(
  "org.eclipse.elk.stress.fixed", false,
)

///|
pub let stress_desired_edge_length : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.stress.desiredEdgeLength", 100.0,
)

///|
pub let stress_dimension : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.stress.dimension", 0,
)

///|
pub let stress_epsilon : ForceDoubleOption = new_force_double_option(
  "org.eclipse.elk.stress.epsilon", 0.001,
)

///|
pub let stress_iteration_limit : ForceIntOption = new_force_int_option(
  "org.eclipse.elk.stress.iterationLimit", 2147483647,
)
