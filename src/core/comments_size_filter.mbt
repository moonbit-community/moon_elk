///|
pub suberror SizeFilterException {
  SizeFilterException(String)
} derive(Show, ToJson)

///|
fn[T] size_filter_raise(message : String) -> T raise SizeFilterException {
  raise SizeFilterException(message)
}

///|
fn size_filter_exception_message(err : SizeFilterException) -> String {
  match err {
    SizeFilterException(message) => message
  }
}

///|
fn[C, T] size_filter_bounds_provider_or_raise(
  filter : SizeFilter[C, T],
) -> IBoundsProvider[C, T] raise SizeFilterException {
  match filter.bounds_provider {
    Some(provider) => provider
    None => size_filter_raise("A bounds provider is required.")
  }
}

///|
pub(all) struct SizeFilter[C, T] {
  mut bounds_provider : IBoundsProvider[C, T]?
  mut max_area : Double
}

///|
pub fn[C, T] new_size_filter() -> SizeFilter[C, T] {
  { bounds_provider: None, max_area: -1.0 }
}

///|
pub fn[C, T] SizeFilter::with_maximum_area(
  self : SizeFilter[C, T],
  area : Double,
) -> SizeFilter[C, T] raise SizeFilterException {
  if area < 0.0 {
    size_filter_raise("Maximum area must be >= 0.")
  }

  self.max_area = area
  self
}

///|
pub fn[C, T] SizeFilter::with_bounds_provider(
  self : SizeFilter[C, T],
  provider : IBoundsProvider[C, T],
) -> SizeFilter[C, T] {
  self.bounds_provider = Some(provider)
  self
}

///|
pub fn[C, T] SizeFilter::check_configuration(
  self : SizeFilter[C, T],
) -> Unit raise SizeFilterException {
  ignore(size_filter_bounds_provider_or_raise(self))
}

///|
pub fn[C, T] SizeFilter::preprocess(
  self : SizeFilter[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  try self.check_configuration() catch {
    err =>
      layout_runtime_report_unsupported_configuration(
        size_filter_exception_message(err),
      )
  } noraise {
    _ => ()
  }
}

///|
fn[C, T] size_filter_eligible_for_attachment_impl(
  filter : SizeFilter[C, T],
  comment : C,
) -> Bool raise SizeFilterException {
  let bounds_provider = size_filter_bounds_provider_or_raise(filter)
  match bounds_provider.bounds_for_comment(comment) {
    Some(bounds) => bounds.height * bounds.width <= filter.max_area
    None => false
  }
}

///|
pub fn[C, T] SizeFilter::eligible_for_attachment(
  self : SizeFilter[C, T],
  comment : C,
) -> Bool {
  try size_filter_eligible_for_attachment_impl(self, comment) catch {
    err => {
      layout_runtime_report_unsupported_configuration(
        size_filter_exception_message(err),
      )
      false
    }
  } noraise {
    eligible => eligible
  }
}

///|
pub fn[C, T] SizeFilter::as_filter(self : SizeFilter[C, T]) -> IFilter[C, T] {
  new_filter(
    comment => self.eligible_for_attachment(comment),
    (data_provider, include_hierarchy) => {
      self.preprocess(data_provider, include_hierarchy)
    },
    () => (),
  )
}
