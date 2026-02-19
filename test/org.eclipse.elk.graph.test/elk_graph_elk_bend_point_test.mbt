///|
test "elk bend point defaults and setters" {
  let bend = new_elk_bend_point()
  inspect(bend.get_x(), content="0")
  inspect(bend.get_y(), content="0")

  bend.set_x(1.5)
  bend.set_y(-2.25)
  inspect(bend.get_x(), content="1.5")
  inspect(bend.get_y(), content="-2.25")

  bend.set(3.0, 4.0)
  inspect(bend.get_x(), content="3")
  inspect(bend.get_y(), content="4")
}

///|
test "elk bend point impl constructor mirrors base" {
  let bend = new_elk_bend_point_impl(x=5.0, y=6.5)
  inspect(bend.get_x(), content="5")
  inspect(bend.get_y(), content="6.5")
}
