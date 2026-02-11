///|
fn bi_linked_int_key(value : Int?) -> Int {
  match value {
    Some(key) => key
    None => -1
  }
}

///|
test "BiLinkedHashMultiMap put updates prior value key and preserves key insertion order" {
  let map : BiLinkedHashMultiMap[Int] = new_bi_linked_hash_multi_map()
  map.put(3, 30)
  map.put(1, 10)
  map.put(3, 31)

  assert_eq(map.key_set(), [3, 1])
  assert_eq(map.get_values(3), [30, 31])
  assert_eq(map.get_values(1), [10])

  map.put(1, 30)
  assert_eq(map.get_values(3), [31])
  assert_eq(map.get_values(1), [10, 30])
  assert_eq(bi_linked_int_key(map.get_key(30)), 1)
}

///|
test "BiLinkedHashMultiMap put_all and key extrema checks match upstream semantics" {
  let map : BiLinkedHashMultiMap[String] = new_bi_linked_hash_multi_map()
  map.put_all(2, ["a", "b"])
  map.put_all(5, ["x"])
  map.put_all(0, ["z"])

  assert_eq(map.get_values(2), ["a", "b"])
  assert_eq(map.get_values(99), [])

  assert_false(map.is_maximal_key(2))
  assert_true(map.is_maximal_key(5))
  assert_true(map.is_minimal_key(0))
  assert_false(map.is_minimal_key(2))
}
