///|
pub struct MrtreeLabel {
  priv data : MrtreeLabelData
}

///|
pub impl Eq for MrtreeLabel with fn equal(self, other) {
  physical_equal(self, other)
}

///|
pub impl @debug.Debug for MrtreeLabel with fn to_repr(self) {
  Repr(mrtree_label_to_string(self))
}

///|
priv struct MrtreeLabelData {
  edge : MrtreeEdge
  text : String
  position : @core.KVector
  size : @core.KVector
}

///|
pub fn new_mrtree_label(edge : MrtreeEdge, text : String) -> MrtreeLabel {
  let label : MrtreeLabel = {
    data: {
      edge,
      text,
      position: @core.new_kvector(),
      size: @core.new_kvector(),
    },
  }
  let edge_data = edge.data
  edge_data.labels.push(label)
  set_mrtree_edge_data(edge, edge_data)
  label
}

///|
pub fn mrtree_label_text(label : MrtreeLabel) -> String {
  label.data.text
}

///|
pub fn mrtree_label_edge(label : MrtreeLabel) -> MrtreeEdge {
  label.data.edge
}

///|
pub fn mrtree_label_position(label : MrtreeLabel) -> @core.KVector {
  label.data.position
}

///|
pub fn mrtree_label_size(label : MrtreeLabel) -> @core.KVector {
  label.data.size
}

///|
pub fn mrtree_label_to_string(label : MrtreeLabel) -> String {
  let label_data = label.data
  if label_data.text.is_empty() {
    "l[\{mrtree_edge_to_string(label_data.edge)}]"
  } else {
    "l_" + label_data.text
  }
}
