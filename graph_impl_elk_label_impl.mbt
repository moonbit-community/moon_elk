///|
pub type ElkLabelImpl = ElkLabel

///|
pub fn new_elk_label_impl(parent? : ElkLabelParent? = None) -> ElkLabelImpl {
  create_label(parent)
}
