///|
fn j_obj(entries : Array[(String, Json)]) -> Json {
  Json::object(Map::from_array(entries))
}

///|
fn j_arr(items : Array[Json]) -> Json {
  Json::array(items)
}

///|
fn j_num(value : Int) -> Json {
  Json::number(value.to_double())
}

///|
fn j_str(value : String) -> Json {
  Json::string(value)
}

///|
fn json_obj(json : Json) -> Map[String, Json] {
  match json {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn json_arr(json : Json) -> Array[Json] {
  match json {
    Array(arr) => arr
    _ => abort("expected array")
  }
}

///|
fn json_int_field(json : Json, key : String) -> Int {
  let obj = json_obj(json)
  match obj.get(key) {
    Some(Number(value, repr~)) => {
      ignore(repr)
      value.to_int()
    }
    _ => abort("expected numeric field")
  }
}

///|
fn json_obj_field(json : Json, key : String) -> Json {
  let obj = json_obj(json)
  match obj.get(key) {
    Some(value) => value
    None => abort("expected field")
  }
}

///|
fn contains_unsupported_configuration(err : Error) -> Bool {
  err
  .to_string()
  .contains("org.eclipse.elk.core.UnsupportedConfigurationException")
}

///|
fn contains_unsupported_graph(err : Error) -> Bool {
  err.to_string().contains("org.eclipse.elk.core.UnsupportedGraphException")
}

///|
fn make_simple_graph() -> Json {
  j_obj([
    ("id", j_str("root")),
    ("layoutOptions", j_obj([("elk.direction", j_str("RIGHT"))])),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(10)), ("height", j_num(10))]),
        j_obj([("id", j_str("n2")), ("width", j_num(10)), ("height", j_num(10))]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
      ]),
    ),
  ])
}

///|
fn make_bug8_graph(primitive_edge : Bool) -> Json {
  let edge = if primitive_edge {
    j_obj([
      ("id", j_str("a1:0")),
      ("source", j_str("a1")),
      ("target", j_str("A")),
    ])
  } else {
    j_obj([
      ("id", j_str("a1:0")),
      ("sources", j_arr([j_str("a1")])),
      ("targets", j_arr([j_str("A")])),
    ])
  }
  j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("A")),
          (
            "children",
            j_arr([
              j_obj([("id", j_str("a1"))]),
              j_obj([("id", j_str("a2"))]),
              j_obj([("id", j_str("$generated_A_initial_0"))]),
            ]),
          ),
          ("edges", j_arr([edge])),
        ]),
        j_obj([("id", j_str("$generated_root_initial_0"))]),
      ]),
    ),
  ])
}

///|
fn make_cycle_first_graph() -> Json {
  j_obj([
    ("id", j_str("root")),
    ("properties", j_obj([("algorithm", j_str("layered"))])),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("n1")),
          ("width", j_num(30)),
          ("height", j_num(30)),
          ("layoutOptions", j_obj([("layerConstraint", j_str("FIRST"))])),
        ]),
        j_obj([
          ("id", j_str("n2")),
          ("width", j_num(30)),
          ("height", j_num(30)),
          ("layoutOptions", j_obj([("layerConstraint", j_str("FIRST"))])),
        ]),
        j_obj([
          ("id", j_str("n3")),
          ("width", j_num(30)),
          ("height", j_num(30)),
          ("layoutOptions", j_obj([("layerConstraint", j_str("FIRST"))])),
        ]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
        j_obj([
          ("id", j_str("e2")),
          ("sources", j_arr([j_str("n2")])),
          ("targets", j_arr([j_str("n3")])),
        ]),
        j_obj([
          ("id", j_str("e3")),
          ("sources", j_arr([j_str("n3")])),
          ("targets", j_arr([j_str("n1")])),
        ]),
      ]),
    ),
  ])
}

