///|
pub enum NodeFlexibility {
  NfNone
  NfPortPosition
  NfNodeSizeWhereSpacePermits
  NfNodeSize
}

///|
pub fn NodeFlexibility::is_flexible_size(self : NodeFlexibility) -> Bool {
  match self {
    NfNodeSize => true
    _ => false
  }
}

///|
pub fn NodeFlexibility::is_flexible_size_where_space_permits(
  self : NodeFlexibility,
) -> Bool {
  match self {
    NfNodeSizeWhereSpacePermits => true
    NfNodeSize => true
    _ => false
  }
}

///|
pub fn NodeFlexibility::is_flexible_ports(self : NodeFlexibility) -> Bool {
  match self {
    NfPortPosition => true
    NfNodeSizeWhereSpacePermits => true
    NfNodeSize => true
    _ => false
  }
}

///|
pub fn NodeFlexibility::is_at_least(
  self : NodeFlexibility,
  nf : NodeFlexibility,
) -> Bool {
  match self {
    NfNodeSize => NodeFlexibility::is_flexible_size(nf)
    // Upstream Java falls through here and returns nf.isFlexiblePorts().
    NfNodeSizeWhereSpacePermits => NodeFlexibility::is_flexible_ports(nf)
    NfPortPosition => NodeFlexibility::is_flexible_ports(nf)
    NfNone => true
  }
}

///|
pub fn node_flexibility_flags() -> Array[Bool] {
  [
    NodeFlexibility::is_flexible_size(NfNone),
    NodeFlexibility::is_flexible_size(NfPortPosition),
    NodeFlexibility::is_flexible_size(NfNodeSizeWhereSpacePermits),
    NodeFlexibility::is_flexible_size(NfNodeSize),
    NodeFlexibility::is_flexible_size_where_space_permits(NfNone),
    NodeFlexibility::is_flexible_size_where_space_permits(NfPortPosition),
    NodeFlexibility::is_flexible_size_where_space_permits(
      NfNodeSizeWhereSpacePermits,
    ),
    NodeFlexibility::is_flexible_size_where_space_permits(NfNodeSize),
    NodeFlexibility::is_flexible_ports(NfNone),
    NodeFlexibility::is_flexible_ports(NfPortPosition),
    NodeFlexibility::is_flexible_ports(NfNodeSizeWhereSpacePermits),
    NodeFlexibility::is_flexible_ports(NfNodeSize),
  ]
}

///|
pub fn node_flexibility_is_at_least_values() -> Array[Bool] {
  [
    NodeFlexibility::is_at_least(NfNodeSize, NfNone),
    NodeFlexibility::is_at_least(NfNodeSize, NfPortPosition),
    NodeFlexibility::is_at_least(NfNodeSize, NfNodeSizeWhereSpacePermits),
    NodeFlexibility::is_at_least(NfNodeSize, NfNodeSize),
    NodeFlexibility::is_at_least(NfNodeSizeWhereSpacePermits, NfNone),
    NodeFlexibility::is_at_least(NfNodeSizeWhereSpacePermits, NfPortPosition),
    NodeFlexibility::is_at_least(
      NfNodeSizeWhereSpacePermits,
      NfNodeSizeWhereSpacePermits,
    ),
    NodeFlexibility::is_at_least(NfNodeSizeWhereSpacePermits, NfNodeSize),
    NodeFlexibility::is_at_least(NfPortPosition, NfNone),
    NodeFlexibility::is_at_least(NfPortPosition, NfPortPosition),
    NodeFlexibility::is_at_least(NfPortPosition, NfNodeSizeWhereSpacePermits),
    NodeFlexibility::is_at_least(NfPortPosition, NfNodeSize),
    NodeFlexibility::is_at_least(NfNone, NfNone),
    NodeFlexibility::is_at_least(NfNone, NfPortPosition),
    NodeFlexibility::is_at_least(NfNone, NfNodeSizeWhereSpacePermits),
    NodeFlexibility::is_at_least(NfNone, NfNodeSize),
  ]
}
