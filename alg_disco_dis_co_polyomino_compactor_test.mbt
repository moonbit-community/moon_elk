///|
fn disco_compactor_test_rect_path(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> KVectorChain {
  let path = new_kvector_chain()
  path.add_xy(x0, y0)
  path.add_xy(x0, y1)
  path.add_xy(x1, y1)
  path.add_xy(x1, y0)
  path
}

///|
fn disco_rectangles_overlap(c1 : DCComponent, c2 : DCComponent) -> Bool {
  let corner1 = c1.get_min_corner()
  let dims1 = c1.get_dimensions_of_bounding_rectangle()
  let corner2 = c2.get_min_corner()
  let dims2 = c2.get_dimensions_of_bounding_rectangle()
  !(corner1.x + dims1.x <= corner2.x ||
  corner2.x + dims2.x <= corner1.x ||
  corner1.y + dims1.y <= corner2.y ||
  corner2.y + dims2.y <= corner1.y)
}

///|
test "DisCoPolyominoCompactor compacts components and sets dimensions" {
  let comp1 = new_dc_component()
  comp1.add_element(
    new_dc_element(disco_compactor_test_rect_path(0.0, 0.0, 12.0, 8.0)),
  )
  let comp2 = new_dc_component()
  comp2.add_element(
    new_dc_element(disco_compactor_test_rect_path(40.0, 0.0, 52.0, 8.0)),
  )

  let graph = new_dc_graph([comp1.get_elements(), comp2.get_elements()])
  graph.set_padding(new_elk_padding_any(6.0))
  graph.set_aspect_ratio(Some(1.0))
  graph.set_polyomino_fill(false)

  let compactor = new_dis_co_polyomino_compactor()
  compactor.compact(graph)

  let dimensions = graph.get_dimensions()
  assert_true(dimensions.x > 0.0)
  assert_true(dimensions.y > 0.0)

  let components = graph.get_components()
  assert_eq(components.length(), 2)
  assert_eq(disco_rectangles_overlap(components[0], components[1]), false)

  match graph.get_debug_disco_polys() {
    Some(polys) => assert_eq(polys.length(), 2)
    None => abort("debug disco polys should be set")
  }
}
