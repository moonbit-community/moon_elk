///|
fn comment_postprocessor_test_new_node(
  graph : LGraph,
  layer : Layer,
  id : Int,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> LNode {
  let node = new_l_node(graph=Some(graph))
  node.set_id(id)
  node.set_layer(Some(layer))
  ignore(node.get_position().set_xy(x, y))
  ignore(node.get_size().set_xy(width, height))
  node
}

///|
fn comment_postprocessor_test_new_comment_box(
  graph : LGraph,
  id : Int,
  width : Double,
  height : Double,
) -> LNode {
  let box = new_l_node(graph=Some(graph))
  box.set_id(id)
  ignore(box.get_size().set_xy(width, height))
  box
}

///|
fn comment_postprocessor_test_new_port(owner : LNode?, id : Int) -> LPort {
  let port = new_l_port()
  port.set_id(id)
  port.set_node(owner)
  port
}

///|
fn comment_postprocessor_test_port_id(port : LPort?) -> Int {
  match port {
    Some(value) => value.get_id()
    None => -1
  }
}

///|
test "comment postprocessor reports expected task name" {
  let processor = new_comment_postprocessor_layout_processor()
  let monitor = new_elk_progress_monitor()
  processor.process(new_l_graph(), Some(monitor))
  inspect(monitor.get_task_name(), content="Comment post-processing")
}

///|
test "comment postprocessor repositions comments and reconnects detached edges" {
  let graph = new_l_graph()
  graph.set_property_double(layered_options_spacing_comment_comment, 5.0)

  let layer = new_layer(graph)
  graph.get_layers().push(layer)

  let node = comment_postprocessor_test_new_node(
    graph, layer, 1, 100.0, 200.0, 40.0, 30.0,
  )
  node.get_margin().set_values(22.0, 2.0, 18.0, 4.0)

  let top_box = comment_postprocessor_test_new_comment_box(graph, 2, 20.0, 10.0)
  let top_node_port = comment_postprocessor_test_new_port(None, 101)
  top_box.set_property_l_port(
    internal_properties_comment_conn_port,
    Some(top_node_port),
  )
  let top_box_port = comment_postprocessor_test_new_port(Some(top_box), 201)
  let top_edge = new_l_edge()
  top_edge.set_id(301)
  top_edge.set_source(Some(top_box_port))

  let bottom_box = comment_postprocessor_test_new_comment_box(
    graph, 3, 30.0, 15.0,
  )
  let bottom_node_port = comment_postprocessor_test_new_port(None, 102)
  bottom_box.set_property_l_port(
    internal_properties_comment_conn_port,
    Some(bottom_node_port),
  )
  let bottom_box_port = comment_postprocessor_test_new_port(
    Some(bottom_box),
    202,
  )
  let bottom_edge = new_l_edge()
  bottom_edge.set_id(302)
  bottom_edge.set_target(Some(bottom_box_port))

  node.set_property_l_node_array(internal_properties_top_comments, [top_box])
  node.set_property_l_node_array(internal_properties_bottom_comments, [
    bottom_box,
  ])

  let processor = new_comment_postprocessor_layout_processor()
  processor.process(graph, None)

  inspect(layer.get_nodes().length(), content="3")
  inspect(top_box.get_position().x, content="110")
  inspect(top_box.get_position().y, content="178")
  inspect(bottom_box.get_position().x, content="105")
  inspect(bottom_box.get_position().y, content="233")

  inspect(top_box_port.get_position().x, content="10")
  inspect(top_box_port.get_position().y, content="10")
  inspect(bottom_box_port.get_position().x, content="15")
  inspect(bottom_box_port.get_position().y, content="0")

  inspect(top_node_port.get_position().x, content="20")
  inspect(top_node_port.get_position().y, content="0")
  inspect(bottom_node_port.get_position().x, content="20")
  inspect(bottom_node_port.get_position().y, content="30")

  inspect(
    comment_postprocessor_test_port_id(top_edge.get_source()),
    content="201",
  )
  inspect(
    comment_postprocessor_test_port_id(top_edge.get_target()),
    content="101",
  )
  inspect(
    comment_postprocessor_test_port_id(bottom_edge.get_source()),
    content="102",
  )
  inspect(
    comment_postprocessor_test_port_id(bottom_edge.get_target()),
    content="202",
  )
}
