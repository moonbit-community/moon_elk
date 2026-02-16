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

  assert_true(
    transformer.is_locked(node, layered_compaction_test_direction("LEFT")),
  )
  assert_true(
    transformer.is_locked(node, layered_compaction_test_direction("RIGHT")),
  )
  assert_true(
    transformer.is_locked(node, layered_compaction_test_direction("UP")),
  )
  assert_false(
    transformer.is_locked(node, layered_compaction_test_direction("DOWN")),
  )

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
  let component : IComponent[Unit, Int] = new_component(
    () => [hull],
    () => [],
    () => [],
  )
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

///|
let layered_compaction_test_spacing = 5.0

///|
let layered_compaction_test_default_spacing_handler : LayeredISpacingsHandler = new_layered_spacings_handler(
  (_, _) => layered_compaction_test_spacing,
  (_, _) => layered_compaction_test_spacing,
)

///|
fn layered_compaction_test_graph() -> LayeredCGraph {
  new_layered_c_graph(direction_values())
}

///|
fn layered_compaction_test_rect(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> ElkRectangle {
  new_elk_rectangle_xywh(x, y, width, height)
}

///|
fn layered_compaction_test_left() -> Direction {
  layered_compaction_test_direction("LEFT")
}

///|
fn layered_compaction_test_right() -> Direction {
  layered_compaction_test_direction("RIGHT")
}

///|
fn layered_compaction_test_up() -> Direction {
  layered_compaction_test_direction("UP")
}

///|
fn layered_compaction_test_down() -> Direction {
  layered_compaction_test_direction("DOWN")
}

///|
fn layered_compaction_test_compacter(
  graph : LayeredCGraph,
) -> LayeredOneDimensionalCompactor {
  new_layered_one_dimensional_compactor(graph).set_constraint_algorithm(
    layered_one_dimensional_compactor_quadratic_constraints,
  )
}

///|
test "CompactionTest left compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(30.0, 0.0, 20.0, 20.0))
    .create(graph)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(left.hitbox().x, 0.0)
  layered_compaction_test_close(right.hitbox().x, 25.0)
}

///|
test "CompactionTest left compaction equal coordinate" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let top = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let bottom = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(30.0, 20.0, 20.0, 20.0))
    .create(graph)

  let no_spacing = new_layered_spacings_handler((_, _) => 0.0, (_, _) => 0.0)
  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(no_spacing)
    .set_constraint_algorithm(
      layered_one_dimensional_compactor_scanline_constraints,
    )
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(top.hitbox().x, 0.0)
  layered_compaction_test_close(bottom.hitbox().x, 0.0)
}

///|
test "CompactionTest left compaction spacing aware" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(
      layered_compaction_test_rect(
        30.0,
        20.0 + layered_compaction_test_spacing - 1.0,
        20.0,
        20.0,
      ),
    )
    .create(graph)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(left.hitbox().x, 0.0)
  layered_compaction_test_close(right.hitbox().x, 25.0)
}

///|
test "CompactionTest right compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(30.0, 0.0, 20.0, 20.0))
    .create(graph)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_right())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(left.hitbox().x, 5.0)
  layered_compaction_test_close(right.hitbox().x, 30.0)
}

///|
test "CompactionTest up compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let upper = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let lower = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 30.0, 20.0, 20.0))
    .create(graph)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_up())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(upper.hitbox().y, 0.0)
  layered_compaction_test_close(lower.hitbox().y, 25.0)
}

///|
test "CompactionTest down compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let upper = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let lower = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 30.0, 20.0, 20.0))
    .create(graph)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_down())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(upper.hitbox().y, 5.0)
  layered_compaction_test_close(lower.hitbox().y, 30.0)
}

///|
test "CompactionTest left group compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let upper_right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(40.0, 5.0, 20.0, 20.0))
    .create(graph)
  let lower_right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(30.0, 25.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_cgroup_of().nodes([upper_right, lower_right]).create(graph))
  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(left.hitbox().x, 0.0)
  layered_compaction_test_close(upper_right.hitbox().x, 25.0)
  layered_compaction_test_close(lower_right.hitbox().x, 15.0)
}

