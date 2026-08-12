///|
/// Apply the host label manager and return the combined size required by the
/// transformed labels. The helper lives with the shared LLabel model because
/// both generic label processing and self-loop state use the same operation.
pub fn label_management_processor_do_manage_labels(
  label_manager : @core.ILabelManager,
  labels : Array[LLabel],
  target_width : Double,
  label_label_spacing : Double,
  vertical_layout : Bool,
) -> @core.KVector {
  let required_label_space = @core.new_kvector()
  if labels.is_empty() {
    return required_label_space
  }
  for label in labels {
    let label_size = label.get_size()
    match label.get_origin_identifier() {
      Some(origin) =>
        match label_manager.manage_label_size(origin, target_width) {
          Some(new_size) =>
            if vertical_layout {
              label_size.x = new_size.y
              label_size.y = new_size.x
            } else {
              label_size.x = new_size.x
              label_size.y = new_size.y
            }
          None => ()
        }
      None => ()
    }
    if vertical_layout {
      required_label_space.x = required_label_space.x +
        label_label_spacing +
        label.get_size().x
      if label_size.y > required_label_space.y {
        required_label_space.y = label_size.y
      }
    } else {
      if label_size.x > required_label_space.x {
        required_label_space.x = label_size.x
      }
      required_label_space.y = required_label_space.y +
        label_label_spacing +
        label.get_size().y
    }
  }
  if vertical_layout {
    required_label_space.x = required_label_space.x - label_label_spacing
  } else {
    required_label_space.y = required_label_space.y - label_label_spacing
  }
  required_label_space
}
