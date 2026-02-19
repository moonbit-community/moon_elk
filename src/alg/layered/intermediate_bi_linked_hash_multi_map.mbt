///|
pub struct BiLinkedHashMultiMap[V] {
  key_to_values : Map[Int, Array[V]]
  value_to_key : Map[V, Int]
  key_order : Array[Int]
}

///|
pub fn[V : Hash + Eq] new_bi_linked_hash_multi_map() -> BiLinkedHashMultiMap[V] {
  { key_to_values: {}, value_to_key: {}, key_order: [] }
}

///|
fn[T : Eq] bi_linked_remove_first(values : Array[T], target : T) -> Bool {
  for i in 0..<values.length() {
    if values[i] == target {
      ignore(values.remove(i))
      return true
    }
  }
  false
}

///|
pub fn[V : Hash + Eq] BiLinkedHashMultiMap::put_all(
  self : BiLinkedHashMultiMap[V],
  key : Int,
  values : Array[V],
) -> Unit {
  for value in values {
    self.put(key, value)
  }
}

///|
pub fn[V : Hash + Eq] BiLinkedHashMultiMap::put(
  self : BiLinkedHashMultiMap[V],
  key : Int,
  value : V,
) -> Unit {
  match self.value_to_key.get(value) {
    Some(old_key) =>
      match self.key_to_values.get(old_key) {
        Some(previous_values) =>
          ignore(bi_linked_remove_first(previous_values, value))
        None => ()
      }
    None => ()
  }

  if !self.key_to_values.contains(key) {
    self.key_to_values[key] = []
    self.key_order.push(key)
  }
  match self.key_to_values.get(key) {
    Some(current_values) => current_values.push(value)
    None => abort("key must exist after ensure_key")
  }
  self.value_to_key[value] = key
}

///|
pub fn[V : Hash + Eq] BiLinkedHashMultiMap::get_key(
  self : BiLinkedHashMultiMap[V],
  value : V,
) -> Int? {
  self.value_to_key.get(value)
}

///|
pub fn[V] BiLinkedHashMultiMap::get_values(
  self : BiLinkedHashMultiMap[V],
  key : Int,
) -> Array[V] {
  match self.key_to_values.get(key) {
    Some(values) => values
    None => []
  }
}

///|
pub fn[V] BiLinkedHashMultiMap::key_set(
  self : BiLinkedHashMultiMap[V],
) -> Array[Int] {
  self.key_order
}

///|
pub fn[V] BiLinkedHashMultiMap::is_maximal_key(
  self : BiLinkedHashMultiMap[V],
  key : Int,
) -> Bool {
  for other_key in self.key_order {
    if key < other_key {
      return false
    }
  }
  true
}

///|
pub fn[V] BiLinkedHashMultiMap::is_minimal_key(
  self : BiLinkedHashMultiMap[V],
  key : Int,
) -> Bool {
  for other_key in self.key_order {
    if key > other_key {
      return false
    }
  }
  true
}
