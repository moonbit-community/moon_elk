///|
fn comment_preprocessor_test_new_node(
  graph : @layered.LGraph,
  id : Int,
  comment_box : Bool,
) -> @layered.LNode {
  let node = @layered.new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_property_bool(@options.layered_options_comment_box, comment_box)
  graph.get_layerless_nodes().push(node)
  node
}

///|
fn comment_preprocessor_test_new_port(
  node : @layered.LNode,
  id : Int,
) -> @layered.LPort {
  let port = @layered.new_l_port()
  port.set_id(id)
  port.set_node(Some(node))
  port
}

///|
fn comment_preprocessor_test_new_edge(
  id : Int,
  source : @layered.LPort?,
  target : @layered.LPort?,
) -> @layered.LEdge {
  let edge = @layered.new_l_edge()
  edge.set_id(id)
  edge.set_source(source)
  edge.set_target(target)
  edge
}

///|
fn comment_preprocessor_test_port_id(port : @layered.LPort?) -> Int {
  match port {
    Some(value) => value.get_id()
    None => -1
  }
}

///|
fn comment_preprocessor_test_is_none(port : @layered.LPort?) -> Bool {
  match port {
    Some(_) => false
    None => true
  }
}

///|
fn comment_preprocessor_test_node_is_none(node : @layered.LNode?) -> Bool {
  match node {
    Some(_) => false
    None => true
  }
}

///|
test "comment preprocessor reports expected task name" {
  let processor = new_comment_preprocessor_layout_processor()
  let monitor = @core.new_elk_progress_monitor()
  processor.process(@layered.new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Comment pre-processing")
}

///|
test "comment preprocessor extracts singly connected comment box" {
  let graph = @layered.new_l_graph()

  let real = comment_preprocessor_test_new_node(graph, 1, false)
  let box = comment_preprocessor_test_new_node(graph, 2, true)

  let real_port = comment_preprocessor_test_new_port(real, 11)
  let box_port = comment_preprocessor_test_new_port(box, 12)
  let edge = comment_preprocessor_test_new_edge(
    21,
    Some(box_port),
    Some(real_port),
  )

  let processor = new_comment_preprocessor_layout_processor()
  processor.process(graph, None)

  inspect(graph.get_layerless_nodes().length(), content="1")
  inspect(graph.get_layerless_nodes()[0].get_id(), content="1")

  inspect(
    real.has_property_l_node_array(@layered.internal_properties_top_comments),
    content="true",
  )
  inspect(
    real
    .get_property_l_node_array(@layered.internal_properties_top_comments)
    .length(),
    content="1",
  )
  inspect(
    real.get_property_l_node_array(@layered.internal_properties_top_comments)[0].get_id(),
    content="2",
  )

  inspect(
    comment_preprocessor_test_port_id(
      box.get_property_l_port(@layered.internal_properties_comment_conn_port),
    ),
    content="11",
  )
  inspect(comment_preprocessor_test_port_id(edge.get_source()), content="12")
  inspect(comment_preprocessor_test_is_none(edge.get_target()), content="true")
  inspect(real_port.get_degree(), content="0")
  inspect(
    comment_preprocessor_test_node_is_none(real_port.get_node()),
    content="true",
  )
}

///|
test "comment preprocessor reverses oddly connected comment edge" {
  let graph = @layered.new_l_graph()

  let comment = comment_preprocessor_test_new_node(graph, 10, true)
  let left = comment_preprocessor_test_new_node(graph, 11, false)
  let right = comment_preprocessor_test_new_node(graph, 12, false)

  let comment_port = comment_preprocessor_test_new_port(comment, 101)
  let left_port = comment_preprocessor_test_new_port(left, 102)
  let right_port = comment_preprocessor_test_new_port(right, 103)

  let odd_edge = comment_preprocessor_test_new_edge(
    201,
    Some(comment_port),
    Some(left_port),
  )
  ignore(
    comment_preprocessor_test_new_edge(202, Some(left_port), Some(right_port)),
  )

  let processor = new_comment_preprocessor_layout_processor()
  processor.process(graph, None)

  inspect(graph.get_layerless_nodes().length(), content="3")
  inspect(
    comment_preprocessor_test_port_id(odd_edge.get_source()),
    content="102",
  )
  inspect(
    comment_preprocessor_test_port_id(odd_edge.get_target()),
    content="101",
  )
  inspect(
    odd_edge.get_property_bool(@layered.internal_properties_reversed),
    content="true",
  )
}
