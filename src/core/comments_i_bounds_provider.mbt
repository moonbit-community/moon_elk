///|
fn[C : Eq] bounds_provider_cached_lookup(
  cache : Array[(C, ElkRectangle?)],
  key : C,
) -> (Bool, ElkRectangle?) {
  for cache_entry in cache {
    let (cached_key, cached_bounds) = cache_entry
    if cached_key == key {
      return (true, cached_bounds)
    }
  }
  (false, None)
}

///|
pub(all) struct IBoundsProvider[C, T] {
  bounds_for_comment_fn : (C) -> ElkRectangle?
  bounds_for_target_fn : (T) -> ElkRectangle?
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit
  cleanup_fn : () -> Unit
}

///|
pub fn[C, T] new_bounds_provider(
  bounds_for_comment_fn : (C) -> ElkRectangle?,
  bounds_for_target_fn : (T) -> ElkRectangle?,
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit,
  cleanup_fn : () -> Unit,
) -> IBoundsProvider[C, T] {
  { bounds_for_comment_fn, bounds_for_target_fn, preprocess_fn, cleanup_fn }
}

///|
pub fn[C, T] new_bounds_provider_with_default_lifecycle(
  bounds_for_comment_fn : (C) -> ElkRectangle?,
  bounds_for_target_fn : (T) -> ElkRectangle?,
) -> IBoundsProvider[C, T] {
  new_bounds_provider(
    bounds_for_comment_fn,
    bounds_for_target_fn,
    (_data_provider, _include_hierarchy) => (),
    () => (),
  )
}

///|
pub fn[C, T] IBoundsProvider::bounds_for_comment(
  self : IBoundsProvider[C, T],
  comment : C,
) -> ElkRectangle? {
  (self.bounds_for_comment_fn)(comment)
}

///|
pub fn[C, T] IBoundsProvider::bounds_for_target(
  self : IBoundsProvider[C, T],
  target : T,
) -> ElkRectangle? {
  (self.bounds_for_target_fn)(target)
}

///|
pub fn[C, T] IBoundsProvider::preprocess(
  self : IBoundsProvider[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit {
  (self.preprocess_fn)(data_provider, include_hierarchy)
}

///|
pub fn[C, T] IBoundsProvider::cleanup(self : IBoundsProvider[C, T]) -> Unit {
  (self.cleanup_fn)()
}

///|
pub fn[C : Eq, T : Eq] IBoundsProvider::cached(
  self : IBoundsProvider[C, T],
) -> IBoundsProvider[C, T] {
  let comment_bounds_cache_ref : Ref[Array[(C, ElkRectangle?)]] = Ref([])
  let target_bounds_cache_ref : Ref[Array[(T, ElkRectangle?)]] = Ref([])

  new_bounds_provider(
    comment => {
      let (found, bounds) = bounds_provider_cached_lookup(
        comment_bounds_cache_ref.val,
        comment,
      )
      if found {
        bounds
      } else {
        let computed = self.bounds_for_comment(comment)
        comment_bounds_cache_ref.val.push((comment, computed))
        computed
      }
    },
    target => {
      let (found, bounds) = bounds_provider_cached_lookup(
        target_bounds_cache_ref.val,
        target,
      )
      if found {
        bounds
      } else {
        let computed = self.bounds_for_target(target)
        target_bounds_cache_ref.val.push((target, computed))
        computed
      }
    },
    (data_provider, include_hierarchy) => {
      self.preprocess(data_provider, include_hierarchy)
    },
    () => {
      comment_bounds_cache_ref.val = []
      target_bounds_cache_ref.val = []
      self.cleanup()
    },
  )
}
