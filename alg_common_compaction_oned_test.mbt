///|
let eps = 0.0001

///|
let spacing = 5.0

///|
let test_spacing_handler : ISpacingsHandler = new_spacings_handler(
  (_, _) => spacing,
  (_, _) => spacing,
)

///|
fn rect(x : Double, y : Double, w : Double, h : Double) -> ElkRectangle {
  let r = new_elk_rectangle()
  r.set_rect(x, y, w, h)
  r
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  assert_true((actual - expected).abs() <= eps)
}

///|
fn compacter(graph : CGraph) -> OneDimensionalCompactor {
  new_one_dimensional_compactor(graph).set_constraint_algorithm(
    one_dimensional_compactor_quadratic_constraints,
  )
}

///|
fn dir_right() -> Direction {
  direction_values()[1]
}

///|
fn dir_left() -> Direction {
  direction_values()[2]
}

///|
fn dir_down() -> Direction {
  direction_values()[3]
}

///|
fn dir_up() -> Direction {
  direction_values()[4]
}

///|
test "OneDimensionalCompactor left compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let right = cnode_of().hitbox(rect(30.0, 0.0, 20.0, 20.0)).create(graph)

  ignore(compacter(graph).change_direction(dir_left()).compact().finish())

  assert_close(left.hitbox().x, 0.0)
  assert_close(right.hitbox().x, 20.0)
}

///|
test "OneDimensionalCompactor left compaction equal y" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let top = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let bot = cnode_of().hitbox(rect(30.0, 20.0, 20.0, 20.0)).create(graph)

  ignore(
    compacter(graph)
    .set_constraint_algorithm(one_dimensional_compactor_scanline_constraints)
    .change_direction(dir_left())
    .compact()
    .finish(),
  )

  assert_close(top.hitbox().x, 0.0)
  assert_close(bot.hitbox().x, 0.0)
}

///|
test "OneDimensionalCompactor left compaction spacing aware" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let right = cnode_of()
    .hitbox(rect(30.0, 20.0 + spacing - 1.0, 20.0, 20.0))
    .create(graph)

  ignore(
    compacter(graph)
    .set_spacings_handler(test_spacing_handler)
    .change_direction(dir_left())
    .compact()
    .finish(),
  )

  assert_close(left.hitbox().x, 0.0)
  assert_close(right.hitbox().x, 25.0)
}

///|
test "OneDimensionalCompactor left compaction spacing aware 2" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let right = cnode_of()
    .hitbox(rect(30.0, 20.0 + spacing + 1.0, 20.0, 20.0))
    .create(graph)

  ignore(
    compacter(graph)
    .set_spacings_handler(test_spacing_handler)
    .change_direction(dir_left())
    .compact()
    .finish(),
  )

  assert_close(left.hitbox().x, 0.0)
  assert_close(right.hitbox().x, 0.0)
}

///|
test "OneDimensionalCompactor right compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let right = cnode_of().hitbox(rect(30.0, 0.0, 20.0, 20.0)).create(graph)

  ignore(compacter(graph).change_direction(dir_right()).compact().finish())

  assert_close(left.hitbox().x, 10.0)
  assert_close(right.hitbox().x, 30.0)
}

///|
test "OneDimensionalCompactor up compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let upper = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let lower = cnode_of().hitbox(rect(0.0, 30.0, 20.0, 20.0)).create(graph)

  ignore(compacter(graph).change_direction(dir_up()).compact().finish())

  assert_close(upper.hitbox().y, 0.0)
  assert_close(lower.hitbox().y, 20.0)
}

///|
test "OneDimensionalCompactor down compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let upper = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let lower = cnode_of().hitbox(rect(0.0, 30.0, 20.0, 20.0)).create(graph)

  ignore(compacter(graph).change_direction(dir_down()).compact().finish())

  assert_close(upper.hitbox().y, 10.0)
  assert_close(lower.hitbox().y, 30.0)
}

