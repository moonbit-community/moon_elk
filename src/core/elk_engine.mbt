///|
pub(all) struct ElkEngine {
  default_layout_options : Map[String, Json]
  algorithms : Array[String]
}

///|
pub type ElkEngineLayoutDelegate = (Map[String, Json], Map[String, Json]) -> Unit

///|
let elk_engine_layout_delegate_ref : Ref[ElkEngineLayoutDelegate?] = Ref::new(
  None,
)

///|
pub fn elk_engine_register_layout_delegate(
  delegate : ElkEngineLayoutDelegate,
) -> Unit {
  elk_engine_layout_delegate_ref.val = Some(delegate)
}

///|
pub fn elk_engine_clear_layout_delegate_for_test() -> Unit {
  elk_engine_layout_delegate_ref.val = None
}

///|
fn elk_engine_apply_delegate_if_registered(
  graph_obj : Map[String, Json],
  options : Map[String, Json],
) -> Bool {
  if elk_engine_layout_delegate_ref.val is Some(delegate) {
    delegate(graph_obj, options)
    true
  } else {
    false
  }
}

///|
fn copy_json_map(source : Map[String, Json]) -> Map[String, Json] {
  source.copy()
}

///|
pub fn new_elk_engine(
  default_layout_options? : Map[String, Json] = {},
  algorithms? : Array[String] = [
    "layered", "force", "stress", "radial", "mrtree", "rectpacking", "sporeOverlap",
    "sporeCompaction", "fixed", "box", "random", "vertiflex", "disco", "topdownpacking",
    "libavoid", "dot", "neato", "fdp", "sfdp", "twopi", "circo",
  ],
) -> ElkEngine {
  {
    default_layout_options: copy_json_map(default_layout_options),
    algorithms: algorithms.copy(),
  }
}

///|
pub fn ElkEngine::known_layout_algorithms(self : ElkEngine) -> Array[String] {
  self.algorithms.copy()
}

///|
pub fn ElkEngine::terminate_worker(self : ElkEngine) -> Unit {
  ignore(self)
}

///|
fn invalid_graph_error(message : String) -> Error {
  Failure::Failure(message)
}

///|
fn ensure_object(
  json : Json,
  error_message : String,
) -> Map[String, Json] raise {
  match json {
    Object(obj) => obj
    _ => raise invalid_graph_error(error_message)
  }
}

///|
fn optional_object_field(
  obj : Map[String, Json],
  key : String,
) -> Map[String, Json]? {
  match obj.get(key) {
    Some(Object(field)) => Some(field)
    _ => None
  }
}

///|
fn json_to_option_string(json : Json) -> String? {
  match json {
    String(value) => Some(value)
    Number(value, repr~) => {
      ignore(repr)
      Some(value.to_string())
    }
    True => Some("true")
    False => Some("false")
    _ => None
  }
}

///|
fn option_by_keys(options : Map[String, Json], keys : Array[String]) -> Json? {
  for key in keys {
    if options.get(key) is Some(value) {
      return Some(value)
    }
  }
  None
}

///|
fn option_string_by_keys(
  options : Map[String, Json],
  keys : Array[String],
) -> String? {
  if option_by_keys(options, keys) is Some(value) {
    json_to_option_string(value)
  } else {
    None
  }
}

///|
fn merge_into(target : Map[String, Json], source : Map[String, Json]) -> Unit {
  source.each((key, value) => target[key] = value)
}

///|
fn merged_options(
  default_layout_options : Map[String, Json],
  call_layout_options : Map[String, Json],
  graph_obj : Map[String, Json],
) -> Map[String, Json] {
  let merged = copy_json_map(default_layout_options)
  merge_into(merged, call_layout_options)
  if optional_object_field(graph_obj, "layoutOptions") is Some(layout_options) {
    merge_into(merged, layout_options)
  }
  if optional_object_field(graph_obj, "properties") is Some(properties) {
    merge_into(merged, properties)
  }
  merged
}

