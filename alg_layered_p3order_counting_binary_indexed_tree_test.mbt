///|
test "BinaryIndexedTree sum before index" {
  let ft = new_binary_indexed_tree(5)
  ft.add(1)
  ft.add(2)
  ft.add(1)

  assert_eq(ft.rank(1), 0)
  assert_eq(ft.rank(2), 2)
}

///|
test "BinaryIndexedTree size reflects number of elements" {
  let ft = new_binary_indexed_tree(5)
  ft.add(2)
  ft.add(1)
  ft.add(1)

  assert_eq(ft.size(), 3)
}

///|
test "BinaryIndexedTree remove all entries at one index" {
  let ft = new_binary_indexed_tree(5)
  ft.add(0)
  ft.add(2)
  ft.add(1)
  ft.add(1)

  ft.remove_all(1)

  assert_eq(ft.size(), 2)
  assert_eq(ft.rank(2), 1)

  ft.remove_all(1)

  assert_eq(ft.size(), 2)
  assert_eq(ft.rank(2), 1)
}
