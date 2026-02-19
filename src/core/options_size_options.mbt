///|
pub(all) enum SizeOptions {
  DefaultMinimumSize
  MinimumSizeAccountsForPadding
  ComputePadding
  OutsideNodeLabelsOverhang
  PortsOverhang
  UniformPortSpacing
  SpaceEfficientPortLabels
  ForceTabularNodeLabels
  Asymmetrical
}

///|
pub fn size_options_values() -> Array[SizeOptions] {
  [
    DefaultMinimumSize,
    MinimumSizeAccountsForPadding,
    ComputePadding,
    OutsideNodeLabelsOverhang,
    PortsOverhang,
    UniformPortSpacing,
    SpaceEfficientPortLabels,
    ForceTabularNodeLabels,
    Asymmetrical,
  ]
}

///|
pub fn size_options_to_string(option : SizeOptions) -> String {
  match option {
    DefaultMinimumSize => "DEFAULT_MINIMUM_SIZE"
    MinimumSizeAccountsForPadding => "MINIMUM_SIZE_ACCOUNTS_FOR_PADDING"
    ComputePadding => "COMPUTE_PADDING"
    OutsideNodeLabelsOverhang => "OUTSIDE_NODE_LABELS_OVERHANG"
    PortsOverhang => "PORTS_OVERHANG"
    UniformPortSpacing => "UNIFORM_PORT_SPACING"
    SpaceEfficientPortLabels => "SPACE_EFFICIENT_PORT_LABELS"
    ForceTabularNodeLabels => "FORCE_TABULAR_NODE_LABELS"
    Asymmetrical => "ASYMMETRICAL"
  }
}

///|
pub fn size_options_value_of(i : Int) -> SizeOptions {
  size_options_values()[i]
}