///|
fn make_linear_graph(node_count : Int) -> Json {
  let children = []
  for i = 0; i < node_count; i = i + 1 {
    children.push(
      j_obj([
        ("id", j_str("n\{i}")),
        ("width", j_num(10)),
        ("height", j_num(10)),
      ]),
    )
  }
  let edges = []
  for i = 0; i < node_count - 1; i = i + 1 {
    edges.push(
      j_obj([
        ("id", j_str("e\{i}")),
        ("sources", j_arr([j_str("n\{i}")])),
        ("targets", j_arr([j_str("n\{i + 1}")])),
      ]),
    )
  }
  j_obj([
    ("id", j_str("root")),
    ("children", j_arr(children)),
    ("edges", j_arr(edges)),
  ])
}

///|
test "ElkEngine parameters: missing graph" {
  let elk = new_elk_engine()
  let result = try? elk.layout()
  assert_true(result is Err(_))
}

///|
test "ElkEngine id validation" {
  let elk = new_elk_engine()
  assert_true((try? elk.layout(graph=j_obj([("id", j_str("x"))]))) is Ok(_))
  assert_true((try? elk.layout(graph=j_obj([("id", j_num(2))]))) is Ok(_))
  assert_true((try? elk.layout(graph=j_obj([]))) is Err(_))
  assert_true(
    (try? elk.layout(graph=j_obj([("id", Json::number(1.2))]))) is Err(_),
  )
  assert_true((try? elk.layout(graph=j_obj([("id", j_arr([]))]))) is Err(_))
  assert_true((try? elk.layout(graph=j_obj([("id", j_obj([]))]))) is Err(_))
  assert_true(
    (try? elk.layout(graph=j_obj([("id", Json::boolean(true))]))) is Err(_),
  )
}

///|
test "ElkEngine option precedence and spacing" {
  let elk = new_elk_engine()
  let graph = make_simple_graph()
  let laid_out = elk.layout(graph~, layout_options={
    "org.eclipse.elk.layered.spacing.nodeNodeBetweenLayers": j_num(11),
  })
  let children = json_arr(json_obj_field(laid_out, "children"))
  let n1 = children[0]
  let n2 = children[1]
  assert_eq(json_int_field(n1, "y"), json_int_field(n2, "y"))
  assert_eq((json_int_field(n2, "x") - json_int_field(n1, "x")).abs(), 21)
}

///|
test "ElkEngine concrete graph options are not overridden" {
  let elk = new_elk_engine()
  let graph = make_simple_graph()
  let laid_out = elk.layout(graph~, layout_options={
    "org.eclipse.elk.direction": j_str("DOWN"),
  })
  let graph_obj = json_obj(laid_out)
  let graph_layout_options = json_obj(json_obj_field(laid_out, "layoutOptions"))
  assert_eq(graph_layout_options.get("elk.direction"), Some(j_str("RIGHT")))
  let children = json_arr(graph_obj["children"])
  let n1 = children[0]
  let n2 = children[1]
  assert_true((json_int_field(n2, "x") - json_int_field(n1, "x")).abs() > 0)
  assert_eq(json_int_field(n1, "y"), json_int_field(n2, "y"))
}

///|
test "ElkEngine parses ElkPadding" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "layoutOptions",
      j_obj([("elk.padding", j_str("[left=2, top=3, right=3, bottom=2]"))]),
    ),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(10)), ("height", j_num(10))]),
      ]),
    ),
  ])
  let laid_out = elk.layout(graph~)
  let children = json_arr(json_obj_field(laid_out, "children"))
  let n1 = children[0]
  assert_eq(json_int_field(n1, "x"), 2)
  assert_eq(json_int_field(n1, "y"), 3)
  assert_eq(json_int_field(laid_out, "width"), 15)
  assert_eq(json_int_field(laid_out, "height"), 15)
}

