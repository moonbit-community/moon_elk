///|
fn disco_engine_object(json : Json) -> Map[String, Json] {
  match json {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn disco_engine_array_field(json : Json, key : String) -> Array[Json] {
  match disco_engine_object(json).get(key) {
    Some(Array(values)) => values
    _ => abort("expected array field " + key)
  }
}

///|
fn disco_engine_number_field(json : Json, key : String) -> Double {
  match disco_engine_object(json).get(key) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      value
    }
    _ => abort("expected numeric field " + key)
  }
}

///|
test "ElkEngine runs disco compaction" {
  let engine = new_elk_engine()
  let graph = Json::object({
    "id": Json::string("root"),
    "width": Json::number(120.0),
    "height": Json::number(60.0),
    "layoutOptions": Json::object({
      "elk.algorithm": Json::string("disco"),
      "elk.padding": Json::string("[left=4, top=4, right=4, bottom=4]"),
      "org.eclipse.elk.spacing.componentComponent": Json::number(12.0),
      "org.eclipse.elk.alg.common.compaction.polyomino.fill": Json::boolean(
        false,
      ),
      "org.eclipse.elk.disco.componentCompaction.strategy": Json::string(
        "POLYOMINO",
      ),
    }),
    "children": Json::array([
      Json::object({
        "id": Json::string("left"),
        "x": Json::number(0.0),
        "y": Json::number(0.0),
        "width": Json::number(20.0),
        "height": Json::number(10.0),
      }),
      Json::object({
        "id": Json::string("right"),
        "x": Json::number(80.0),
        "y": Json::number(0.0),
        "width": Json::number(20.0),
        "height": Json::number(10.0),
      }),
    ]),
  })

  let output = engine.layout(graph~)
  let children = disco_engine_array_field(output, "children")
  assert_eq(children.length(), 2)
  let left = children[0]
  let right = children[1]
  assert_true(disco_engine_number_field(output, "width") > 0.0)
  assert_true(disco_engine_number_field(output, "height") > 0.0)
  assert_true(
    disco_engine_number_field(left, "x") != 0.0 ||
    disco_engine_number_field(right, "x") != 80.0,
  )
}