///|
test "CompactionTest right group compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 5.0, 20.0, 20.0))
    .create(graph)
  let upper_right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(40.0, 0.0, 20.0, 20.0))
    .create(graph)
  let lower_right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(10.0, 25.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_cgroup_of().nodes([left, lower_right]).create(graph))
  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_right())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(left.hitbox().x, 15.0)
  layered_compaction_test_close(upper_right.hitbox().x, 40.0)
  layered_compaction_test_close(lower_right.hitbox().x, 25.0)
}

///|
test "CompactionTest up group compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let upper_left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let lower_left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(5.0, 40.0, 20.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(25.0, 30.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_cgroup_of().nodes([lower_left, right]).create(graph))
  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_up())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(upper_left.hitbox().y, 0.0)
  layered_compaction_test_close(lower_left.hitbox().y, 25.0)
  layered_compaction_test_close(right.hitbox().y, 15.0)
}

///|
test "CompactionTest down group compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let upper_left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let lower_left = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(5.0, 40.0, 10.0, 20.0))
    .create(graph)
  let right = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(25.0, 10.0, 20.0, 20.0))
    .create(graph)

  ignore(layered_cgroup_of().nodes([upper_left, right]).create(graph))
  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_down())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(upper_left.hitbox().y, 15.0)
  layered_compaction_test_close(lower_left.hitbox().y, 40.0)
  layered_compaction_test_close(right.hitbox().y, 25.0)
}

///|
test "CompactionTest no spacing within groups" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(20.0, 10.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(40.0, 20.0, 20.0, 20.0))
    .create(graph)
  ignore(layered_cgroup_of().nodes([one, two, three]).create(graph))

  let four = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(22.0, 80.0, 20.0, 20.0))
    .create(graph)
  let five = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(42.0, 90.0, 20.0, 20.0))
    .create(graph)
  let six = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(62.0, 100.0, 20.0, 20.0))
    .create(graph)
  ignore(layered_cgroup_of().nodes([four, five, six]).create(graph))

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(layered_compaction_test_default_spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .change_direction(layered_compaction_test_right())
    .compact()
    .change_direction(layered_compaction_test_up())
    .compact()
    .change_direction(layered_compaction_test_down())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(one.hitbox().x, 0.0)
  layered_compaction_test_close(two.hitbox().x, 20.0)
  layered_compaction_test_close(three.hitbox().x, 40.0)
  layered_compaction_test_close(four.hitbox().x, 0.0)
  layered_compaction_test_close(five.hitbox().x, 20.0)
  layered_compaction_test_close(six.hitbox().x, 40.0)

  layered_compaction_test_close(one.hitbox().y, 0.0)
  layered_compaction_test_close(two.hitbox().y, 10.0)
  layered_compaction_test_close(three.hitbox().y, 20.0)
  layered_compaction_test_close(four.hitbox().y, 35.0)
  layered_compaction_test_close(five.hitbox().y, 45.0)
  layered_compaction_test_close(six.hitbox().y, 55.0)
}

///|
test "CompactionTest subsequent directions compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(25.0, 0.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 25.0, 20.0, 20.0))
    .create(graph)
  let four = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(25.0, 25.0, 20.0, 20.0))
    .create(graph)

  let directions = [
    layered_compaction_test_left(),
    layered_compaction_test_right(),
    layered_compaction_test_up(),
    layered_compaction_test_down(),
  ]
  for d1 in directions {
    for d2 in directions {
      for d3 in directions {
        for d4 in directions {
          ignore(
            layered_compaction_test_compacter(graph)
            .set_spacings_handler(
              layered_compaction_test_default_spacing_handler,
            )
            .change_direction(d1)
            .compact()
            .change_direction(d2)
            .compact()
            .change_direction(d3)
            .compact()
            .change_direction(d4)
            .compact()
            .finish(),
          )

          layered_compaction_test_close(one.hitbox().x, 0.0)
          layered_compaction_test_close(one.hitbox().y, 0.0)
          layered_compaction_test_close(two.hitbox().x, 25.0)
          layered_compaction_test_close(two.hitbox().y, 0.0)
          layered_compaction_test_close(three.hitbox().x, 0.0)
          layered_compaction_test_close(three.hitbox().y, 25.0)
          layered_compaction_test_close(four.hitbox().x, 25.0)
          layered_compaction_test_close(four.hitbox().y, 25.0)
        }
      }
    }
  }
}