///|
test "ElkEngine parses KVector for fixed algorithm" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("n1")),
          ("width", j_num(10)),
          ("height", j_num(10)),
          ("layoutOptions", j_obj([("position", j_str("(23, 43)"))])),
        ]),
      ]),
    ),
  ])
  let laid_out = elk.layout(graph~, layout_options={
    "algorithm": j_str("fixed"),
  })
  let n1 = json_arr(json_obj_field(laid_out, "children"))[0]
  assert_eq(json_int_field(n1, "x"), 23)
  assert_eq(json_int_field(n1, "y"), 43)
}

///|
test "ElkEngine parses KVectorChain for fixed edges" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(10)), ("height", j_num(10))]),
        j_obj([("id", j_str("n2")), ("width", j_num(10)), ("height", j_num(10))]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
          ("layoutOptions", j_obj([("bendPoints", j_str("( {1,2}, {3,4} )"))])),
        ]),
      ]),
    ),
  ])
  let laid_out = elk.layout(graph~, layout_options={
    "algorithm": j_str("fixed"),
  })
  let edges = json_arr(json_obj_field(laid_out, "edges"))
  let sections = json_arr(json_obj_field(edges[0], "sections"))
  let section0 = sections[0]
  let start = json_obj_field(section0, "startPoint")
  let end = json_obj_field(section0, "endPoint")
  assert_eq(json_int_field(start, "x"), 1)
  assert_eq(json_int_field(start, "y"), 2)
  assert_eq(json_int_field(end, "x"), 3)
  assert_eq(json_int_field(end, "y"), 4)
}

///|
test "ElkEngine invalid layouter id raises unsupported configuration" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(10)), ("height", j_num(10))]),
      ]),
    ),
    ("layoutOptions", j_obj([("algorithm", j_str("foo.bar.baz"))])),
  ])
  let result = try? elk.layout(graph~)
  match result {
    Ok(_) => assert_true(false)
    Err(err) => assert_true(contains_unsupported_configuration(err))
  }
}

///|
test "ElkEngine default global layout options" {
  let elk = new_elk_engine(default_layout_options={
    "elk.layered.spacing.nodeNodeBetweenLayers": j_num(33),
  })
  let laid_out = elk.layout(graph=make_simple_graph())
  let children = json_arr(json_obj_field(laid_out, "children"))
  let n1 = children[0]
  let n2 = children[1]
  assert_eq((json_int_field(n2, "x") - json_int_field(n1, "x")).abs(), 43)
}

///|
test "ElkEngine logging behavior" {
  let elk = new_elk_engine()
  let graph = make_simple_graph()
  let with_logging = elk.layout(
    graph~,
    layout_options={ "algorithm": j_str("stress") },
    logging=true,
  )
  let log_obj = json_obj(json_obj_field(with_logging, "logging"))
  ignore(json_obj_field(with_logging, "logging"))
  ignore(log_obj["children"])
  assert_eq(log_obj.get("executionTime"), None)
  let with_timing = elk.layout(
    graph~,
    layout_options={ "algorithm": j_str("layered") },
    measure_execution_time=true,
  )
  let timing = json_obj(json_obj_field(with_timing, "logging"))
  assert_true(timing.get("executionTime") is Some(_))
  let without_logging = elk.layout(
    graph~,
    logging=false,
    measure_execution_time=false,
  )
  let without_obj = json_obj(without_logging)
  assert_eq(without_obj.get("logging"), None)
}

///|
test "ElkEngine clears previous logging" {
  let elk = new_elk_engine()
  let graph = make_simple_graph()
  ignore(elk.layout(graph~, logging=true))
  assert_true(json_obj(graph).get("logging") is Some(_))
  ignore(elk.layout(graph~))
  assert_eq(json_obj(graph).get("logging"), None)
}

