///|
pub(all) struct DefaultFactory[T] {
  create_fn : () -> T
}

///|
pub fn[T] new_default_factory(create_fn : () -> T) -> DefaultFactory[T] {
  { create_fn, }
}

///|
pub fn[T] DefaultFactory::create(self : DefaultFactory[T]) -> T {
  (self.create_fn)()
}

///|
pub fn[T] DefaultFactory::destroy(self : DefaultFactory[T], obj : T) -> Unit {
  ignore(self)
  ignore(obj)
}

///|
pub fn[T] DefaultFactory::as_factory(self : DefaultFactory[T]) -> IFactory[T] {
  new_factory(() => self.create(), destroy_fn=obj => self.destroy(obj))
}
