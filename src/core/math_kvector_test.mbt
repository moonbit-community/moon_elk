///|
test "KVector testEquals" {
  let kvector1 = new_kvector_xy(10.0, 10.0)
  let kvector2 = new_kvector_xy(10.0, 10.0)
  assert_true(kvector1.equals(kvector2))
  let kvector3 = new_kvector()
  assert_false(kvector1.equals(kvector3))
}

///|
test "KVector testAddAndSub" {
  let kvector1 = new_kvector_xy(12.0, 70.0)
  let kvector2 = new_kvector_xy(15.0, 17.0)
  assert_true(kvector1.equals(kvector1.add(kvector2).sub(kvector2)))
}

///|
test "KVector testScale" {
  let a = new_kvector_xy(12.0, 70.0)
  let b = new_kvector_xy(12.0, 70.0)
  let a_temp = new_kvector_xy(12.0, 70.0)
  ignore(a.add(a_temp).add(a_temp))
  ignore(b.scale(3.0))
  assert_true(a.equals(b))
}

///|
test "KVector testTranslate" {
  let v = new_kvector_xy(10.0, 30.0)
  let b = new_kvector_xy(50.0, 50.0)
  assert_true(b.equals(v.add_xy(40.0, 20.0)))
}

///|
test "KVector testNormalize" {
  let v1 = new_kvector_xy(2.0, 0.0)
  let n1 = new_kvector_xy(1.0, 0.0)
  assert_true(n1.equals(v1.normalize()))
  let v2 = new_kvector_xy(0.0, 2.0)
  let n2 = new_kvector_xy(0.0, 1.0)
  assert_true(n2.equals(v2.normalize()))
}

///|
test "KVector testToDegrees" {
  assert_double_eq(new_kvector_xy(10.0, 0.0).to_degrees(), 0.0, 0.00001)
  assert_double_eq(new_kvector_xy(10.0, 10.0).to_degrees(), 45.0, 0.00001)
  assert_double_eq(new_kvector_xy(0.0, 10.0).to_degrees(), 90.0, 0.00001)
  assert_double_eq(new_kvector_xy(-10.0, 10.0).to_degrees(), 135.0, 0.00001)
  assert_double_eq(new_kvector_xy(-10.0, 0.0).to_degrees(), 180.0, 0.00001)
  assert_double_eq(new_kvector_xy(-10.0, -10.0).to_degrees(), 225.0, 0.00001)
  assert_double_eq(new_kvector_xy(0.0, -10.0).to_degrees(), 270.0, 0.00001)
  assert_double_eq(new_kvector_xy(10.0, -10.0).to_degrees(), 315.0, 0.00001)
}

///|
test "KVector testDistance" {
  assert_double_eq(
    new_kvector_xy(5.0, 50.0).distance(new_kvector_xy(5.0, 50.0)),
    0.0,
    0.0,
  )
  assert_double_eq(
    new_kvector_xy(0.0, 20.0).distance(new_kvector_xy(0.0, 50.0)),
    30.0,
    0.0,
  )
}

///|
test "KVector testParse" {
  let v1 = new_kvector_xy(5.0, 50.0)
  let v2 = new_kvector()
  v2.parse("(5,50)")
  assert_true(v1.equals(v2))
  v2.parse("{5,50}")
  assert_true(v1.equals(v2))
  v2.parse("[5,50]")
  assert_true(v1.equals(v2))
  v2.parse("{(5,50)}")
  assert_true(v1.equals(v2))
  v2.parse("[(5,50)]")
  assert_true(v1.equals(v2))
  v2.parse("[{5,50}]")
  assert_true(v1.equals(v2))
}

///|
test "KVector testApplyBounds" {
  let v = new_kvector_xy(30.0, 30.0)
  let vt = v
  let lower1 = new_kvector_xy(10.0, 10.0)
  let upper1 = new_kvector_xy(40.0, 40.0)
  ignore(vt.bound(lower1.x, lower1.y, upper1.x, upper1.y))
  assert_true(vt.equals(v))
  let lower2 = new_kvector_xy(40.0, 40.0)
  let upper2 = new_kvector_xy(60.0, 60.0)
  ignore(vt.bound(lower2.x, lower2.y, upper2.x, upper2.y))
  assert_true(vt.equals(lower2))
  let lower3 = new_kvector_xy(20.0, 20.0)
  let upper3 = new_kvector_xy(30.0, 30.0)
  ignore(vt.bound(lower3.x, lower3.y, upper3.x, upper3.y))
  assert_true(vt.equals(upper3))
}