///|
test "ElkEngine SPOrE algorithms" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("n1")),
          ("x", j_num(20)),
          ("y", j_num(20)),
          ("width", j_num(10)),
          ("height", j_num(10)),
        ]),
        j_obj([
          ("id", j_str("n2")),
          ("x", j_num(50)),
          ("y", j_num(50)),
          ("width", j_num(10)),
          ("height", j_num(10)),
        ]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
      ]),
    ),
  ])
  let compaction = elk.layout(graph~, layout_options={
    "algorithm": j_str("elk.sporeCompaction"),
    "elk.spacing.nodeNode": j_num(14),
    "elk.padding": j_str("[left=2, top=2, right=2, bottom=2]"),
  })
  let compaction_children = json_arr(json_obj_field(compaction, "children"))
  assert_eq(json_int_field(compaction_children[0], "x"), 2)
  assert_eq(json_int_field(compaction_children[0], "y"), 2)
  assert_eq(json_int_field(compaction_children[1], "x"), 26)
  assert_eq(json_int_field(compaction_children[1], "y"), 26)
  let overlap_graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("n1")),
          ("x", j_num(20)),
          ("y", j_num(20)),
          ("width", j_num(10)),
          ("height", j_num(10)),
        ]),
        j_obj([
          ("id", j_str("n2")),
          ("x", j_num(25)),
          ("y", j_num(25)),
          ("width", j_num(10)),
          ("height", j_num(10)),
        ]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
      ]),
    ),
  ])
  let overlap = elk.layout(graph=overlap_graph, layout_options={
    "algorithm": j_str("elk.sporeOverlap"),
    "elk.spacing.nodeNode": j_num(13),
    "elk.padding": j_str("[left=3, top=3, right=3, bottom=3]"),
  })
  let overlap_children = json_arr(json_obj_field(overlap, "children"))
  assert_eq(json_int_field(overlap_children[0], "x"), 3)
  assert_eq(json_int_field(overlap_children[0], "y"), 3)
  assert_eq(json_int_field(overlap_children[1], "x"), 26)
  assert_eq(json_int_field(overlap_children[1], "y"), 26)
  assert_true(
    (try? elk.layout(graph=overlap_graph, layout_options={
      "algorithm": j_str("elk.rectpacking"),
    }))
    is Ok(_),
  )
}

