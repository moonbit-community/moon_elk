///|
test "KVectorChain testParse" {
  let v0 = new_kvector_xy(5.0, 50.0)
  let v1 = new_kvector_xy(10.0, 50.0)
  let v2 = new_kvector_xy(30.0, 50.0)
  let kv = new_kvector_chain()
  kv.parse("{(5,50),(10,50),(30,50)}")
  assert_true(v0.equals(kv.get(0)))
  assert_true(v1.equals(kv.get(1)))
  assert_true(v2.equals(kv.get(2)))
  kv.clear()
  kv.parse("{(5,50),(10,50),(30,)}")
  assert_true(v0.equals(kv.get(0)))
  assert_true(v1.equals(kv.get(1)))
  assert_eq(kv.size(), 2)
  kv.clear()
  kv.parse("{(5; 50 ], [10 , 50 ),(30,,,)}")
  assert_true(v0.equals(kv.get(0)))
  assert_true(v1.equals(kv.get(1)))
  assert_eq(kv.size(), 2)
}

///|
test "panic KVectorChain testParseIllegalArgumentException" {
  let kv = new_kvector_chain()
  kv.parse("{(5,a),(10,50),(30,50)}")
}

///|
test "KVectorChain testGetLength" {
  let kv = new_kvector_chain()
  kv.parse("{(10,50),(10,50),(10,50)}")
  assert_double_eq(kv.total_length(), 0.0, 0.0)
  kv.parse("{(10,0),(10,20),(10,30)}")
  assert_double_eq(kv.total_length(), 30.0, 0.0)
}

///|
test "KVectorChain testGetPointOnLine" {
  let v0 = new_kvector_xy(5.0, 50.0)
  let v1 = new_kvector_xy(10.0, 50.0)
  let v2 = new_kvector_xy(30.0, 50.0)
  let kv = new_kvector_chain_from_array([v0, v1, v2])
  assert_true(v0.equals(kv.point_on_line(0.0)))
  assert_true(v1.equals(kv.point_on_line(5.0)))
  assert_true(v2.equals(kv.point_on_line(40.0)))
}