///|
fn normalize_algorithm(raw_algorithm : String) -> String? {
  match raw_algorithm {
    "layered" | "elk.layered" | "org.eclipse.elk.layered" => Some("layered")
    "force" | "elk.force" | "org.eclipse.elk.force" => Some("force")
    "stress" | "elk.stress" | "org.eclipse.elk.stress" => Some("stress")
    "radial" | "elk.radial" | "org.eclipse.elk.radial" => Some("radial")
    "mrtree" | "elk.mrtree" | "org.eclipse.elk.mrtree" => Some("mrtree")
    "rectpacking" | "elk.rectpacking" | "org.eclipse.elk.rectpacking" =>
      Some("rectpacking")
    "sporeOverlap"
    | "elk.sporeOverlap"
    | "org.eclipse.elk.sporeOverlap"
    | "org.eclipse.elk.sporeoverlap" => Some("sporeOverlap")
    "sporeCompaction"
    | "elk.sporeCompaction"
    | "org.eclipse.elk.sporeCompaction"
    | "org.eclipse.elk.sporecompaction" => Some("sporeCompaction")
    "fixed" | "elk.fixed" | "org.eclipse.elk.fixed" => Some("fixed")
    "box" | "elk.box" | "org.eclipse.elk.box" => Some("box")
    "random" | "elk.random" | "org.eclipse.elk.random" => Some("random")
    "vertiflex" | "elk.vertiflex" | "org.eclipse.elk.vertiflex" =>
      Some("vertiflex")
    "disco" | "elk.disco" | "org.eclipse.elk.disco" => Some("disco")
    "topdownpacking"
    | "elk.topdownpacking"
    | "org.eclipse.elk.topdownpacking" => Some("topdownpacking")
    "libavoid" | "elk.libavoid" | "org.eclipse.elk.libavoid" => Some("libavoid")
    "dot" | "elk.graphviz.dot" | "org.eclipse.elk.graphviz.dot" => Some("dot")
    "neato" | "elk.graphviz.neato" | "org.eclipse.elk.graphviz.neato" =>
      Some("neato")
    "fdp" | "elk.graphviz.fdp" | "org.eclipse.elk.graphviz.fdp" => Some("fdp")
    "sfdp" | "elk.graphviz.sfdp" | "org.eclipse.elk.graphviz.sfdp" =>
      Some("sfdp")
    "twopi" | "elk.graphviz.twopi" | "org.eclipse.elk.graphviz.twopi" =>
      Some("twopi")
    "circo" | "elk.graphviz.circo" | "org.eclipse.elk.graphviz.circo" =>
      Some("circo")
    _ => None
  }
}

///|
fn resolve_algorithm(options : Map[String, Json]) -> String raise {
  let raw = option_string_by_keys(options, [
    "algorithm", "elk.algorithm", "org.eclipse.elk.algorithm",
  ]).unwrap_or("layered")
  match normalize_algorithm(raw) {
    Some(algorithm) => algorithm
    None =>
      raise invalid_graph_error(
        "org.eclipse.elk.core.UnsupportedConfigurationException: Unknown layouter id",
      )
  }
}

///|
fn clear_logging(graph_obj : Map[String, Json]) -> Unit {
  graph_obj.remove("logging")
}

///|
fn ensure_graph_id(graph_obj : Map[String, Json]) -> Unit raise {
  match graph_obj.get("id") {
    None => raise invalid_graph_error("Graph id is missing")
    Some(String(_)) => ()
    Some(Number(value, repr~)) => {
      ignore(repr)
      if value != value.floor() {
        raise invalid_graph_error("Graph id must be string or integral number")
      }
    }
    Some(_) =>
      raise invalid_graph_error("Graph id must be string or integral number")
  }
}

///|
fn add_logging(
  graph_obj : Map[String, Json],
  include_execution_time : Bool,
) -> Unit {
  let logging = { "children": Json::array([Json::object({})]) }
  if include_execution_time {
    logging["executionTime"] = Json::number(1)
  }
  graph_obj["logging"] = Json::object(logging)
}

///|
fn is_known_unsupported_algorithm(algorithm : String) -> Bool {
  match algorithm {
    "disco"
    | "topdownpacking"
    | "libavoid"
    | "dot"
    | "neato"
    | "fdp"
    | "sfdp"
    | "twopi"
    | "circo" => true
    _ => false
  }
}

///|
pub fn ElkEngine::layout(
  self : ElkEngine,
  graph? : Json,
  layout_options? : Map[String, Json] = {},
  logging? : Bool = false,
  measure_execution_time? : Bool = false,
) -> Json raise {
  let graph = match graph {
    Some(graph) => graph
    None => raise invalid_graph_error("Missing mandatory parameter 'graph'.")
  }
  let graph_obj = ensure_object(graph, "Graph must be an object")
  ensure_graph_id(graph_obj)
  clear_logging(graph_obj)
  let options = merged_options(
    self.default_layout_options,
    layout_options,
    graph_obj,
  )
  let root_algorithm = resolve_algorithm(options)
  if !self.algorithms.contains(root_algorithm) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Unknown layouter id",
    )
  }
  if is_known_unsupported_algorithm(root_algorithm) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Layout algorithm '" +
      root_algorithm +
      "' not found for Root Node root",
    )
  }
  layout_runtime_clear_error()
  if !elk_engine_apply_delegate_if_registered(graph_obj, options) {
    raise invalid_graph_error(
      "org.eclipse.elk.core.UnsupportedConfigurationException: Unknown layouter id",
    )
  }
  if layout_runtime_take_error_message() is Some(layout_error) {
    raise invalid_graph_error(layout_error)
  }
  if logging || measure_execution_time {
    add_logging(graph_obj, measure_execution_time)
  }
  Json::object(graph_obj)
}
