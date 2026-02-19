///|
pub struct IEditPartFilter {
  filter_fn : (GmfEditPart) -> Bool
}

///|
pub fn new_i_edit_part_filter(
  filter_fn : (GmfEditPart) -> Bool,
) -> IEditPartFilter {
  { filter_fn, }
}

///|
pub fn IEditPartFilter::filter(
  self : IEditPartFilter,
  edit_part : GmfEditPart,
) -> Bool {
  (self.filter_fn)(edit_part)
}

///|
pub fn new_i_edit_part_filter_default_impl() -> IEditPartFilter {
  new_i_edit_part_filter(_ => true)
}
