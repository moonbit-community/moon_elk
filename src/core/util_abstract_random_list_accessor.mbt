///|
priv suberror RandomListAccessorException {
  RandomListAccessorException(String)
} derive(Debug, ToJson)

///|
fn random_list_accessor_raise(
  message : String,
) -> Unit raise RandomListAccessorException {
  raise RandomListAccessorException(message)
}

///|
fn random_list_accessor_exception_message(
  err : RandomListAccessorException,
) -> String {
  match err {
    RandomListAccessorException(message) => message
  }
}

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
    try random_list_accessor_raise("Invalid index: \{index}") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          random_list_accessor_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return (self.provide_default)()
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
    try random_list_accessor_raise("Invalid index: \{index}") catch {
      err =>
        layout_runtime_report_unsupported_configuration(
          random_list_accessor_exception_message(err),
        )
    } noraise {
      _ => ()
    }
    return
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