///|
test "OneDimensionalCompactor left group compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let upper_right = cnode_of().hitbox(rect(40.0, 5.0, 20.0, 20.0)).create(graph)
  let lower_right = cnode_of()
    .hitbox(rect(30.0, 25.0, 20.0, 20.0))
    .create(graph)

  ignore(cgroup_of().nodes([upper_right, lower_right]).create(graph))

  ignore(compacter(graph).change_direction(dir_left()).compact().finish())

  assert_close(left.hitbox().x, 0.0)
  assert_close(upper_right.hitbox().x, 20.0)
  assert_close(lower_right.hitbox().x, 10.0)
}

///|
test "OneDimensionalCompactor right group compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let left = cnode_of().hitbox(rect(0.0, 5.0, 20.0, 20.0)).create(graph)
  let upper_right = cnode_of().hitbox(rect(40.0, 0.0, 20.0, 20.0)).create(graph)
  let lower_right = cnode_of()
    .hitbox(rect(10.0, 25.0, 20.0, 20.0))
    .create(graph)

  ignore(cgroup_of().nodes([left, lower_right]).create(graph))

  ignore(compacter(graph).change_direction(dir_right()).compact().finish())

  assert_close(left.hitbox().x, 20.0)
  assert_close(upper_right.hitbox().x, 40.0)
  assert_close(lower_right.hitbox().x, 30.0)
}

///|
test "OneDimensionalCompactor up group compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let upper_left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let lower_left = cnode_of().hitbox(rect(5.0, 40.0, 20.0, 20.0)).create(graph)
  let right = cnode_of().hitbox(rect(25.0, 30.0, 20.0, 20.0)).create(graph)

  ignore(cgroup_of().nodes([lower_left, right]).create(graph))

  ignore(compacter(graph).change_direction(dir_up()).compact().finish())

  assert_close(upper_left.hitbox().y, 0.0)
  assert_close(lower_left.hitbox().y, 20.0)
  assert_close(right.hitbox().y, 10.0)
}

///|
test "OneDimensionalCompactor down group compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let upper_left = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let lower_left = cnode_of().hitbox(rect(5.0, 40.0, 10.0, 20.0)).create(graph)
  let right = cnode_of().hitbox(rect(25.0, 10.0, 20.0, 20.0)).create(graph)

  ignore(cgroup_of().nodes([upper_left, right]).create(graph))

  ignore(compacter(graph).change_direction(dir_down()).compact().finish())

  assert_close(upper_left.hitbox().y, 20.0)
  assert_close(lower_left.hitbox().y, 40.0)
  assert_close(right.hitbox().y, 30.0)
}

///|
test "OneDimensionalCompactor no spacing within groups" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let one = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let two = cnode_of().hitbox(rect(20.0, 10.0, 20.0, 20.0)).create(graph)
  let three = cnode_of().hitbox(rect(40.0, 20.0, 20.0, 20.0)).create(graph)
  ignore(cgroup_of().nodes([one, two, three]).create(graph))

  let four = cnode_of().hitbox(rect(22.0, 80.0, 20.0, 20.0)).create(graph)
  let five = cnode_of().hitbox(rect(42.0, 90.0, 20.0, 20.0)).create(graph)
  let six = cnode_of().hitbox(rect(62.0, 100.0, 20.0, 20.0)).create(graph)
  ignore(cgroup_of().nodes([four, five, six]).create(graph))

  ignore(
    compacter(graph)
    .set_spacings_handler(test_spacing_handler)
    .change_direction(dir_left())
    .compact()
    .change_direction(dir_right())
    .compact()
    .change_direction(dir_up())
    .compact()
    .change_direction(dir_down())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().x, 0.0)
  assert_close(two.hitbox().x, 20.0)
  assert_close(three.hitbox().x, 40.0)
  assert_close(four.hitbox().x, 0.0)
  assert_close(five.hitbox().x, 20.0)
  assert_close(six.hitbox().x, 40.0)

  assert_close(one.hitbox().y, 0.0)
  assert_close(two.hitbox().y, 10.0)
  assert_close(three.hitbox().y, 20.0)
  assert_close(four.hitbox().y, 35.0)
  assert_close(five.hitbox().y, 45.0)
  assert_close(six.hitbox().y, 55.0)
}

