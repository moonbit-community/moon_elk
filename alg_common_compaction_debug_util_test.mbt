///|
test "DebugUtil draw hitboxes returns svg content" {
  reset_compaction_oned_model_for_test()
  let graph = new_cgraph(direction_values())
  let left_hitbox = new_elk_rectangle_xywh(0.0, 0.0, 20.0, 20.0)
  let right_hitbox = new_elk_rectangle_xywh(30.0, 0.0, 20.0, 20.0)
  let left = cnode_of().hitbox(left_hitbox).create(graph)
  let right = cnode_of().hitbox(right_hitbox).create(graph)
  right.add_constraint(left)

  let svg = draw_hitboxes(graph, "debug.svg")
  inspect(svg.contains("<svg"), content="true")
  inspect(svg.contains("<rect"), content="true")
  inspect(svg.contains("<line"), content="true")
}
