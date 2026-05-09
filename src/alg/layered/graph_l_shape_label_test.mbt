///|
test "LGraphElement designation uses non-empty origin identifier" {
  let element = new_l_graph_element()
  debug_inspect(element.get_designation(), content="None")

  element.set_origin_identifier(Some(""))
  debug_inspect(element.get_designation(), content="None")

  element.set_origin_identifier(Some("n0"))
  debug_inspect(element.get_designation(), content="Some(\"n0\")")
}

///|
test "LShape position and size are mutable vectors" {
  let shape = new_l_shape()
  let position = shape.get_position()
  let size = shape.get_size()
  ignore(position.set_xy(10.0, 20.0))
  ignore(size.set_xy(30.0, 40.0))

  debug_inspect(shape.get_position().x, content="10")
  debug_inspect(shape.get_position().y, content="20")
  debug_inspect(shape.get_size().x, content="30")
  debug_inspect(shape.get_size().y, content="40")
}

///|
test "LLabel designation and to_string follow Java behavior" {
  let empty = new_l_label()
  debug_inspect(empty.get_designation(), content="None")
  debug_inspect(empty.to_string(), content="label")

  empty.set_origin_identifier(Some("origin"))
  debug_inspect(empty.get_designation(), content="Some(\"origin\")")
  debug_inspect(empty.to_string(), content="l_origin")

  let text_label = new_l_label_text("txt")
  debug_inspect(text_label.get_designation(), content="Some(\"txt\")")
  debug_inspect(text_label.to_string(), content="l_txt")
}
