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
fn base_option_string_or_none(value : String?) -> String {
  match value {
    Some(v) => v
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

///|
test "DotTransformationData properties" {
  let data : DotTransformationData[Int, String] = new_dot_transformation_data()

  let bool_property : @graph.IProperty[Bool] = @graph.new_property(
    "dot.test.bool", true,
  )
  inspect(data.get_bool_property(bool_property), content="true")
  data.set_bool_property(bool_property, false)
  inspect(data.get_bool_property(bool_property), content="false")

  let int_property : @graph.IProperty[Int] = @graph.new_property(
    "dot.test.int", 1,
  )
  inspect(data.get_int_property(int_property), content="1")
  data.set_int_property(int_property, 42)
  inspect(data.get_int_property(int_property), content="42")

  let string_property : @graph.IProperty[String] = @graph.new_property(
    "dot.test.string", "default",
  )
  inspect(data.get_string_property(string_property), content="default")
  data.set_string_property(string_property, "value")
  inspect(data.get_string_property(string_property), content="value")

  let graph_elem_property : @graph.IProperty[Map[String, DotGraphElement]] = @graph.new_property(
    "dot.test.graphElems",
    {},
  )
  let graph_elems = data.get_graph_elem_map_property(graph_elem_property)
  inspect(graph_elems.length(), content="0")
  graph_elems["node-1"] = dot_graph_element_node(1)
  graph_elems["edge-2"] = dot_graph_element_edge(2)

  let graph_elems2 = data.get_graph_elem_map_property(graph_elem_property)
  inspect(graph_elems2.length(), content="2")
  inspect(
    option_int_to_string(
      match graph_elems2.get("node-1") {
        Some(element) => dot_graph_element_as_node(element)
        None => None
      },
    ),
    content="1",
  )
  inspect(
    base_option_string_or_none(
      match graph_elems2.get("edge-2") {
        Some(element) =>
          match dot_graph_element_as_edge(element) {
            Some(value) => Some(value.to_string())
            None => None
          }
        None => None
      },
    ),
    content="2",
  )
}
