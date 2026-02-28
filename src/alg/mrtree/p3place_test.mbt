///|
test "Mrtree NodePlacer computes walker coordinates and final positions" {
  reset_mrtree_graph_model_for_test()

  let graph = new_mrtree_graph()
  let root = new_mrtree_node(0, graph)
  let left = new_mrtree_node(1, graph)
  let right = new_mrtree_node(2, graph)
  ignore(new_mrtree_edge(root, left))
  ignore(new_mrtree_edge(root, right))

  ignore(mrtree_node_size(root).set_xy(10.0, 10.0))
  ignore(mrtree_node_size(left).set_xy(10.0, 10.0))
  ignore(mrtree_node_size(right).set_xy(10.0, 10.0))

  new_mrtree_root_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_level_height_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_neighbors_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_node_placer_layout_phase().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_direction_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )
  new_mrtree_node_position_processor_layout_processor().process(
    graph,
    Some(@core.new_basic_progress_monitor()),
  )

  inspect(mrtree_node_xcoor(root), content="15")
  inspect(mrtree_node_ycoor(root), content="0")
  inspect(mrtree_node_xcoor(left), content="0")
  inspect(mrtree_node_ycoor(left), content="30")
  inspect(mrtree_node_xcoor(right), content="30")
  inspect(mrtree_node_ycoor(right), content="30")

  inspect(mrtree_node_position(root).x, content="10")
  inspect(mrtree_node_position(root).y, content="-5")
  inspect(mrtree_node_position(left).x, content="-5")
  inspect(mrtree_node_position(left).y, content="25")
  inspect(mrtree_node_position(right).x, content="25")
  inspect(mrtree_node_position(right).y, content="25")
}
