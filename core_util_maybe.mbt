///|
pub struct Maybe[T] {
  mut object : T?
}

///|
pub fn[T] maybe_create() -> Maybe[T] {
  { object: None }
}

///|
pub fn[T] maybe_of(object : T) -> Maybe[T] {
  { object: Some(object) }
}

///|
pub fn[T] Maybe::set(self : Maybe[T], object : T?) -> Unit {
  self.object = object
}

///|
pub fn[T] Maybe::get(self : Maybe[T]) -> T? {
  self.object
}

///|
pub fn[T] Maybe::clear(self : Maybe[T]) -> Unit {
  self.object = None
}

///|
pub fn[T] Maybe::is_empty(self : Maybe[T]) -> Bool {
  self.object is None
}

///|
pub fn[T : Eq] Maybe::equals(self : Maybe[T], other : Maybe[T]) -> Bool {
  self.object == other.object
}

///|
pub fn[T : Hash] Maybe::hash_code(self : Maybe[T]) -> Int {
  self.object.hash()
}

///|
pub fn[T : Show] Maybe::to_string(self : Maybe[T]) -> String {
  match self.object {
    Some(value) => "maybe(\{value.to_string()})"
    None => "maybe(null)"
  }
}
