///|
let basic_edge_router_test_tolerance : Double = 0.05

///|
pub fn basic_edge_router_test_check_edge_route_is_orthogonal(
  edge : String,
  route : KVectorChain,
) -> Unit raise {
  if route.size() < 2 {
    fail(edge + ": Route with less than 2 points")
  }

  let mut horizontal = basic_edge_router_test_is_horizontal(
    route.get(0),
    route.get(1),
  )

  let mut prev = route.get(0)
  for i in 1..<route.size() {
    let curr = route.get(i)
    let error = edge +
      ": horizontal = " +
      horizontal.to_string() +
      " prev = " +
      prev.to_string() +
      " curr = " +
      curr.to_string()

    if horizontal {
      if (prev.y - curr.y).abs() >= basic_edge_router_test_tolerance {
        fail(error)
      }
    } else if (prev.x - curr.x).abs() >= basic_edge_router_test_tolerance {
      fail(error)
    }

    horizontal = !horizontal
    prev = curr
  }
}

///|
pub fn basic_edge_router_test_is_horizontal(p1 : KVector, p2 : KVector) -> Bool {
  (p1.y - p2.y).abs() < basic_edge_router_test_tolerance
}

///|
test "basic edge router orthogonal route utility accepts horizontal-first route" {
  let route = new_kvector_chain_from_array([
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(10.0, 0.01),
    new_kvector_xy(10.01, 8.0),
    new_kvector_xy(20.0, 8.01),
  ])
  basic_edge_router_test_check_edge_route_is_orthogonal("edge-1", route)
}

///|
test "basic edge router orthogonal route utility accepts vertical-first route" {
  let route = new_kvector_chain_from_array([
    new_kvector_xy(0.0, 0.0),
    new_kvector_xy(0.02, 6.0),
    new_kvector_xy(7.0, 6.01),
    new_kvector_xy(7.01, 13.0),
  ])
  basic_edge_router_test_check_edge_route_is_orthogonal("edge-2", route)
}

///|
test "basic edge router isHorizontal follows tolerance" {
  assert_true(
    basic_edge_router_test_is_horizontal(
      new_kvector_xy(0.0, 1.0),
      new_kvector_xy(10.0, 1.04),
    ),
  )
  assert_false(
    basic_edge_router_test_is_horizontal(
      new_kvector_xy(0.0, 1.0),
      new_kvector_xy(10.0, 1.06),
    ),
  )
}
