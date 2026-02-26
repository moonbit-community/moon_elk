///|
fn transfer_sample_graph() -> Json {
  gj_obj([
    ("id", gj_str("root")),
    (
      "children",
      gj_arr([
        gj_obj([
          ("id", gj_str("n1")),
          ("width", gj_num(40)),
          ("height", gj_num(40)),
        ]),
        gj_obj([
          ("id", gj_str("n2")),
          ("width", gj_num(40)),
          ("height", gj_num(40)),
        ]),
      ]),
    ),
    (
      "edges",
      gj_arr([
        gj_obj([
          ("id", gj_str("e1")),
          ("source", gj_str("n1")),
          ("target", gj_str("n2")),
        ]),
      ]),
    ),
  ])
}

///|
fn required_importer(
  maybe_importer : @core.Maybe[JsonImporter],
) -> JsonImporter {
  match maybe_importer.get() {
    Some(importer) => importer
    None => abort("missing importer")
  }
}

///|
fn transfer_json_obj(json : Json) -> Map[String, Json] {
  match json {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn transfer_json_arr(json : Json) -> Array[Json] {
  match json {
    Array(arr) => arr
    _ => abort("expected array")
  }
}

///|
fn transfer_positive_coordinate(obj : Map[String, Json], key : String) -> Bool {
  match obj.get(key) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      value > 0.0
    }
    _ => false
  }
}

///|
test "graph json transfer layout" {
  @graph.reset_graph_model_for_test()
  let graph = transfer_sample_graph()
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  required_importer(maybe_importer).transfer_layout(root)
}

///|
test "graph json transfer layout fail when graph changed reports runtime error" {
  @graph.reset_graph_model_for_test()
  let graph = transfer_sample_graph()
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  ignore(@graph.create_node(Some(root)))
  required_importer(maybe_importer).transfer_layout(root)
  let error = @core.layout_runtime_take_error_message()
  assert_eq(error is Some(_), true)
  if error is Some(message) {
    assert_eq(message.is_empty(), false)
  }
}

///|
test "graph json transfer layout edge section exists" {
  @graph.reset_graph_model_for_test()
  @core.layout_meta_data_service_reset_for_test()
  @core.layout_meta_data_service_register_default_algorithms()
  let graph = transfer_sample_graph()
  let maybe_importer : @core.Maybe[JsonImporter] = @core.maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  let engine = @core.new_recursive_graph_layout_engine()
  engine.layout(root, @core.new_basic_progress_monitor())
  required_importer(maybe_importer).transfer_layout(root)
  let graph_obj = transfer_json_obj(graph)
  let children = transfer_json_arr(graph_obj["children"])
  for child in children {
    let child_obj = transfer_json_obj(child)
    assert_eq(transfer_positive_coordinate(child_obj, "x"), true)
    assert_eq(transfer_positive_coordinate(child_obj, "y"), true)
  }
  let edges = transfer_json_arr(graph_obj["edges"])
  for edge in edges {
    let edge_obj = transfer_json_obj(edge)
    assert_eq(edge_obj.contains("sections"), true)
    let sections = transfer_json_arr(edge_obj["sections"])
    assert_eq(sections.is_empty(), false)
    for section in sections {
      let section_obj = transfer_json_obj(section)
      assert_eq(section_obj.contains("id"), true)
      assert_eq(section_obj.contains("startPoint"), true)
      assert_eq(section_obj.contains("endPoint"), true)
    }
    assert_eq(edge_obj.contains("container"), true)
  }
}
