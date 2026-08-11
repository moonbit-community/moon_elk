///|
pub struct IEditPartFilter {
  filter_fn : ((GmfEditPart) -> Bool raise)?
  accept_all : Bool
}

///|
pub fn new_i_edit_part_filter(
  filter_fn : (GmfEditPart) -> Bool raise,
) -> IEditPartFilter {
  { filter_fn: Some(filter_fn), accept_all: false }
}

///|
pub fn IEditPartFilter::filter(
  self : IEditPartFilter,
  edit_part : GmfEditPart,
) -> Bool raise {
  match self.filter_fn {
    Some(filter) => filter(edit_part)
    None => self.accept_all
  }
}

///|
pub fn new_i_edit_part_filter_default_impl() -> IEditPartFilter {
  { filter_fn: None, accept_all: true }
}
