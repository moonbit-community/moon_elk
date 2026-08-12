///|
fn invalid_json_element(field : String) -> Map[String, Json] {
  let graph : Map[String, Json] = { "id": Json::string("root") }
  graph[field] = Json::array([Json::object({})])
  graph
}

///|
test "json importer disposes its arena when construction raises" {
  let invalid_graphs : Array[Map[String, Json]] = [
    {},
    invalid_json_element("children"),
    invalid_json_element("ports"),
    invalid_json_element("edges"),
  ]
  for graph in invalid_graphs {
    let arena = @graph.new_graph_arena()
    let importer = new_json_importer(
      new_codec_metadata(),
      @core.new_layout_session(),
    )
    try importer.transform_in_arena(graph, arena) catch {
      _ => assert_false(arena.is_alive())
    } noraise {
      root => {
        @graph.dispose_graph(root)
        fail("expected JSON import to raise")
      }
    }
  }
}

///|
test "json importer transfers a successful arena to the returned root" {
  let arena = @graph.new_graph_arena()
  let importer = new_json_importer(
    new_codec_metadata(),
    @core.new_layout_session(),
  )
  let root = importer.transform_in_arena({ "id": Json::string("root") }, arena)
  assert_true(arena.is_alive())
  @graph.dispose_graph(root)
  assert_false(arena.is_alive())
}
