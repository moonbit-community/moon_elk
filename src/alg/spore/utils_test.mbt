///|
fn spore_utils_rect(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> @core.ElkRectangle {
  @core.new_elk_rectangle_xywh(x, y, w, h)
}

///|
fn spore_utils_overlap_non_negative_after_move(
  r1 : @core.ElkRectangle,
  r2 : @core.ElkRectangle,
) -> Bool {
  let o = @common.overlap(r1, r2)
  let c1 = r1.get_center()
  let c2 = r2.get_center()
  let d = c2.clone().sub(c1)
  let c3 = c1.clone().add(d.scale(o))
  let r3 = @core.new_elk_rectangle_copy(r2)
  ignore(r3.move(c3.clone().sub(c2)))
  @common.compare_fuzzy_ge(@core.shortest_distance(r1, r3), 0.0)
}

///|
test "spore utils @common.overlap computation" {
  let r1 = spore_utils_rect(0.0, 0.0, 40.0, 80.0)
  let samples : Array[@core.ElkRectangle] = [
    spore_utils_rect(0.0, 0.0, 70.0, 20.0),
    spore_utils_rect(10.0, 50.0, 70.0, 20.0),
    spore_utils_rect(-40.0, 30.0, 70.0, 20.0),
    spore_utils_rect(-60.0, 70.0, 70.0, 20.0),
    spore_utils_rect(-10.0, 70.0, 70.0, 20.0),
    spore_utils_rect(-20.0, -10.0, 70.0, 20.0),
    spore_utils_rect(10.0, 20.0, 20.0, 20.0),
    spore_utils_rect(-20.0, -20.0, 100.0, 120.0),
    spore_utils_rect(0.0, -0.001, 40.0, 80.0),
  ]
  for sample in samples {
    assert_true(spore_utils_overlap_non_negative_after_move(r1, sample))
  }
}

///|
priv struct SporeUtilsDistanceCase {
  vector : @core.KVector
  should_collide : Bool
}

///|
test "spore utils underlap and distance" {
  let r1 = spore_utils_rect(0.0, 0.0, 20.0, 60.0)
  let samples : Array[@core.ElkRectangle] = [
    spore_utils_rect(40.0, 20.0, 20.0, 20.0),
    spore_utils_rect(40.0, 40.0, 20.0, 20.0),
    spore_utils_rect(30.0, 70.0, 20.0, 20.0),
    spore_utils_rect(20.0, 80.0, 20.0, 20.0),
    spore_utils_rect(10.0, 80.0, 20.0, 20.0),
    spore_utils_rect(0.0, 80.0, 20.0, 20.0),
    spore_utils_rect(-30.0, 70.0, 20.0, 20.0),
    spore_utils_rect(-40.0, 40.0, 20.0, 20.0),
    spore_utils_rect(-40.0, 20.0, 20.0, 20.0),
    spore_utils_rect(-30.0, -20.0, 20.0, 20.0),
    spore_utils_rect(-20.0, -40.0, 20.0, 20.0),
    spore_utils_rect(0.0, -30.0, 20.0, 20.0),
    spore_utils_rect(30.0, -30.0, 20.0, 20.0),
    spore_utils_rect(20.0, 0.0, 20.0, 20.0),
    spore_utils_rect(0.0, 60.0, 20.0, 20.0),
  ]

  for sample in samples {
    let n1 = @common.new_node(r1.get_center(), r1)
    let n2 = @common.new_node(sample.get_center(), sample)
    let underlap = n1.underlap(n2)
    assert_true(
      @common.compare_fuzzy_eq(
        underlap,
        n1.distance(n2, n1.vertex.clone().sub(n2.vertex)),
      ),
    )
    n2.translate(n1.vertex.clone().sub(n2.vertex).scale_to_length(underlap))
    assert_true(@common.compare_fuzzy_eq(@core.shortest_distance(n1.rect, n2.rect), 0.0))
  }

  let vectors : Array[SporeUtilsDistanceCase] = [
    { vector: @core.new_kvector_xy(-20.0, 20.0), should_collide: true },
    { vector: @core.new_kvector_xy(-80.0, 0.0), should_collide: false },
    { vector: @core.new_kvector_xy(-20.0, 9.0), should_collide: false },
    { vector: @core.new_kvector_xy(0.0, 50.0), should_collide: false },
    { vector: @core.new_kvector_xy(-9.99, 50.0), should_collide: false },
    { vector: @core.new_kvector_xy(60.0, 60.0), should_collide: false },
    { vector: @core.new_kvector_xy(-30.0, 50.0), should_collide: true },
    { vector: @core.new_kvector_xy(-20.0, 130.0), should_collide: true },
    { vector: @core.new_kvector_xy(-20.0, -21.0), should_collide: false },
  ]

  let root = @common.new_node(r1.get_center(), r1)
  let source = spore_utils_rect(30.0, -30.0, 20.0, 20.0)
  for item in vectors {
    let n2 = @common.new_node(source.get_center(), @core.new_elk_rectangle_copy(source))
    let distance = root.distance(n2, item.vector)
    if item.should_collide {
      n2.translate(item.vector.clone().scale_to_length(distance))
      assert_true(@common.compare_fuzzy_eq(@core.shortest_distance(root.rect, n2.rect), 0.0))
    } else {
      assert_true(distance == @double.infinity)
    }
  }
}
