///|
test "graph element adapter forwards base accessors and properties" {
  let size_ref : Ref[KVector] = Ref(new_kvector_xy(1.0, 2.0))
  let position_ref : Ref[KVector] = Ref(new_kvector_xy(3.0, 4.0))

  let int_property = @graph.new_property("graph.adapters.test.int", 7)
  let bool_property = @graph.new_property("graph.adapters.test.bool", true)
  let double_property = @graph.new_property("graph.adapters.test.double", 1.5)
  let string_property = @graph.new_property(
    "graph.adapters.test.string", "value",
  )
  let string_array_property = @graph.new_property(
    "graph.adapters.test.string-array",
    ["a", "b"],
  )

  let adapter = new_graph_element_adapter(
    42,
    () => size_ref.val.clone(),
    size => size_ref.val = size.clone(),
    () => position_ref.val.clone(),
    position => position_ref.val = position.clone(),
    _ => 11,
    _ => true,
    _ => false,
    _ => true,
    _ => 3.25,
    _ => true,
    _ => "ok",
    _ => true,
    _ => ["x", "y", "z"],
    _ => true,
  )

  inspect(adapter.get_element(), content="42")
  inspect(adapter.get_size().x, content="1")
  inspect(adapter.get_size().y, content="2")
  inspect(adapter.get_position().x, content="3")
  inspect(adapter.get_position().y, content="4")
  inspect(adapter.get_property_int(int_property), content="11")
  inspect(adapter.has_property_int(int_property), content="true")
  inspect(adapter.get_property_bool(bool_property), content="false")
  inspect(adapter.has_property_bool(bool_property), content="true")
  inspect(adapter.get_property_double(double_property), content="3.25")
  inspect(adapter.has_property_double(double_property), content="true")
  inspect(adapter.get_property_string(string_property), content="ok")
  inspect(adapter.has_property_string(string_property), content="true")
  inspect(
    adapter.get_property_string_array(string_array_property).length(),
    content="3",
  )
  inspect(
    adapter.has_property_string_array(string_array_property),
    content="true",
  )

  adapter.set_size(new_kvector_xy(9.0, 8.0))
  adapter.set_position(new_kvector_xy(7.0, 6.0))
  inspect(size_ref.val.x, content="9")
  inspect(size_ref.val.y, content="8")
  inspect(position_ref.val.x, content="7")
  inspect(position_ref.val.y, content="6")

  inspect(adapter.get_volatile_id(), content="0")
  adapter.set_volatile_id(99)
  inspect(adapter.get_volatile_id(), content="99")
}

///|
test "node and graph adapters forward composed behavior" {
  let padding_ref : Ref[ElkPadding] = Ref(new_elk_padding_any(2.0))
  let margin_ref : Ref[ElkMargin] = Ref(new_elk_margin_any(3.0))
  let sort_calls : Ref[Int] = Ref(0)
  let sort_with_calls : Ref[Int] = Ref(0)

  let element_adapter = new_graph_element_adapter(
    "node-1",
    () => new_kvector_xy(10.0, 20.0),
    _ => (),
    () => new_kvector_xy(30.0, 40.0),
    _ => (),
    _ => 1,
    _ => false,
    _ => true,
    _ => false,
    _ => 1.0,
    _ => false,
    _ => "x",
    _ => false,
    _ => [],
    _ => false,
  )
  let node_adapter = new_node_adapter(
    element_adapter,
    () => Some("graph-1"),
    () => [1, 2],
    () => [3],
    () => [4],
    () => [5, 6],
    () => sort_calls.val = sort_calls.val + 1,
    comparator => {
      ignore(comparator(3, 3))
      sort_with_calls.val = sort_with_calls.val + 1
    },
    () => true,
    () => new_elk_padding_copy(padding_ref.val),
    padding => padding_ref.val = new_elk_padding_copy(padding),
    () => new_elk_margin_copy(margin_ref.val),
    margin => margin_ref.val = new_elk_margin_copy(margin),
  )
  let graph_adapter = new_graph_adapter(element_adapter, () => [node_adapter])

  inspect(graph_adapter.get_nodes().length(), content="1")
  inspect(node_adapter.get_graph() == Some("graph-1"), content="true")
  inspect(node_adapter.get_labels().length(), content="2")
  inspect(node_adapter.get_ports().length(), content="1")
  inspect(node_adapter.get_incoming_edges().length(), content="1")
  inspect(node_adapter.get_outgoing_edges().length(), content="2")
  inspect(node_adapter.is_compound_node(), content="true")

  node_adapter.sort_port_list()
  node_adapter.sort_port_list_with((left, right) => left - right)
  inspect(sort_calls.val, content="1")
  inspect(sort_with_calls.val, content="1")

  inspect(node_adapter.get_padding().left, content="2")
  inspect(node_adapter.get_margin().left, content="3")
  node_adapter.set_padding(new_elk_padding_any(9.0))
  node_adapter.set_margin(new_elk_margin_any(7.0))
  inspect(padding_ref.val.left, content="9")
  inspect(margin_ref.val.left, content="7")
}

///|
test "port label and edge adapters expose dedicated accessors" {
  let margin_ref : Ref[ElkMargin] = Ref(new_elk_margin_any(5.0))
  let port_side = sides_north[0]
  let label_side = @layered.new_l_label().get_property_label_side(
    @layered.internal_properties_label_side,
  )

  let element_adapter = new_graph_element_adapter(
    "port-1",
    () => new_kvector_xy(1.0, 1.0),
    _ => (),
    () => new_kvector_xy(1.0, 1.0),
    _ => (),
    _ => 0,
    _ => false,
    _ => false,
    _ => false,
    _ => 0.0,
    _ => false,
    _ => "",
    _ => false,
    _ => [],
    _ => false,
  )
  let port_adapter = new_port_adapter(
    element_adapter,
    () => port_side,
    () => ["p-label"],
    () => new_elk_margin_copy(margin_ref.val),
    margin => margin_ref.val = new_elk_margin_copy(margin),
    () => [1, 2, 3],
    () => [4],
    () => true,
  )
  let label_adapter = new_label_adapter(element_adapter, () => label_side, () => {
    "hello"
  })
  let edge_adapter = new_edge_adapter("edge-1", () => [label_adapter])

  inspect(port_side_to_string(port_adapter.get_side()), content="NORTH")
  inspect(port_adapter.get_labels().length(), content="1")
  inspect(port_adapter.get_incoming_edges().length(), content="3")
  inspect(port_adapter.get_outgoing_edges().length(), content="1")
  inspect(port_adapter.has_compound_connections(), content="true")
  inspect(port_adapter.get_margin().left, content="5")
  port_adapter.set_margin(new_elk_margin_any(8.0))
  inspect(margin_ref.val.left, content="8")

  inspect(
    label_side_to_string(label_adapter.get_side()),
    content=label_side_to_string(label_side),
  )
  inspect(label_adapter.get_text(), content="hello")
  inspect(edge_adapter.get_element(), content="edge-1")
  inspect(edge_adapter.get_labels().length(), content="1")
}
