///|
pub(all) struct IFilter[C, T] {
  eligible_for_attachment_fn : (C) -> Bool raise
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit raise
  cleanup_fn : () -> Unit raise
}

///|
pub fn[C, T] new_filter(
  eligible_for_attachment_fn : (C) -> Bool raise,
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit raise,
  cleanup_fn : () -> Unit raise,
) -> IFilter[C, T] {
  { eligible_for_attachment_fn, preprocess_fn, cleanup_fn }
}

///|
pub fn[C, T] new_filter_with_default_lifecycle(
  eligible_for_attachment_fn : (C) -> Bool raise,
) -> IFilter[C, T] {
  new_filter(
    eligible_for_attachment_fn,
    (_provider, _include_hierarchy) => (),
    () => (),
  )
}

///|
pub fn[C, T] IFilter::eligible_for_attachment(
  self : IFilter[C, T],
  comment : C,
) -> Bool raise {
  (self.eligible_for_attachment_fn)(comment)
}

///|
pub fn[C, T] IFilter::preprocess(
  self : IFilter[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit raise {
  (self.preprocess_fn)(data_provider, include_hierarchy)
}

///|
pub fn[C, T] IFilter::cleanup(self : IFilter[C, T]) -> Unit raise {
  (self.cleanup_fn)()
}
