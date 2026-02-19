///|
pub(all) struct AbstractRandomListAccessor[T] {
  list : Array[T]
  provide_default : () -> T
}

///|
pub fn[T] new_abstract_random_list_accessor(
  provide_default : () -> T,
) -> AbstractRandomListAccessor[T] {
  { list: [], provide_default }
}

///|
pub fn[T] AbstractRandomListAccessor::get_list_item(
  self : AbstractRandomListAccessor[T],
  index : Int,
) -> T {
  if index < 0 {
    abort("Invalid index: \{index}")
  }
  self.ensure_list_size(index + 1)
  self.list[index]
}

///|
pub fn[T] AbstractRandomListAccessor::set_list_item(
  self : AbstractRandomListAccessor[T],
  index : Int,
  value : T,
) -> Unit {
  if index < 0 {
    abort("Invalid index: \{index}")
  }
  if index < self.list.length() {
    self.list[index] = value
  } else {
    self.ensure_list_size(index)
    self.list.push(value)
  }
}

///|
pub fn[T] AbstractRandomListAccessor::get_list_size(
  self : AbstractRandomListAccessor[T],
) -> Int {
  self.list.length()
}

///|
pub fn[T] AbstractRandomListAccessor::clear_list(
  self : AbstractRandomListAccessor[T],
) -> Unit {
  self.list.clear()
}

///|
pub fn[T] AbstractRandomListAccessor::ensure_list_size(
  self : AbstractRandomListAccessor[T],
  size : Int,
) -> Unit {
  let mut i = self.list.length()
  while i < size {
    self.list.push((self.provide_default)())
    i += 1
  }
}
