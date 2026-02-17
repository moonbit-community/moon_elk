///|
fn[C, T] size_filter_bounds_provider_or_abort(
  filter : SizeFilter[C, T],
) -> IBoundsProvider[C, T] {
  match filter.bounds_provider {
    Some(provider) => provider
    None => abort("A bounds provider is required.")
  }
}

///|
pub struct SizeFilter[C, T] {
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
) -> SizeFilter[C, T] {
  if area < 0.0 {
    abort("Maximum area must be >= 0.")
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
pub fn[C, T] SizeFilter::check_configuration(self : SizeFilter[C, T]) -> Unit {
  ignore(size_filter_bounds_provider_or_abort(self))
}

///|
pub fn[C, T] SizeFilter::preprocess(
  self : SizeFilter[C, T],
  _data_provider : IDataProvider[C, T],
  _include_hierarchy : Bool,
) -> Unit {
  self.check_configuration()
}

///|
pub fn[C, T] SizeFilter::eligible_for_attachment(
  self : SizeFilter[C, T],
  comment : C,
) -> Bool {
  let bounds_provider = size_filter_bounds_provider_or_abort(self)
  match bounds_provider.bounds_for_comment(comment) {
    Some(bounds) => bounds.height * bounds.width <= self.max_area
    None => false
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