///|
test "ElkEngine bug regressions that should fulfill" {
  let elk = new_elk_engine()
  let bug63_graph = j_obj([
    ("id", j_str("root")),
    (
      "properties",
      j_obj([
        ("algorithm", j_str("layered")),
        ("layering.strategy", j_str("COFFMAN_GRAHAM")),
      ]),
    ),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(30)), ("height", j_num(30))]),
        j_obj([("id", j_str("n2")), ("width", j_num(30)), ("height", j_num(30))]),
        j_obj([("id", j_str("n3")), ("width", j_num(30)), ("height", j_num(30))]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
        j_obj([
          ("id", j_str("e2")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n3")])),
        ]),
        j_obj([
          ("id", j_str("e3")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n1")])),
        ]),
      ]),
    ),
  ])
  assert_true((try? elk.layout(graph=bug63_graph)) is Ok(_))
  let klay23_graph = j_obj([
    ("id", j_str("root")),
    (
      "layoutOptions",
      j_obj([
        ("elk.algorithm", j_str("layered")),
        ("elk.layered.crossingMinimization.strategy", j_str("INTERACTIVE")),
      ]),
    ),
    (
      "children",
      j_arr([
        j_obj([("id", j_str("n1")), ("width", j_num(10)), ("height", j_num(10))]),
        j_obj([("id", j_str("n2")), ("width", j_num(10)), ("height", j_num(10))]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
        j_obj([
          ("id", j_str("e2")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
          (
            "sections",
            j_arr([
              j_obj([
                ("id", j_str("es2")),
                ("startPoint", j_obj([("x", j_num(0)), ("y", j_num(0))])),
                (
                  "bendPoints",
                  j_arr([j_obj([("x", j_num(20)), ("y", j_num(0))])]),
                ),
                ("endPoint", j_obj([("x", j_num(50)), ("y", j_num(0))])),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
  assert_true((try? elk.layout(graph=klay23_graph)) is Ok(_))
}

///|
test "ElkEngine bug #7 style graph should succeed" {
  let elk = new_elk_engine()
  let graph = j_obj([
    ("id", j_str("root")),
    (
      "children",
      j_arr([
        j_obj([
          ("id", j_str("n1")),
          ("width", j_num(174)),
          ("height", j_num(80)),
          (
            "ports",
            j_arr([
              j_obj([
                ("id", j_str("n1_0")),
                ("width", j_num(18)),
                ("height", j_num(18)),
                (
                  "properties",
                  j_obj([
                    ("port.side", j_str("NORTH")),
                    ("port.index", j_str("0")),
                  ]),
                ),
              ]),
            ]),
          ),
          ("properties", j_obj([("portConstraints", j_str("FIXED_ORDER"))])),
        ]),
        j_obj([
          ("id", j_str("n2")),
          ("width", j_num(232)),
          ("height", j_num(80)),
        ]),
      ]),
    ),
    (
      "edges",
      j_arr([
        j_obj([
          ("id", j_str("e1")),
          ("sources", j_arr([j_str("n1")])),
          ("targets", j_arr([j_str("n2")])),
        ]),
      ]),
    ),
  ])
  assert_true((try? elk.layout(graph~)) is Ok(_))
}

///|
test "ElkEngine large graph should finish (ChangeAwareArrayList)" {
  let elk = new_elk_engine()
  let graph = make_linear_graph(120)
  assert_true((try? elk.layout(graph~)) is Ok(_))
}

///|
test "ElkEngine construction and terminate worker no-op" {
  let elk = new_elk_engine(algorithms=[
    "layered", "stress", "sporeCompaction", "sporeOverlap", "rectpacking", "fixed",
  ])
  let algorithms = elk.known_layout_algorithms()
  assert_true(algorithms.contains("layered"))
  elk.terminate_worker()
  assert_true((try? elk.layout(graph=make_linear_graph(3))) is Ok(_))
}

///|
test "ElkEngine hierarchical layout behavior (bug #8)" {
  let elk = new_elk_engine()
  let separate_result = try? elk.layout(graph=make_bug8_graph(false), layout_options={
    "hierarchyHandling": j_str("SEPARATE_CHILDREN"),
  })
  match separate_result {
    Ok(_) => assert_true(false)
    Err(err) => assert_true(contains_unsupported_graph(err))
  }
  let included = elk.layout(graph=make_bug8_graph(false), layout_options={
    "hierarchyHandling": j_str("INCLUDE_CHILDREN"),
  })
  let child_a = json_arr(json_obj_field(included, "children"))[0]
  let child_a_edges = json_arr(json_obj_field(child_a, "edges"))
  let edge_sections = json_arr(json_obj_field(child_a_edges[0], "sections"))
  assert_eq(edge_sections.length(), 1)
  ignore(json_obj_field(edge_sections[0], "startPoint"))
  ignore(json_obj_field(edge_sections[0], "endPoint"))
  let included_primitive = elk.layout(graph=make_bug8_graph(true), layout_options={
    "hierarchyHandling": j_str("INCLUDE_CHILDREN"),
  })
  let primitive_child_a = json_arr(
      json_obj_field(included_primitive, "children"),
    )[0]
  let primitive_edges = json_arr(json_obj_field(primitive_child_a, "edges"))
  let primitive_sections = json_arr(
    json_obj_field(primitive_edges[0], "sections"),
  )
  assert_eq(primitive_sections.length(), 1)
}

///|
test "ElkEngine unsupported configuration raise" {
  let elk = new_elk_engine()
  let result = try? elk.layout(graph=make_cycle_first_graph())
  match result {
    Ok(_) => assert_true(false)
    Err(err) => assert_true(contains_unsupported_configuration(err))
  }
}
