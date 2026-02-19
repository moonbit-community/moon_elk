///|
fn expect_some_int_in_renderer_test(value : Int?) -> Int {
  match value {
    Some(v) => v
    None => abort("Expected Some(Int)")
  }
}

///|
fn new_renderer_test_dc_graph() -> (@disco.DCGraph, Array[@disco.DCPolyomino]) {
  let chain = @core.new_kvector_chain()
  chain.add_xy(0.0, 0.0)
  chain.add_xy(10.0, 0.0)
  chain.add_xy(10.0, 10.0)
  chain.add_xy(0.0, 10.0)

  let element = @disco.new_dc_element(chain)
  let direction = @disco.dc_direction_values()[0]
  ignore(@disco.new_dc_extension(element, direction, @core.new_kvector_xy(5.0, 0.0), 2.0))

  let graph = @disco.new_dc_graph([[element]])
  let component = graph.get_components()[0]
  component.set_id(7)

  let poly = @disco.new_dc_polyomino(component, 5.0, 5.0)
  poly.set_id(7)
  (graph, [poly])
}

///|
fn new_renderer_test_concave_dc_graph() -> @disco.DCGraph {
  let chain = @core.new_kvector_chain()
  chain.add_xy(0.0, 0.0)
  chain.add_xy(8.0, 0.0)
  chain.add_xy(8.0, 2.0)
  chain.add_xy(2.0, 2.0)
  chain.add_xy(2.0, 8.0)
  chain.add_xy(0.0, 8.0)
  @disco.new_dc_graph([[@disco.new_dc_element(chain)]])
}

///|
test "DisCoGraphRenderer renders and fills debug caches" {
  dis_co_graph_renderer_clear_bindings_for_test()

  let root = @graph.create_graph()
  @graph.node_set_dimensions(root, 50.0, 50.0)
  let child = @graph.create_node(Some(root))
  @graph.node_set_location(child, 5.0, 6.0)
  @graph.node_set_dimensions(child, 12.0, 13.0)

  let (dc_graph, polys) = new_renderer_test_dc_graph()
  dis_co_graph_renderer_bind_component_graph(root, dc_graph)
  dis_co_graph_renderer_bind_polyominoes(root, polys)

  let renderer = new_dis_co_graph_renderer(
    new_dis_co_graph_rendering_configurator(new_dis_co_debug_display()),
  )
  dis_co_graph_renderer_render(
    renderer,
    root,
    new_dis_co_paint_rectangle(0, 0, 500, 500),
  )

  assert_eq(
    expect_some_int_in_renderer_test(
      config_state_get_max_depth(dis_co_graph_renderer_get_state(renderer)),
    ),
    1,
  )
  assert_true(dis_co_graph_renderer_debug_bounds_cache_size(renderer) > 0)
  assert_true(dis_co_graph_renderer_debug_polygon_cache_size(renderer) > 0)
  assert_true(dis_co_graph_renderer_debug_poly_cell_cache_size(renderer) > 0)
}

///|
test "DisCoGraphRenderer setVisible follows Java commands" {
  let renderer = new_dis_co_graph_renderer(
    new_dis_co_graph_rendering_configurator(new_dis_co_debug_display()),
  )

  assert_true(dis_co_graph_renderer_is_visible(renderer, "elkgraph"))
  assert_true(dis_co_graph_renderer_is_visible(renderer, "dcgraph"))
  assert_true(dis_co_graph_renderer_is_visible(renderer, "polyominoes"))

  dis_co_graph_renderer_set_visible(renderer, "dcgraph", false)
  assert_true(!dis_co_graph_renderer_is_visible(renderer, "dcgraph"))
  dis_co_graph_renderer_set_visible(renderer, "polyominoes", false)
  assert_true(!dis_co_graph_renderer_is_visible(renderer, "polyominoes"))

  dis_co_graph_renderer_set_visible(renderer, "unknown-command", false)
  assert_true(dis_co_graph_renderer_is_visible(renderer, "unknown-command"))
}

///|
test "DisCoGraphRenderer markDirty resets painted cache entries" {
  dis_co_graph_renderer_clear_bindings_for_test()
  let root = @graph.create_graph()
  @graph.node_set_dimensions(root, 20.0, 20.0)
  let child = @graph.create_node(Some(root))
  @graph.node_set_location(child, 1.0, 1.0)
  @graph.node_set_dimensions(child, 2.0, 2.0)

  let renderer = new_dis_co_graph_renderer(
    new_dis_co_graph_rendering_configurator(new_dis_co_debug_display()),
  )
  let area = new_dis_co_paint_rectangle(0, 0, 100, 100)
  dis_co_graph_renderer_render(renderer, root, area)
  assert_true(dis_co_graph_renderer_debug_painted_bounds_count(renderer) > 0)
  dis_co_graph_renderer_mark_dirty(renderer, area)
  assert_eq(dis_co_graph_renderer_debug_painted_bounds_count(renderer), 0)
}

///|
test "DisCoGraphRenderer polygon dirty check uses polygon geometry" {
  dis_co_graph_renderer_clear_bindings_for_test()
  let root = @graph.create_graph()
  @graph.node_set_dimensions(root, 20.0, 20.0)
  let dc_graph = new_renderer_test_concave_dc_graph()
  dis_co_graph_renderer_bind_component_graph(root, dc_graph)

  let renderer = new_dis_co_graph_renderer(
    new_dis_co_graph_rendering_configurator(new_dis_co_debug_display()),
  )
  dis_co_graph_renderer_render(
    renderer,
    root,
    new_dis_co_paint_rectangle(0, 0, 100, 100),
  )

  let painted_before = dis_co_graph_renderer_debug_painted_polygon_count(
    renderer,
  )
  assert_true(painted_before > 0)

  // This rectangle is inside the polygon's bounding box but outside the concave polygon.
  dis_co_graph_renderer_mark_dirty(
    renderer,
    new_dis_co_paint_rectangle(4, 4, 1, 1),
  )
  assert_eq(
    dis_co_graph_renderer_debug_painted_polygon_count(renderer),
    painted_before,
  )

  dis_co_graph_renderer_mark_dirty(
    renderer,
    new_dis_co_paint_rectangle(1, 1, 1, 1),
  )
  assert_eq(dis_co_graph_renderer_debug_painted_polygon_count(renderer), 0)
}

///|
test "DisCoGraphRenderer makeArrow parity for degenerate and normal cases" {
  let renderer = new_dis_co_graph_renderer(
    new_dis_co_graph_rendering_configurator(new_dis_co_debug_display()),
  )
  inspect(
    dis_co_graph_renderer_debug_make_arrow(
      renderer,
      @core.new_kvector_xy(1.0, 1.0),
      @core.new_kvector_xy(1.0, 1.0),
    ),
    content="None",
  )
  let arrow = dis_co_graph_renderer_debug_make_arrow(
    renderer,
    @core.new_kvector_xy(0.0, 0.0),
    @core.new_kvector_xy(10.0, 0.0),
  )
  assert_true(arrow is Some(_))
  match arrow {
    Some(points) => assert_eq(points.length(), 6)
    None => abort("Expected arrow points")
  }
}
