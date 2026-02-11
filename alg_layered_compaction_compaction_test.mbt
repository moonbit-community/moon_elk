///|
fn layered_compaction_test_close(actual : Double, expected : Double) -> Unit {
  let eps = 0.000001
  if (actual - expected).abs() > eps {
    abort("expected=\{expected} actual=\{actual}")
  }
}

///|
fn layered_compaction_test_direction(name : String) -> Direction {
  for direction in direction_values() {
    if direction_to_string(direction) == name {
      return direction
    }
  }
  abort("direction not found: " + name)
}

///|
fn layered_compaction_test_port_side(name : String) -> PortSide {
  for side in port_side_values() {
    if port_side_to_string(side) == name {
      return side
    }
  }
  abort("port side not found: " + name)
}

///|
test "ComponentsToCGraphTransformer applies lock, spacing and rectangle layout" {
  let hull = new_elk_rectangle_xywh(10.0, 20.0, 30.0, 40.0)
  let representor = new_elk_rectangle_xywh(100.0, 5.0, 8.0, 3.0)
  let parent = new_elk_rectangle_xywh(0.0, 0.0, 1.0, 1.0)
  let placeholder = new_elk_rectangle_xywh(200.0, 9.0, 2.0, 2.0)
  let extension = new_external_extension(
    () => "e",
    () => representor,
    () => parent,
    () => layered_compaction_test_direction("RIGHT"),
    get_placeholder=() => Some(placeholder),
  )
  let component : IComponent[Unit, String] = new_component(
    () => [hull],
    () => [extension],
    () => [layered_compaction_test_port_side("NORTH")],
  )
  let connected : IConnectedComponents[Unit, String] = new_connected_components(
    () => [component],
    () => true,
  )

  let transformer = new_components_to_cgraph_transformer(10.0)
  let graph = transformer.transform(connected)

  assert_eq(graph.c_nodes.length(), 1)
  let node = graph.c_nodes[0]

  assert_true(transformer.is_locked(node, layered_compaction_test_direction("LEFT")))
  assert_true(transformer.is_locked(node, layered_compaction_test_direction("RIGHT")))
  assert_true(transformer.is_locked(node, layered_compaction_test_direction("UP")))
  assert_false(transformer.is_locked(node, layered_compaction_test_direction("DOWN")))

  let extension_entries = transformer.get_external_extensions()
  assert_eq(extension_entries.length(), 1)
  let (_, (_group, extension_node)) = extension_entries[0]

  let placeholder_entries = transformer.get_external_placeholders()
  assert_eq(placeholder_entries.length(), 1)
  let (_, (_parent_group, placeholder_node)) = placeholder_entries[0]

  let spacing_handler = components_to_cgraph_spacing_handler(transformer)
  layered_compaction_test_close(
    (spacing_handler.get_horizontal_spacing)(extension_node, placeholder_node),
    1.0,
  )

  let moved = node.hitbox()
  node.set_hitbox(
    new_elk_rectangle_xywh(
      moved.x + 5.0,
      moved.y + 7.0,
      moved.width,
      moved.height,
    ),
  )

  let offset = transformer.get_offset(component)
  layered_compaction_test_close(offset.x, -5.0)
  layered_compaction_test_close(offset.y, -7.0)

  transformer.apply_layout()
  layered_compaction_test_close(hull.x, 15.0)
  layered_compaction_test_close(hull.y, 27.0)

  let graph_size = transformer.get_graph_size()
  assert_true(graph_size.x > 0.0)
  assert_true(graph_size.y > 0.0)
}

///|
test "OneDimensionalComponentsCompaction keeps single component size and offset" {
  let hull = new_elk_rectangle_xywh(0.0, 0.0, 20.0, 10.0)
  let component : IComponent[Unit, Int] = new_component(() => [hull], () => [], () => [])
  let connected : IConnectedComponents[Unit, Int] = new_connected_components(
    () => [component],
    () => false,
  )

  let compaction = new_one_dimensional_components_compaction(connected, 5.0)
  compaction.compact(new_null_elk_progress_monitor())

  let offset = compaction.get_offset(component)
  layered_compaction_test_close(offset.x, 0.0)
  layered_compaction_test_close(offset.y, 0.0)

  let graph_size = compaction.get_graph_size()
  layered_compaction_test_close(graph_size.x, 20.0)
  layered_compaction_test_close(graph_size.y, 10.0)
}
