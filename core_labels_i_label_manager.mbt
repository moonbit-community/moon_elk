///|
pub struct ILabelManager {
  manage_label_size_fn : (String, Double) -> KVector?
}

///|
pub fn new_i_label_manager(
  manage_label_size_fn : (String, Double) -> KVector?,
) -> ILabelManager {
  { manage_label_size_fn, }
}

///|
pub fn ILabelManager::manage_label_size(
  self : ILabelManager,
  label_origin : String,
  target_width : Double,
) -> KVector? {
  (self.manage_label_size_fn)(label_origin, target_width)
}
