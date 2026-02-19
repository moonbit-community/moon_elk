///|
test "L margin defaults to zero spacing" {
  let margin = new_l_margin()
  inspect(margin.top, content="0")
  inspect(margin.right, content="0")
  inspect(margin.bottom, content="0")
  inspect(margin.left, content="0")
}

///|
test "L padding clone copies all sides" {
  let padding = new_l_padding()
  padding.set_top(1.0)
  padding.set_right(2.0)
  padding.set_bottom(3.0)
  padding.set_left(4.0)

  let clone = padding.clone()
  inspect(clone.top, content="1")
  inspect(clone.right, content="2")
  inspect(clone.bottom, content="3")
  inspect(clone.left, content="4")

  padding.set_top(99.0)
  inspect(clone.top, content="1")
}