///|
test "OneDimensionalCompactor subsequent directions compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let one = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let two = cnode_of().hitbox(rect(25.0, 0.0, 20.0, 20.0)).create(graph)
  let three = cnode_of().hitbox(rect(0.0, 25.0, 20.0, 20.0)).create(graph)
  let four = cnode_of().hitbox(rect(25.0, 25.0, 20.0, 20.0)).create(graph)

  let directions = [dir_left(), dir_right(), dir_up(), dir_down()]

  for d1 in directions {
    for d2 in directions {
      for d3 in directions {
        for d4 in directions {
          ignore(
            compacter(graph)
            .set_spacings_handler(test_spacing_handler)
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

          assert_close(one.hitbox().x, 0.0)
          assert_close(one.hitbox().y, 0.0)

          assert_close(two.hitbox().x, 25.0)
          assert_close(two.hitbox().y, 0.0)

          assert_close(three.hitbox().x, 0.0)
          assert_close(three.hitbox().y, 25.0)

          assert_close(four.hitbox().x, 25.0)
          assert_close(four.hitbox().y, 25.0)
        }
      }
    }
  }
}

///|
test "OneDimensionalCompactor vertical spacing during horizontal compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let one = cnode_of().hitbox(rect(150.0, 11.0, 20.0, 20.0)).create(graph)
  let two = cnode_of().hitbox(rect(0.0, 40.0, 20.0, 20.0)).create(graph)
  let three = cnode_of().hitbox(rect(150.0, 76.0, 20.0, 20.0)).create(graph)

  let spacing_handler = new_spacings_handler((_, _) => 0.0, (cnode1, cnode2) => {
    if cnode1 == three || cnode2 == three {
      15.0
    } else if cnode1 == one || cnode2 == one {
      10.0
    } else if cnode1 == two || cnode2 == two {
      5.0
    } else {
      0.0
    }
  })

  ignore(
    compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(dir_left())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().x, 20.0)
  assert_close(two.hitbox().x, 0.0)
  assert_close(three.hitbox().x, 0.0)
}

///|
test "OneDimensionalCompactor vertical spacings" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let one = cnode_of().hitbox(rect(0.0, 0.0, 20.0, 20.0)).create(graph)
  let two = cnode_of().hitbox(rect(0.0, 50.0, 20.0, 20.0)).create(graph)
  let three = cnode_of().hitbox(rect(0.0, 150.0, 20.0, 20.0)).create(graph)

  let spacing_handler = new_spacings_handler((_, _) => 0.0, (cnode1, cnode2) => {
    if cnode1 == three || cnode2 == three {
      10.0
    } else if cnode1 == two || cnode2 == two {
      7.0
    } else if cnode1 == one || cnode2 == one {
      5.0
    } else {
      0.0
    }
  })

  ignore(
    compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(dir_up())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().y, 0.0)
  assert_close(two.hitbox().y, 27.0)
  assert_close(three.hitbox().y, 57.0)

  ignore(
    compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(dir_down())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().y, 0.0)
  assert_close(two.hitbox().y, 27.0)
  assert_close(three.hitbox().y, 57.0)

  ignore(
    compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(dir_up())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().y, 0.0)
  assert_close(two.hitbox().y, 27.0)
  assert_close(three.hitbox().y, 57.0)
}

///|
test "OneDimensionalCompactor horizontal spacing during vertical compaction" {
  reset_compaction_oned_model_for_test()

  let graph = new_cgraph(direction_values())

  let one = cnode_of().hitbox(rect(16.0, 150.0, 20.0, 20.0)).create(graph)
  let two = cnode_of().hitbox(rect(40.0, 0.0, 20.0, 20.0)).create(graph)
  let three = cnode_of().hitbox(rect(76.0, 150.0, 20.0, 20.0)).create(graph)

  let spacing_handler = new_spacings_handler(
    (cnode1, cnode2) => {
      if cnode1 == three || cnode2 == three {
        15.0
      } else if cnode1 == two || cnode2 == two {
        10.0
      } else if cnode1 == one || cnode2 == one {
        5.0
      } else {
        0.0
      }
    },
    (_, _) => 0.0,
  )

  ignore(
    compacter(graph)
    .set_spacings_handler(spacing_handler)
    .change_direction(dir_up())
    .compact()
    .finish(),
  )

  assert_close(one.hitbox().y, 20.0)
  assert_close(two.hitbox().y, 0.0)
  assert_close(three.hitbox().y, 0.0)
}
