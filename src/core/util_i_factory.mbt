///|
pub(all) struct IFactory[T] {
  create_fn : () -> T
  destroy_fn : (T) -> Unit
}

///|
pub fn[T] new_factory(
  create_fn : () -> T,
  destroy_fn? : (T) -> Unit = _ => (),
) -> IFactory[T] {
  { create_fn, destroy_fn }
}

///|
pub fn[T] IFactory::create(self : IFactory[T]) -> T {
  (self.create_fn)()
}

///|
pub fn[T] IFactory::destroy(self : IFactory[T], obj : T) -> Unit {
  (self.destroy_fn)(obj)
}
