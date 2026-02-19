///|
fn spore_rect(x : Double, y : Double, w : Double, h : Double) -> ElkRectangle {
  new_elk_rectangle_xywh(x, y, w, h)
}

///|
fn spore_underlap_samples() -> Array[ElkRectangle] {
  [
    spore_rect(40.0, 20.0, 20.0, 20.0),
    spore_rect(40.0, 40.0, 20.0, 20.0),
    spore_rect(30.0, 70.0, 20.0, 20.0),
    spore_rect(20.0, 80.0, 20.0, 20.0),
    spore_rect(10.0, 80.0, 20.0, 20.0),
    spore_rect(0.0, 80.0, 20.0, 20.0),
    spore_rect(-30.0, 70.0, 20.0, 20.0),
    spore_rect(-40.0, 40.0, 20.0, 20.0),
    spore_rect(-40.0, 20.0, 20.0, 20.0),
    spore_rect(-30.0, -20.0, 20.0, 20.0),
    spore_rect(-20.0, -40.0, 20.0, 20.0),
    spore_rect(0.0, -30.0, 20.0, 20.0),
    spore_rect(30.0, -30.0, 20.0, 20.0),
    spore_rect(20.0, 0.0, 20.0, 20.0),
    spore_rect(0.0, 60.0, 20.0, 20.0),
  ]
}

///|
fn spore_test_underlap_computation(
  r1 : ElkRectangle,
  r2 : ElkRectangle,
) -> Unit raise {
  let n1 = new_node(r1.get_center(), r1)
  let n2 = new_node(r2.get_center(), r2)

  let underlap = n1.underlap(n2)
  assert_true(
    compare_fuzzy_eq(
      underlap,
      n1.distance(n2, n1.vertex.clone().sub(n2.vertex)),
    ),
  )

  n2.translate(n1.vertex.clone().sub(n2.vertex).scale_to_length(underlap))
  assert_true(compare_fuzzy_eq(shortest_distance(n1.rect, n2.rect), 0.0))
}

///|
test "spore node underlap and distance by center direction" {
  let root = spore_rect(0.0, 0.0, 20.0, 60.0)
  for sample in spore_underlap_samples() {
    spore_test_underlap_computation(root, sample)
  }
}

///|
priv struct SporeDistanceCase {
  vector : KVector
  should_collide : Bool
}

///|
fn spore_distance_cases() -> Array[SporeDistanceCase] {
  [
    { vector: new_kvector_xy(-20.0, 20.0), should_collide: true },
    { vector: new_kvector_xy(-80.0, 0.0), should_collide: false },
    { vector: new_kvector_xy(-20.0, 9.0), should_collide: false },
    { vector: new_kvector_xy(0.0, 50.0), should_collide: false },
    { vector: new_kvector_xy(-9.99, 50.0), should_collide: false },
    { vector: new_kvector_xy(60.0, 60.0), should_collide: false },
    { vector: new_kvector_xy(-30.0, 50.0), should_collide: true },
    { vector: new_kvector_xy(-20.0, 130.0), should_collide: true },
    { vector: new_kvector_xy(-20.0, -21.0), should_collide: false },
  ]
}

///|
test "spore node distance by arbitrary vectors" {
  let root_rect = spore_rect(0.0, 0.0, 20.0, 60.0)
  let source_rect = spore_rect(30.0, -30.0, 20.0, 20.0)
  let root = new_node(root_rect.get_center(), root_rect)

  for test_case in spore_distance_cases() {
    let probe = new_node(
      source_rect.get_center(),
      new_elk_rectangle_copy(source_rect),
    )
    let distance = root.distance(probe, test_case.vector)

    if test_case.should_collide {
      probe.translate(test_case.vector.clone().scale_to_length(distance))
      assert_true(
        compare_fuzzy_eq(shortest_distance(root.rect, probe.rect), 0.0),
      )
    } else {
      assert_true(distance == @double.infinity)
    }
  }
}
