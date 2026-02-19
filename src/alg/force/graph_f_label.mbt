///|
pub type FLabel = Int

///|
let flabel_store : Ref[Array[FLabelData]] = Ref::new([])

///|
priv struct FLabelData {
  edge : FEdge
  text : String
  displacement : @core.KVector
  position : @core.KVector
  size : @core.KVector
  bool_properties : Map[String, Bool]
  double_properties : Map[String, Double]
  mut origin : @graph.ElkLabel?
}

///|
fn checked_flabel(label : FLabel) -> Unit {
  if label < 0 || label >= flabel_store.val.length() {
    abort("invalid force label id")
  }
}

///|
fn set_flabel_data(label : FLabel, data : FLabelData) -> Unit {
  checked_flabel(label)
  flabel_store.val[label] = data
}

///|
pub fn new_flabel(edge : FEdge, text? : String = "") -> FLabel {
  checked_fedge(edge)
  let label = flabel_store.val.length()
  flabel_store.val.push({
    edge,
    text,
    displacement: @core.new_kvector(),
    position: @core.new_kvector(),
    size: @core.new_kvector(),
    bool_properties: {},
    double_properties: {},
    origin: None,
  })
  let edge_data = fedge_store.val[edge]
  edge_data.labels.push(label)
  set_fedge_data(edge, edge_data)
  label
}

///|
pub fn flabel_text(label : FLabel) -> String {
  checked_flabel(label)
  flabel_store.val[label].text
}

///|
pub fn flabel_edge(label : FLabel) -> FEdge {
  checked_flabel(label)
  flabel_store.val[label].edge
}

///|
pub fn flabel_displacement(label : FLabel) -> @core.KVector {
  checked_flabel(label)
  flabel_store.val[label].displacement
}

///|
pub fn flabel_position(label : FLabel) -> @core.KVector {
  checked_flabel(label)
  flabel_store.val[label].position
}

///|
pub fn flabel_size(label : FLabel) -> @core.KVector {
  checked_flabel(label)
  flabel_store.val[label].size
}

///|
pub fn flabel_radius(label : FLabel) -> Double {
  flabel_size(label).length() / 2.0
}

///|
pub fn flabel_set_bool_property(
  label : FLabel,
  property : ForceBoolOption,
  value : Bool,
) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.bool_properties[property.get_id()] = value
  set_flabel_data(label, data)
}

///|
pub fn flabel_get_bool_property(
  label : FLabel,
  property : ForceBoolOption,
) -> Bool {
  checked_flabel(label)
  let data = flabel_store.val[label]
  match data.bool_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn flabel_set_double_property(
  label : FLabel,
  property : ForceDoubleOption,
  value : Double,
) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.double_properties[property.get_id()] = value
  set_flabel_data(label, data)
}

///|
pub fn flabel_get_double_property(
  label : FLabel,
  property : ForceDoubleOption,
) -> Double {
  checked_flabel(label)
  let data = flabel_store.val[label]
  match data.double_properties.get(property.get_id()) {
    Some(value) => value
    None => property.get_default()
  }
}

///|
pub fn flabel_set_origin(label : FLabel, origin : @graph.ElkLabel) -> Unit {
  checked_flabel(label)
  let data = flabel_store.val[label]
  data.origin = Some(origin)
  set_flabel_data(label, data)
}

///|
pub fn flabel_origin(label : FLabel) -> @graph.ElkLabel? {
  checked_flabel(label)
  flabel_store.val[label].origin
}

///|
pub fn flabel_refresh_position(label : FLabel) -> Unit {
  checked_flabel(label)
  let edge = flabel_edge(label)
  let source = match fedge_source(edge) {
    Some(source) => source
    None => return
  }
  let target = match fedge_target(edge) {
    Some(target) => target
    None => return
  }
  let source_position = fnode_position(source)
  let target_position = fnode_position(target)
  if flabel_get_bool_property(label, force_edge_labels_inline) {
    let source_to_target = target_position
      .clone()
      .sub(source_position)
      .scale(0.5)
    let to_label_center = flabel_size(label).clone().scale(0.5)
    let new_position = source_position
      .clone()
      .add(source_to_target)
      .sub(to_label_center)
    ignore(flabel_position(label).set(new_position))
  } else {
    let spacing = fedge_get_double_property(edge, force_spacing_edge_label)
    let position = flabel_position(label)
    if source_position.x >= target_position.x {
      if source_position.y >= target_position.y {
        position.x = target_position.x +
          (source_position.x - target_position.x) / 2.0 +
          spacing
        position.y = target_position.y +
          (source_position.y - target_position.y) / 2.0 -
          spacing -
          flabel_size(label).y
      } else {
        position.x = target_position.x +
          (source_position.x - target_position.x) / 2.0 +
          spacing
        position.y = source_position.y +
          (target_position.y - source_position.y) / 2.0 +
          spacing
      }
    } else if source_position.y >= target_position.y {
      position.x = source_position.x +
        (target_position.x - source_position.x) / 2.0 +
        spacing
      position.y = target_position.y +
        (source_position.y - target_position.y) / 2.0 +
        spacing
    } else {
      position.x = source_position.x +
        (target_position.x - source_position.x) / 2.0 +
        spacing
      position.y = source_position.y +
        (target_position.y - source_position.y) / 2.0 -
        spacing -
        flabel_size(label).y
    }
  }
}
