///|
pub struct IExplicitAttachmentProvider[C, T] {
  find_explicit_attachment_fn : (C) -> T?
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit
  cleanup_fn : () -> Unit
}

///|
pub fn[C, T] new_explicit_attachment_provider(
  find_explicit_attachment_fn : (C) -> T?,
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit,
  cleanup_fn : () -> Unit,
) -> IExplicitAttachmentProvider[C, T] {
  { find_explicit_attachment_fn, preprocess_fn, cleanup_fn }
}

///|
pub fn[C, T] new_explicit_attachment_provider_with_default_lifecycle(
  find_explicit_attachment_fn : (C) -> T?,
) -> IExplicitAttachmentProvider[C, T] {
  new_explicit_attachment_provider(
    find_explicit_attachment_fn,
    (_provider, _include_hierarchy) => (),
    () => (),
  )
}

///|
pub fn[C, T] IExplicitAttachmentProvider::find_explicit_attachment(
  self : IExplicitAttachmentProvider[C, T],
  comment : C,
) -> T? {
  (self.find_explicit_attachment_fn)(comment)
}

///|
pub fn[C, T] IExplicitAttachmentProvider::preprocess(
  self : IExplicitAttachmentProvider[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit {
  (self.preprocess_fn)(data_provider, include_hierarchy)
}

///|
pub fn[C, T] IExplicitAttachmentProvider::cleanup(
  self : IExplicitAttachmentProvider[C, T],
) -> Unit {
  (self.cleanup_fn)()
}
