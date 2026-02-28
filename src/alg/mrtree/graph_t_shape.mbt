///|
pub enum MrtreeShape {
  MrtreeNodeShape(MrtreeNode)
  MrtreeLabelShape(MrtreeLabel)
}

///|
pub fn new_mrtree_node_shape(node : MrtreeNode) -> MrtreeShape {
  MrtreeNodeShape(node)
}

///|
pub fn new_mrtree_label_shape(label : MrtreeLabel) -> MrtreeShape {
  MrtreeLabelShape(label)
}

///|
pub fn mrtree_shape_position(shape : MrtreeShape) -> @core.KVector {
  match shape {
    MrtreeNodeShape(node) => mrtree_node_position(node)
    MrtreeLabelShape(label) => mrtree_label_position(label)
  }
}

///|
pub fn mrtree_shape_size(shape : MrtreeShape) -> @core.KVector {
  match shape {
    MrtreeNodeShape(node) => mrtree_node_size(node)
    MrtreeLabelShape(label) => mrtree_label_size(label)
  }
}