///|
test "CompactionTest horizontal spacings" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(50.0, 0.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(150.0, 0.0, 20.0, 20.0))
    .create(graph)

  let spacing_handler = new_layered_spacings_handler(
    (n1, n2) => {
      if n1 == three || n2 == three {
        10.0
      } else if n1 == two || n2 == two {
        7.0
      } else if n1 == one || n2 == one {
        5.0
      } else {
        layered_compaction_test_spacing
      }
    },
    (_, _) => 0.0,
  )

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().x, 0.0)
  layered_compaction_test_close(two.hitbox().x, 27.0)
  layered_compaction_test_close(three.hitbox().x, 57.0)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_right())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().x, 0.0)
  layered_compaction_test_close(two.hitbox().x, 27.0)
  layered_compaction_test_close(three.hitbox().x, 57.0)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().x, 0.0)
  layered_compaction_test_close(two.hitbox().x, 27.0)
  layered_compaction_test_close(three.hitbox().x, 57.0)
}

///|
test "CompactionTest vertical spacing during horizontal compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(150.0, 11.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 40.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(150.0, 76.0, 20.0, 20.0))
    .create(graph)

  let spacing_handler = new_layered_spacings_handler((_, _) => 0.0, (n1, n2) => {
    if n1 == three || n2 == three {
      15.0
    } else if n1 == one || n2 == one {
      10.0
    } else if n1 == two || n2 == two {
      5.0
    } else {
      0.0
    }
  })

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_left())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(one.hitbox().x, 20.0)
  layered_compaction_test_close(two.hitbox().x, 0.0)
  layered_compaction_test_close(three.hitbox().x, 0.0)
}

///|
test "CompactionTest vertical spacings" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 0.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 50.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(0.0, 150.0, 20.0, 20.0))
    .create(graph)

  let spacing_handler = new_layered_spacings_handler((_, _) => 0.0, (n1, n2) => {
    if n1 == three || n2 == three {
      10.0
    } else if n1 == two || n2 == two {
      7.0
    } else if n1 == one || n2 == one {
      5.0
    } else {
      0.0
    }
  })

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_up())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().y, 0.0)
  layered_compaction_test_close(two.hitbox().y, 27.0)
  layered_compaction_test_close(three.hitbox().y, 57.0)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_down())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().y, 0.0)
  layered_compaction_test_close(two.hitbox().y, 27.0)
  layered_compaction_test_close(three.hitbox().y, 57.0)

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_up())
    .compact()
    .finish(),
  )
  layered_compaction_test_close(one.hitbox().y, 0.0)
  layered_compaction_test_close(two.hitbox().y, 27.0)
  layered_compaction_test_close(three.hitbox().y, 57.0)
}

///|
test "CompactionTest horizontal spacing during vertical compaction" {
  reset_layered_compaction_oned_model_for_test()

  let graph = layered_compaction_test_graph()
  let one = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(16.0, 150.0, 20.0, 20.0))
    .create(graph)
  let two = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(40.0, 0.0, 20.0, 20.0))
    .create(graph)
  let three = layered_cnode_of()
    .hitbox(layered_compaction_test_rect(76.0, 150.0, 20.0, 20.0))
    .create(graph)

  let spacing_handler = new_layered_spacings_handler(
    (n1, n2) => {
      if n1 == three || n2 == three {
        15.0
      } else if n1 == two || n2 == two {
        10.0
      } else if n1 == one || n2 == one {
        5.0
      } else {
        0.0
      }
    },
    (_, _) => 0.0,
  )

  ignore(
    layered_compaction_test_compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(layered_compaction_test_up())
    .compact()
    .finish(),
  )

  layered_compaction_test_close(one.hitbox().y, 20.0)
  layered_compaction_test_close(two.hitbox().y, 0.0)
  layered_compaction_test_close(three.hitbox().y, 0.0)
}
