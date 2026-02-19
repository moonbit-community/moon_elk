///|
pub type MrtreeLabel = Int

///|
priv struct MrtreeLabelData {
  edge : MrtreeEdge
  text : String
  position : @core.KVector
  size : @core.KVector
}

///|
let mrtree_label_store : Ref[Array[MrtreeLabelData]] = Ref::new([])

///|
fn checked_mrtree_label(label : MrtreeLabel) -> Unit {
  if label < 0 || label >= mrtree_label_store.val.length() {
    abort("invalid mrtree label id")
  }
}

///|
pub fn new_mrtree_label(edge : MrtreeEdge, text : String) -> MrtreeLabel {
  checked_mrtree_edge(edge)
  let label = mrtree_label_store.val.length()
  mrtree_label_store.val.push({
    edge,
    text,
    position: @core.new_kvector(),
    size: @core.new_kvector(),
  })
  let edge_data = mrtree_edge_store.val[edge]
  edge_data.labels.push(label)
  set_mrtree_edge_data(edge, edge_data)
  label
}

///|
pub fn mrtree_label_text(label : MrtreeLabel) -> String {
  checked_mrtree_label(label)
  mrtree_label_store.val[label].text
}

///|
pub fn mrtree_label_edge(label : MrtreeLabel) -> MrtreeEdge {
  checked_mrtree_label(label)
  mrtree_label_store.val[label].edge
}

///|
pub fn mrtree_label_position(label : MrtreeLabel) -> @core.KVector {
  checked_mrtree_label(label)
  mrtree_label_store.val[label].position
}

///|
pub fn mrtree_label_size(label : MrtreeLabel) -> @core.KVector {
  checked_mrtree_label(label)
  mrtree_label_store.val[label].size
}

///|
pub fn mrtree_label_to_string(label : MrtreeLabel) -> String {
  checked_mrtree_label(label)
  let label_data = mrtree_label_store.val[label]
  if label_data.text.is_empty() {
    "l[\{mrtree_edge_to_string(label_data.edge)}]"
  } else {
    "l_" + label_data.text
  }
}
