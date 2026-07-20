///|
test "greedy switch mock random matches Java nextLong and reseed nextBoolean" {
  let random1 = new_greedy_switch_mock_random_seeded(1)
  let next_long1 = random1.next_long()
  assert_eq(next_long1, -4964420948893066024L)
  random1.set_seed(next_long1)
  assert_eq(random1.next_boolean(), false)

  let random2 = new_greedy_switch_mock_random_seeded(2)
  let next_long2 = random2.next_long()
  assert_eq(next_long2, -4959463499243013640L)
  random2.set_seed(next_long2)
  assert_eq(random2.next_boolean(), true)

  let random3 = new_greedy_switch_mock_random_seeded(3)
  let next_long3 = random3.next_long()
  assert_eq(next_long3, -4961115986754665064L)
  random3.set_seed(next_long3)
  assert_eq(random3.next_boolean(), false)

  let random4 = new_greedy_switch_mock_random_seeded(4)
  let next_long4 = random4.next_long()
  assert_eq(next_long4, -4969378402838085704L)
  random4.set_seed(next_long4)
  assert_eq(random4.next_boolean(), true)

  let random5 = new_greedy_switch_mock_random_seeded(5)
  let next_long5 = random5.next_long()
  assert_eq(next_long5, -4971030886054769832L)
  random5.set_seed(next_long5)
  assert_eq(random5.next_boolean(), false)

  let random42 = new_greedy_switch_mock_random_seeded(42)
  let next_long42 = random42.next_long()
  assert_eq(next_long42, -5025562857975149833L)
  random42.set_seed(next_long42)
  assert_eq(random42.next_boolean(), false)

  let random99 = new_greedy_switch_mock_random_seeded(99)
  let next_long99 = random99.next_long()
  assert_eq(next_long99, -5119754439980850796L)
  random99.set_seed(next_long99)
  assert_eq(random99.next_boolean(), false)
}
