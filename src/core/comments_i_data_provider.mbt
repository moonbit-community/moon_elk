///|
fn[C : Eq, T] data_provider_cached_targets_get(
  cache : Array[(C, Array[T])],
  comment : C,
) -> Array[T]? {
  for cache_entry in cache {
    let (cached_comment, cached_targets) = cache_entry
    if cached_comment == comment {
      return Some(cached_targets)
    }
  }
  None
}

///|
pub(all) struct IDataProvider[C, T] {
  provide_comments_fn : () -> Array[C]
  provide_targets_fn : () -> Array[T]
  provide_targets_for_fn : (C) -> Array[T]
  provide_sub_hierarchies_fn : () -> Array[IDataProvider[C, T]]
  attach_fn : (C, T) -> Unit
}

///|
pub fn[C, T] new_data_provider(
  provide_comments_fn : () -> Array[C],
  provide_targets_fn : () -> Array[T],
  provide_targets_for_fn : (C) -> Array[T],
  provide_sub_hierarchies_fn : () -> Array[IDataProvider[C, T]],
  attach_fn : (C, T) -> Unit,
) -> IDataProvider[C, T] {
  {
    provide_comments_fn,
    provide_targets_fn,
    provide_targets_for_fn,
    provide_sub_hierarchies_fn,
    attach_fn,
  }
}

///|
pub fn[C, T] new_data_provider_with_default_targets_for(
  provide_comments_fn : () -> Array[C],
  provide_targets_fn : () -> Array[T],
  provide_sub_hierarchies_fn : () -> Array[IDataProvider[C, T]],
  attach_fn : (C, T) -> Unit,
) -> IDataProvider[C, T] {
  new_data_provider(
    provide_comments_fn,
    provide_targets_fn,
    _comment => provide_targets_fn(),
    provide_sub_hierarchies_fn,
    attach_fn,
  )
}

///|
pub fn[C, T] IDataProvider::provide_comments(
  self : IDataProvider[C, T],
) -> Array[C] {
  (self.provide_comments_fn)()
}

///|
pub fn[C, T] IDataProvider::provide_targets(
  self : IDataProvider[C, T],
) -> Array[T] {
  (self.provide_targets_fn)()
}

///|
pub fn[C, T] IDataProvider::provide_targets_for(
  self : IDataProvider[C, T],
  comment : C,
) -> Array[T] {
  (self.provide_targets_for_fn)(comment)
}

///|
pub fn[C, T] IDataProvider::provide_sub_hierarchies(
  self : IDataProvider[C, T],
) -> Array[IDataProvider[C, T]] {
  (self.provide_sub_hierarchies_fn)()
}

///|
pub fn[C, T] IDataProvider::attach(
  self : IDataProvider[C, T],
  comment : C,
  target : T,
) -> Unit {
  (self.attach_fn)(comment, target)
}

///|
pub fn[C : Eq, T] IDataProvider::cached(
  self : IDataProvider[C, T],
) -> IDataProvider[C, T] {
  let comments_cache_ref : Ref[Array[C]?] = Ref::new(None)
  let targets_cache_ref : Ref[Array[T]?] = Ref::new(None)
  let comment_targets_cache_ref : Ref[Array[(C, Array[T])]] = Ref::new([])
  let sub_provider_cache_ref : Ref[Array[IDataProvider[C, T]]?] = Ref::new(None)

  new_data_provider(
    () => {
      match comments_cache_ref.val {
        Some(comments) => comments
        None => {
          let comments = self.provide_comments()
          comments_cache_ref.val = Some(comments)
          comments
        }
      }
    },
    () => {
      match targets_cache_ref.val {
        Some(targets) => targets
        None => {
          let targets = self.provide_targets()
          targets_cache_ref.val = Some(targets)
          targets
        }
      }
    },
    comment => {
      match
        data_provider_cached_targets_get(comment_targets_cache_ref.val, comment) {
        Some(targets) => targets
        None => {
          let targets = self.provide_targets_for(comment)
          comment_targets_cache_ref.val.push((comment, targets))
          targets
        }
      }
    },
    () => {
      match sub_provider_cache_ref.val {
        Some(providers) => providers
        None => {
          let providers = []
          for provider in self.provide_sub_hierarchies() {
            providers.push(provider.cached())
          }
          sub_provider_cache_ref.val = Some(providers)
          providers
        }
      }
    },
    (comment, target) => self.attach(comment, target),
  )
}
