///|
fn edge_coords_json_obj(json : Json) -> Map[String, Json] {
  match json {
    Object(obj) => obj
    _ => abort("expected object")
  }
}

///|
fn edge_coords_json_arr(json : Json) -> Array[Json] {
  match json {
    Array(arr) => arr
    _ => abort("expected array")
  }
}

///|
fn edge_coords_json_num(json : Json) -> Double {
  match json {
    Number(value, repr~) => {
      ignore(repr)
      value
    }
    _ => abort("expected number")
  }
}

///|
fn edge_coords_find_child(
  parent : Map[String, Json],
  identifier : String,
) -> Map[String, Json] {
  for child in edge_coords_json_arr(parent["children"]) {
    let child_obj = edge_coords_json_obj(child)
    if child_obj["id"] == Json::string(identifier) {
      return child_obj
    }
  }
  abort("child not found")
}

///|
fn edge_coords_first_edge(node_obj : Map[String, Json]) -> Map[String, Json] {
  let edges = edge_coords_json_arr(node_obj["edges"])
  edge_coords_json_obj(edges[0])
}

///|
fn edge_coords_first_section(edge_obj : Map[String, Json]) -> Map[String, Json] {
  let sections = edge_coords_json_arr(edge_obj["sections"])
  edge_coords_json_obj(sections[0])
}

///|
fn edge_coords_num_field(obj : Map[String, Json], key : String) -> Double {
  edge_coords_json_num(obj[key])
}

///|
fn edge_coords_point_x(
  section_obj : Map[String, Json],
  point_key : String,
) -> Double {
  let point_obj = edge_coords_json_obj(section_obj[point_key])
  edge_coords_num_field(point_obj, "x")
}

///|
fn edge_coords_approx_equal(value : Double, expected : Double) -> Bool {
  (value - expected).abs() < 0.001
}

///|
fn edge_coords_required_importer(
  maybe_importer : Maybe[JsonImporter],
) -> JsonImporter {
  match maybe_importer.get() {
    Some(importer) => importer
    None => abort("missing importer")
  }
}

///|
fn edge_coords_sample_graph(
  shape_coords : String,
  edge_coords : String,
) -> Json {
  gj_obj([
    ("id", gj_str("root")),
    (
      "properties",
      gj_obj([
        ("algorithm", gj_str("layered")),
        ("org.eclipse.elk.hierarchyHandling", gj_str("INCLUDE_CHILDREN")),
        ("org.eclipse.elk.json.shapeCoords", gj_str(shape_coords)),
        ("org.eclipse.elk.json.edgeCoords", gj_str(edge_coords)),
      ]),
    ),
    (
      "children",
      gj_arr([
        gj_obj([
          ("id", gj_str("A")),
          (
            "children",
            gj_arr([
              gj_obj([
                ("id", gj_str("x")),
                ("width", gj_num(50)),
                ("height", gj_num(40)),
              ]),
              gj_obj([
                ("id", gj_str("z")),
                ("width", gj_num(50)),
                ("height", gj_num(40)),
              ]),
            ]),
          ),
          (
            "edges",
            gj_arr([
              gj_obj([
                ("id", gj_str("e1")),
                ("source", gj_str("x")),
                ("target", gj_str("z")),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
}

///|
fn edge_coords_run_case(
  shape_coords : String,
  edge_coords : String,
) -> Map[String, Json] {
  reset_graph_model_for_test()
  layout_meta_data_service_reset_for_test()
  layout_meta_data_service_register_default_algorithms()
  let graph = edge_coords_sample_graph(shape_coords, edge_coords)
  let maybe_importer : Maybe[JsonImporter] = maybe_create()
  let root = elk_graph_json_for_json_graph(graph)
    .remember_importer(maybe_importer)
    .to_elk()
  let engine = new_recursive_graph_layout_engine()
  engine.layout(root, new_basic_progress_monitor())
  edge_coords_required_importer(maybe_importer).transfer_layout(root)
  edge_coords_json_obj(graph)
}

///|
test "graph json edge coords and shape coords modes" {
  let parent_container = edge_coords_run_case("PARENT", "CONTAINER")
  let root_container = edge_coords_run_case("ROOT", "CONTAINER")
  let root_root = edge_coords_run_case("ROOT", "ROOT")

  let a_pc = edge_coords_find_child(parent_container, "A")
  let a_rc = edge_coords_find_child(root_container, "A")
  let a_rr = edge_coords_find_child(root_root, "A")
  let x_pc = edge_coords_find_child(a_pc, "x")
  let x_rc = edge_coords_find_child(a_rc, "x")

  assert_eq(
    edge_coords_approx_equal(
      edge_coords_num_field(x_rc, "x"),
      edge_coords_num_field(x_pc, "x") + edge_coords_num_field(a_pc, "x"),
    ),
    true,
  )

  let e_rc = edge_coords_first_edge(a_rc)
  let e_rr = edge_coords_first_edge(a_rr)
  let s_rc = edge_coords_first_section(e_rc)
  let s_rr = edge_coords_first_section(e_rr)
  assert_eq(
    edge_coords_approx_equal(
      edge_coords_point_x(s_rr, "startPoint"),
      edge_coords_point_x(s_rc, "startPoint") + edge_coords_num_field(a_rc, "x"),
    ),
    true,
  )
  assert_eq(e_rc.contains("container"), true)
  assert_eq(e_rr.contains("container"), false)
}
