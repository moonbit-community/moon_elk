///|
pub enum FParticle {
  Node(FNode)
  Label(FLabel)
  Bendpoint(FBendpoint)
}

///|
pub fn fparticle_displacement(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_displacement(node)
    Label(label) => flabel_displacement(label)
    Bendpoint(bendpoint) => fbendpoint_displacement(bendpoint)
  }
}

///|
pub fn fparticle_position(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_position(node)
    Label(label) => flabel_position(label)
    Bendpoint(bendpoint) => fbendpoint_position(bendpoint)
  }
}

///|
pub fn fparticle_size(particle : FParticle) -> KVector {
  match particle {
    Node(node) => fnode_size(node)
    Label(label) => flabel_size(label)
    Bendpoint(bendpoint) => fbendpoint_size(bendpoint)
  }
}

///|
pub fn fparticle_radius(particle : FParticle) -> Double {
  fparticle_size(particle).length() / 2.0
}

///|
pub fn fparticle_get_int_property(
  particle : FParticle,
  property : ForceIntOption,
) -> Int {
  match particle {
    Node(node) => fnode_get_int_property(node, property)
    _ => property.get_default()
  }
}
