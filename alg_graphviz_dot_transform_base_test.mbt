///|
test "Command parse and to_string" {
  inspect(command_to_string(command_parse("dot")), content="dot")
  inspect(command_to_string(command_parse("NeAtO")), content="neato")
  inspect(command_to_string(command_parse("bad-command")), content="invalid")
}

///|
test "OverlapMode parse and literal" {
  inspect(overlap_mode_to_string(overlap_mode_parse("true")), content="none")
  inspect(overlap_mode_literal(overlap_mode_parse("true")), content="true")
  inspect(overlap_mode_to_string(overlap_mode_parse("PrIsM")), content="prism")
  inspect(
    overlap_mode_literal(overlap_mode_parse("SCALEXY")),
    content="scalexy",
  )
}

///|
test "NeatoModel parse and literal" {
  inspect(
    neato_model_to_string(neato_model_parse("shortpath")),
    content="shortpath",
  )
  inspect(neato_model_literal(neato_model_parse("CiRcUiT")), content="circuit")
  inspect(neato_model_literal(neato_model_parse("SUBSET")), content="subset")
}

///|
test "Attributes constants" {
  inspect(dot_attr_boundingbox, content="bb")
  inspect(dot_attr_damping, content="Damping")
  inspect(dot_attr_spring_constant, content="K")
  inspect(dot_attr_rankdir, content="rankdir")
}

///|
fn option_int_to_string(value : Int?) -> String {
  match value {
    Some(v) => v.to_string()
    None => "none"
  }
}

///|
test "DotTransformationData storage" {
  let data : DotTransformationData[Int, String] = new_dot_transformation_data()
  inspect(option_int_to_string(data.get_source_graph()), content="none")
  data.set_source_graph(42)
  inspect(option_int_to_string(data.get_source_graph()), content="42")

  data.get_target_graphs().push("g0")
  data.get_target_graphs().push("g1")
  inspect(data.get_target_graphs().length(), content="2")
  inspect(data.get_target_graphs()[1], content="g1")

  data.log("m0")
  data.log("m1")
  inspect(data.get_messages().length(), content="2")
  inspect(data.get_messages()[0], content="m0")
  inspect(data.get_messages()[1], content="m1")
}
