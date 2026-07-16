///|
fn spore_scanline_node(x : Double, y : Double, w : Double, h : Double) -> Node {
  let rect = new_elk_rectangle_xywh(x, y, w, h)
  new_node(rect.get_center(), rect)
}

///|
test "spore scanline overlap check detects expected overlap pairs" {
  let n0 = spore_scanline_node(0.0, 30.0, 160.0, 20.0)
  let n1 = spore_scanline_node(150.0, 40.0, 160.0, 20.0)
  let n2 = spore_scanline_node(150.0, 0.0, 20.0, 20.0)
  let n3 = spore_scanline_node(150.0, 70.0, 20.0, 20.0)

  let overlap_count : Ref[Int] = Ref(0)
  let handler : IOverlapHandler = (_, _) => {
    overlap_count.val = overlap_count.val + 1
  }
  let checker = new_scanline_overlap_check(handler, new_svg_image(None))
  checker.sweep([n0, n1, n2, n3])

  assert_eq(overlap_count.val, 1)
}

///|
test "spore scanline overlap check ignores touching rectangles" {
  let n0 = spore_scanline_node(0.0, 0.0, 20.0, 20.0)
  let n1 = spore_scanline_node(20.0, 5.0, 20.0, 20.0)

  let overlap_count : Ref[Int] = Ref(0)
  let handler : IOverlapHandler = (_, _) => {
    overlap_count.val = overlap_count.val + 1
  }
  let checker = new_scanline_overlap_check(handler, new_svg_image(None))
  checker.sweep([n0, n1])

  assert_eq(overlap_count.val, 0)
}
