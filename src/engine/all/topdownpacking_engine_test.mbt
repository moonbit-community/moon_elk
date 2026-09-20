///|
fn topdownpacking_engine_object(json : Json) -> Map[String, Json] {
  match json {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn topdownpacking_engine_array_field(json : Json, key : String) -> Array[Json] {
  match topdownpacking_engine_object(json).get(key) {
    Some(Array(values)) => values
    _ => abort("expected array field " + key)
  }
}

///|
fn topdownpacking_engine_number_field(json : Json, key : String) -> Double {
  match topdownpacking_engine_object(json).get(key) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      value
    }
    _ => abort("expected numeric field " + key)
  }
}

///|
test "ElkEngine runs topdownpacking" {
  let engine = new_elk_engine()
  let graph = Json::object({
    "id": Json::string("root"),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string("topdownpacking"),
      "elk.padding": Json::string("[left=0, top=0, right=0, bottom=0]"),
      "elk.spacing.nodeNode": Json::number(0.0),
      "org.eclipse.elk.topdown.hierarchicalNodeWidth": Json::number(10.0),
      "org.eclipse.elk.topdown.hierarchicalNodeAspectRatio": Json::number(1.0),
    }),
    "children": Json::array([
      Json::object({
        "id": Json::string("n0"),
        "width": Json::number(0.0),
        "height": Json::number(0.0),
      }),
      Json::object({
        "id": Json::string("n1"),
        "width": Json::number(0.0),
        "height": Json::number(0.0),
      }),
      Json::object({
        "id": Json::string("n2"),
        "width": Json::number(0.0),
        "height": Json::number(0.0),
      }),
      Json::object({
        "id": Json::string("n3"),
        "width": Json::number(0.0),
        "height": Json::number(0.0),
      }),
    ]),
  })

  let output = engine.layout(graph~)
  let children = topdownpacking_engine_array_field(output, "children")
  assert_eq(children.length(), 4)
  assert_eq(topdownpacking_engine_number_field(output, "width"), 20.0)
  assert_eq(topdownpacking_engine_number_field(output, "height"), 20.0)
  assert_eq(topdownpacking_engine_number_field(children[0], "x"), 0.0)
  assert_eq(topdownpacking_engine_number_field(children[0], "y"), 0.0)
  assert_eq(topdownpacking_engine_number_field(children[1], "x"), 10.0)
  assert_eq(topdownpacking_engine_number_field(children[1], "y"), 0.0)
  assert_eq(topdownpacking_engine_number_field(children[2], "x"), 0.0)
  assert_eq(topdownpacking_engine_number_field(children[2], "y"), 10.0)
  assert_eq(topdownpacking_engine_number_field(children[3], "x"), 10.0)
  assert_eq(topdownpacking_engine_number_field(children[3], "y"), 10.0)
}
