///|
let core_comments_next_matcher_id_ref : Ref[Int] = Ref::new(0)

///|
fn core_comments_next_matcher_id() -> Int {
  let id = core_comments_next_matcher_id_ref.val
  core_comments_next_matcher_id_ref.val = id + 1
  id
}

///|
pub struct IMatcher[C, T] {
  id : Int
  raw_fn : (C, T) -> Double
  normalized_fn : (C, T) -> Double
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit
  cleanup_fn : () -> Unit
}

///|
pub fn[C, T] new_matcher(
  raw_fn : (C, T) -> Double,
  normalized_fn : (C, T) -> Double,
  preprocess_fn : (IDataProvider[C, T], Bool) -> Unit,
  cleanup_fn : () -> Unit,
) -> IMatcher[C, T] {
  {
    id: core_comments_next_matcher_id(),
    raw_fn,
    normalized_fn,
    preprocess_fn,
    cleanup_fn,
  }
}

///|
pub fn[C, T] new_matcher_with_default_lifecycle(
  raw_fn : (C, T) -> Double,
  normalized_fn : (C, T) -> Double,
) -> IMatcher[C, T] {
  new_matcher(raw_fn, normalized_fn, (_provider, _include_hierarchy) => (), () => {
    ()
  })
}

///|
pub fn[C, T] IMatcher::raw(
  self : IMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  (self.raw_fn)(comment, target)
}

///|
pub fn[C, T] IMatcher::normalized(
  self : IMatcher[C, T],
  comment : C,
  target : T,
) -> Double {
  (self.normalized_fn)(comment, target)
}

///|
pub fn[C, T] IMatcher::preprocess(
  self : IMatcher[C, T],
  data_provider : IDataProvider[C, T],
  include_hierarchy : Bool,
) -> Unit {
  (self.preprocess_fn)(data_provider, include_hierarchy)
}

///|
pub fn[C, T] IMatcher::cleanup(self : IMatcher[C, T]) -> Unit {
  (self.cleanup_fn)()
}

///|
pub fn[C, T] IMatcher::matcher_id(self : IMatcher[C, T]) -> Int {
  self.id
}
